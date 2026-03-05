import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final _col = FirebaseFirestore.instance.collection('appointments');

  Stream<List<AppointmentModel>> getMyAppointments(String patientId) {
    return _col.where('patientId', isEqualTo: patientId).snapshots().map((s) {
      final appointments = s.docs
          .map((d) => AppointmentModel.fromMap(d.data(), d.id))
          .toList();
      appointments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return appointments;
    });
  }

  Future<void> bookAppointment(AppointmentModel appointment) async {
    await _col.add(appointment.toMap());
  }

  Future<List<String>> getBookedSlots(String doctorId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final snap = await _col
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .where('status', whereNotIn: ['cancelled'])
        .get();
    return snap.docs
        .map((d) => AppointmentModel.fromMap(d.data(), d.id).timeSlot)
        .toList();
  }
}
