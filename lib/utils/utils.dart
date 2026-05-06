import 'dart:math';
import 'package:intl/intl.dart';

class Utils {
  // Generate ID format: APT-2026-0001
  static String generateAppointmentId() {
    final year = DateTime.now().year;
    final randomNum = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'APT-$year-$randomNum';
  }

  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format time (if needed)
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }
}
