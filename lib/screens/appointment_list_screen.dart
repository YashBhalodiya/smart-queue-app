import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../widgets/appointment_card.dart';

class AppointmentListScreen extends StatelessWidget {
  const AppointmentListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.appointments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.appointments.isEmpty) {
          return const Center(child: Text('No appointments found.'));
        }

        return Column(
          children: [
            if (provider.isOffline)
              Container(
                color: Colors.red,
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                child: const Text(
                  'Offline Mode - Changes will sync when online',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.appointments.length,
                itemBuilder: (context, index) {
                  return AppointmentCard(appointment: provider.appointments[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
