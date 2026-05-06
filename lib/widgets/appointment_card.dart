import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../utils/utils.dart';
import 'status_badge.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Token: ${appointment.queuePosition}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(status: appointment.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                appointment.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.medical_services, size: 16, color: Colors.teal),
                  const SizedBox(width: 4),
                  Text(appointment.serviceType),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.teal),
                      const SizedBox(width: 4),
                      Text(Utils.formatDate(appointment.date)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.teal),
                      const SizedBox(width: 4),
                      Text(appointment.timeSlot),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (!appointment.isSynced)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.cloud_off, size: 16, color: Colors.orange),
                    SizedBox(width: 4),
                    Text(
                      'Unsynced',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
