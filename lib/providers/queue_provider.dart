import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../models/service_type.dart';

class QueueProvider with ChangeNotifier {
  int getCurrentServingToken(List<Appointment> allAppointments, DateTime targetDate) {
    // 1. Find if there is an appointment "In Progress"
    final inProgressAppts = allAppointments.where((a) => 
      a.date.year == targetDate.year && 
      a.date.month == targetDate.month && 
      a.date.day == targetDate.day &&
      a.status == 'In Progress'
    ).toList();

    if (inProgressAppts.isNotEmpty) {
      // Return the token that is currently in progress
      int minPos = inProgressAppts.first.queuePosition;
      for (var a in inProgressAppts) {
        if (a.queuePosition < minPos) minPos = a.queuePosition;
      }
      return minPos;
    }

    // 2. If nothing is "In Progress", find the highest "Completed" token
    final completedAppts = allAppointments.where((a) => 
      a.date.year == targetDate.year && 
      a.date.month == targetDate.month && 
      a.date.day == targetDate.day &&
      a.status == 'Completed'
    ).toList();

    if (completedAppts.isEmpty) return 0;

    int maxPos = 0;
    for (var a in completedAppts) {
      if (a.queuePosition > maxPos) maxPos = a.queuePosition;
    }
    return maxPos;
  }

  int estimateWaitingTime(Appointment appointment, List<Appointment> allAppointments, int currentServing) {
    if (appointment.status == 'Completed' || appointment.status == 'Cancelled') return 0;
    if (appointment.status == 'In Progress') return 0;
    
    // Find all active appointments ahead of this one ON THE SAME DAY
    final aheadAppointments = allAppointments.where((a) => 
      a.date.year == appointment.date.year &&
      a.date.month == appointment.date.month &&
      a.date.day == appointment.date.day &&
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
