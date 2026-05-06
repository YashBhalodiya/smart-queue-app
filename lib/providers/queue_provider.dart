import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../models/service_type.dart';

class QueueProvider with ChangeNotifier {
  // Get current token being served for today
  int getCurrentServingToken(List<Appointment> allAppointments) {
    final todaysAppointments = allAppointments.where((a) => 
      (a.status == 'In Progress' || a.status == 'Completed')
    ).toList();

    if (todaysAppointments.isEmpty) return 0;

    // Find the highest queue position among In Progress or Completed
    int maxPos = 0;
    for (var a in todaysAppointments) {
      if (a.queuePosition > maxPos) {
        maxPos = a.queuePosition;
      }
    }
    return maxPos;
  }

  int estimateWaitingTime(Appointment appointment, List<Appointment> allAppointments, int currentServing) {
    if (appointment.status == 'Completed' || appointment.status == 'Cancelled') return 0;
    if (appointment.status == 'In Progress') return 0;
    
    // Find all active appointments ahead of this one
    final aheadAppointments = allAppointments.where((a) => 
      a.queuePosition < appointment.queuePosition &&
      (a.status == 'Scheduled' || a.status == 'In Progress')
    ).toList();

    int totalWaitTime = 0;
    for (var a in aheadAppointments) {
      try {
        final sType = ServiceConstants.services.firstWhere((s) => s.name == a.serviceType);
        totalWaitTime += sType.averageDurationMinutes;
      } catch (e) {
        totalWaitTime += 15; // fallback
      }
    }

    return totalWaitTime;
  }
}
