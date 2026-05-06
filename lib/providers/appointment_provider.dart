import 'package:flutter/material.dart';
import 'dart:async';
import '../models/appointment.dart';
import '../services/hive_service.dart';
import '../services/firebase_service.dart';
import '../utils/utils.dart';

class AppointmentProvider with ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  bool _isOffline = false;
  StreamSubscription? _firebaseSubscription;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;

  // Initialize and load data
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    // Check connection (Simulated for this project, ideally use connectivity_plus)
    _isOffline = false; 

    // First load from local storage
    _appointments = await HiveService.getAppointments();
    
    // Attempt to sync offline records
    await syncOfflineData();

    // Setup Firebase Stream if online
    if (!_isOffline) {
      _firebaseSubscription = FirebaseService.getAppointmentsStream().listen(
        (firebaseAppointments) async {
          _appointments = firebaseAppointments;
          
          // Save to local for offline use
          for (var appt in firebaseAppointments) {
            await HiveService.saveAppointment(appt.copyWith(isSynced: true));
          }
          
          notifyListeners();
        },
        onError: (e) {
          _isOffline = true;
          notifyListeners();
        }
      );
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Add new appointment
  Future<bool> bookAppointment(String name, String serviceType, DateTime date, String timeSlot) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check for conflicts
      bool isConflict = _appointments.any((a) => 
        a.date.year == date.year && 
        a.date.month == date.month && 
        a.date.day == date.day && 
        a.timeSlot == timeSlot && 
        a.status != 'Cancelled'
      );

      if (isConflict) {
        _isLoading = false;
        notifyListeners();
        return false; // Conflict detected
      }

      // Calculate queue position
      int queuePos = _appointments.where((a) => 
        a.date.year == date.year && 
        a.date.month == date.month && 
        a.date.day == date.day &&
        a.status != 'Cancelled'
      ).length + 1;

      // Create object
      final newAppt = Appointment(
        id: Utils.generateAppointmentId(),
        name: name,
        serviceType: serviceType,
        date: date,
        timeSlot: timeSlot,
        status: 'Scheduled',
        queuePosition: queuePos,
        isSynced: false,
        createdAt: DateTime.now(),
      );

      // Save locally first (offline-first approach)
      await HiveService.saveAppointment(newAppt);
      
      // Try saving to Firebase
      try {
        await FirebaseService.saveAppointment(newAppt.copyWith(isSynced: true));
        await HiveService.markAsSynced(newAppt.id);
      } catch (e) {
        // Will be synced later when online
        _isOffline = true;
      }

      // Add to local list if stream hasn't caught it yet
      if (!_appointments.any((a) => a.id == newAppt.id)) {
        _appointments.insert(0, newAppt);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update Status
  Future<void> updateStatus(String id, String newStatus) async {
    // Update locally
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index >= 0) {
      final updated = _appointments[index].copyWith(status: newStatus, isSynced: false);
      _appointments[index] = updated;
      await HiveService.saveAppointment(updated);
      notifyListeners();

      // Update Firebase
      try {
        await FirebaseService.updateAppointmentStatus(id, newStatus);
        await HiveService.markAsSynced(id);
      } catch (e) {
        _isOffline = true;
        notifyListeners();
      }
    }
  }

  // Reschedule Appointment
  Future<bool> rescheduleAppointment(String id, DateTime newDate, String newTimeSlot) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check for conflicts
      bool isConflict = _appointments.any((a) => 
        a.id != id &&
        a.date.year == newDate.year && 
        a.date.month == newDate.month && 
        a.date.day == newDate.day && 
        a.timeSlot == newTimeSlot && 
        a.status != 'Cancelled'
      );

      if (isConflict) {
        _isLoading = false;
        notifyListeners();
        return false; // Conflict detected
      }

      final index = _appointments.indexWhere((a) => a.id == id);
      if (index >= 0) {
        final updated = _appointments[index].copyWith(
          date: newDate, 
          timeSlot: newTimeSlot, 
          status: 'Scheduled',
          isSynced: false
        );
        _appointments[index] = updated;
        await HiveService.saveAppointment(updated);

        // Try Firebase
        try {
          // Since it's an update, saveAppointment overwrites
          await FirebaseService.saveAppointment(updated.copyWith(isSynced: true));
          await HiveService.markAsSynced(updated.id);
        } catch (e) {
          _isOffline = true;
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cancel Appointment
  Future<void> cancelAppointment(String id) async {
    await updateStatus(id, 'Cancelled');
  }

  // Sync Offline Data
  Future<void> syncOfflineData() async {
    try {
      final unsynced = await HiveService.getUnsyncedAppointments();
      for (var appt in unsynced) {
        await FirebaseService.saveAppointment(appt.copyWith(isSynced: true));
        await HiveService.markAsSynced(appt.id);
      }
      _isOffline = false;
      notifyListeners();
    } catch (e) {
      _isOffline = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _firebaseSubscription?.cancel();
    super.dispose();
  }
}
