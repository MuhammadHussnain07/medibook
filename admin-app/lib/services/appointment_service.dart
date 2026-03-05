import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final _col = FirebaseFirestore.instance.collection('appointments');

  Stream<List<AppointmentModel>> getAllAppointments() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => AppointmentModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  Stream<List<AppointmentModel>> getTodayAppointments() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return _col
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => AppointmentModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  Future<void> updateStatus(String id, AppointmentStatus status) async {
    await _col.doc(id).update({'status': status.name});
  }
}
