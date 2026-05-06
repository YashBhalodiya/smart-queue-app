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

  // Estimate waiting time in minutes
  int estimateWaitingTime(Appointment appointment, List<Appointment> allAppointments, int currentServing) {
    if (appointment.status == 'Completed' || appointment.status == 'Cancelled') return 0;
    if (appointment.status == 'In Progress') return 0;
    
    int peopleAhead = appointment.queuePosition - currentServing - 1;
    if (peopleAhead < 0) peopleAhead = 0;

    // Find service average duration
    int avgDuration = 15; // default
    try {
      final sType = ServiceConstants.services.firstWhere((s) => s.name == appointment.serviceType);
      avgDuration = sType.averageDurationMinutes;
    } catch (e) {
      avgDuration = 15;
    }

    return peopleAhead * avgDuration;
  }
}
