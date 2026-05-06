import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Smart Queue App';
  
  // Status Colors
  static const Color statusScheduled = Colors.blue;
  static const Color statusInProgress = Colors.orange;
  static const Color statusCompleted = Colors.green;
  static const Color statusCancelled = Colors.red;

  static const List<String> timeSlots = [
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '01:00 PM - 02:00 PM',
    '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM',
    '04:00 PM - 05:00 PM',
  ];
}
