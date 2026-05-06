import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/queue_provider.dart';
import '../widgets/appointment_card.dart';

class QueueStatusScreen extends StatelessWidget {
  const QueueStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppointmentProvider, QueueProvider>(
      builder: (context, apptProvider, queueProvider, child) {
        final allAppts = apptProvider.appointments;
        final currentServing = queueProvider.getCurrentServingToken(allAppts);
        
        final activeAppts = allAppts.where((a) {
          return a.status == 'Scheduled' || a.status == 'In Progress';
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.teal,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Currently Serving Token',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentServing == 0 ? 'None' : currentServing.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Active Queue',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: activeAppts.isEmpty
                  ? const Center(child: Text('No active appointments in queue'))
                  : ListView.builder(
                      itemCount: activeAppts.length,
                      itemBuilder: (context, index) {
                        final appt = activeAppts[index];
                        final waitTime = queueProvider.estimateWaitingTime(appt, allAppts, currentServing);
                        
                        return Column(
                          children: [
                            AppointmentCard(appointment: appt),
                            if (appt.status == 'Scheduled')
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.timer, size: 16, color: Colors.orange),
                                    const SizedBox(width: 4),
                                    Text('Est. wait: $waitTime mins', style: const TextStyle(color: Colors.orange)),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
