import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'appointments';

  // Add or update appointment in Firebase
  static Future<void> saveAppointment(Appointment appointment) async {
    await _firestore
        .collection(collectionName)
        .doc(appointment.id)
        .set(appointment.toMap())
        .timeout(const Duration(seconds: 3));
  }

  // Get stream of all appointments
  static Stream<List<Appointment>> getAppointmentsStream() {
    return _firestore
        .collection(collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data()))
          .toList();
    });
  }

  // Update appointment status
  static Future<void> updateAppointmentStatus(String id, String status) async {
    await _firestore.collection(collectionName).doc(id).update({'status': status}).timeout(const Duration(seconds: 3));
  }

  // Delete appointment
  static Future<void> deleteAppointment(String id) async {
    await _firestore.collection(collectionName).doc(id).delete().timeout(const Duration(seconds: 3));
  }
}
