import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../widgets/appointment_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        final all = provider.appointments;
        final pending = all.where((a) => a.status == 'Scheduled').length;
        final completed = all.where((a) => a.status == 'Completed').length;
        final cancelled = all.where((a) => a.status == 'Cancelled').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total', all.length.toString(), Colors.blue)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatCard('Pending', pending.toString(), Colors.orange)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Completed', completed.toString(), Colors.green)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatCard('Cancelled', cancelled.toString(), Colors.red)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Manage Appointments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              ...all.map((appt) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  title: Text('${appt.id} - ${appt.name}'),
                  subtitle: Text('Status: ${appt.status}'),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (appt.status == 'Scheduled')
                          TextButton(
                            onPressed: () => provider.updateStatus(appt.id, 'In Progress'),
                            child: const Text('Start'),
                          ),
                        if (appt.status == 'In Progress')
                          TextButton(
                            onPressed: () => provider.updateStatus(appt.id, 'Completed'),
                            child: const Text('Complete'),
                          ),
                        if (appt.status == 'Scheduled' || appt.status == 'In Progress')
                          TextButton(
                            onPressed: () => _showRescheduleDialog(context, appt, provider),
                            child: const Text('Reschedule'),
                          ),
                        if (appt.status == 'Scheduled' || appt.status == 'In Progress')
                          TextButton(
                            onPressed: () => provider.cancelAppointment(appt.id),
                            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                          ),
                      ],
                    )
                  ],
                ),
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, appt, AppointmentProvider provider) {
    DateTime? selectedDate;
    String? selectedTime;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reschedule Appointment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(selectedDate == null ? 'Select Date' : '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}'),
                    leading: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) setState(() => selectedDate = date);
                    },
                  ),
                  DropdownButton<String>(
                    hint: const Text('Select Time Slot'),
                    value: selectedTime,
                    items: const [
                      DropdownMenuItem(value: '09:00 AM - 10:00 AM', child: Text('09:00 AM - 10:00 AM')),
                      DropdownMenuItem(value: '10:00 AM - 11:00 AM', child: Text('10:00 AM - 11:00 AM')),
                      DropdownMenuItem(value: '11:00 AM - 12:00 PM', child: Text('11:00 AM - 12:00 PM')),
                      DropdownMenuItem(value: '01:00 PM - 02:00 PM', child: Text('01:00 PM - 02:00 PM')),
                      DropdownMenuItem(value: '02:00 PM - 03:00 PM', child: Text('02:00 PM - 03:00 PM')),
                    ],
                    onChanged: (val) => setState(() => selectedTime = val),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedDate != null && selectedTime != null) {
                      final success = await provider.rescheduleAppointment(appt.id, selectedDate!, selectedTime!);
                      if (success) {
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conflict detected!'), backgroundColor: Colors.red));
                      }
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          }
        );
      }
    );
  }
}
