import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service_type.dart';
import '../providers/appointment_provider.dart';
import '../utils/constants.dart';
import '../utils/utils.dart';
import '../widgets/custom_text_field.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String? _selectedService;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Full Name',
                controller: _nameController,
                prefixIcon: Icons.person,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              
              // Service Type Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Service Type',
                  prefixIcon: const Icon(Icons.medical_services),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ServiceConstants.services.map((s) {
                  return DropdownMenuItem(value: s.name, child: Text(s.name));
                }).toList(),
                onChanged: (val) => setState(() => _selectedService = val),
                validator: (val) => val == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Date Picker
              ListTile(
                title: Text(_selectedDate == null 
                  ? 'Select Date' 
                  : Utils.formatDate(_selectedDate!)),
                leading: const Icon(Icons.calendar_today, color: Colors.teal),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.grey),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
              if (_selectedDate == null)
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 4),
                  child: Text('Date is required', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              const SizedBox(height: 16),

              // Time Slot Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Time Slot',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: AppConstants.timeSlots.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (val) => setState(() => _selectedTimeSlot = val),
                validator: (val) => val == null ? 'Required' : null,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: provider.isLoading ? null : () async {
                  if (_formKey.currentState!.validate() && _selectedDate != null) {
                    final success = await provider.bookAppointment(
                      _nameController.text,
                      _selectedService!,
                      _selectedDate!,
                      _selectedTimeSlot!,
                    );

                    if (mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Appointment Booked!')),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Conflict detected! Slot unavailable.'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  }
                },
                child: provider.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
