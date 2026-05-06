import 'package:hive_flutter/hive_flutter.dart';
import '../models/appointment.dart';

class HiveService {
  static const String boxName = 'appointmentsBox';
  static Box? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(boxName);
  }

  // Save or update an appointment
  static Future<void> saveAppointment(Appointment appointment) async {
    if (_box == null) await init();
    await _box!.put(appointment.id, appointment.toMap());
  }

  // Get all appointments
  static Future<List<Appointment>> getAppointments() async {
    if (_box == null) await init();
    final List<Appointment> appointments = [];
    for (var key in _box!.keys) {
      final map = Map<String, dynamic>.from(_box!.get(key));
      appointments.add(Appointment.fromMap(map));
    }
    // Sort by created date descending
    appointments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return appointments;
  }

  // Get unsynced appointments
  static Future<List<Appointment>> getUnsyncedAppointments() async {
    final all = await getAppointments();
    return all.where((element) => !element.isSynced).toList();
  }

  // Mark appointment as synced
  static Future<void> markAsSynced(String id) async {
    if (_box == null) await init();
    final data = _box!.get(id);
    if (data != null) {
      final map = Map<String, dynamic>.from(data);
      map['isSynced'] = true;
      await _box!.put(id, map);
    }
  }

  // Delete appointment
  static Future<void> deleteAppointment(String id) async {
    if (_box == null) await init();
    await _box!.delete(id);
  }
}
