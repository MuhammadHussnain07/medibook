import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';

class DoctorService {
  final _col = FirebaseFirestore.instance.collection('doctors');

  Stream<List<DoctorModel>> getDoctors() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => DoctorModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  Future<void> addDoctor(DoctorModel doctor) async {
    await _col.add(doctor.toMap());
  }

  Future<void> updateDoctor(DoctorModel doctor) async {
    final map = doctor.toMap();
    map.remove('createdAt');
    await _col.doc(doctor.id).update(map);
  }

  Future<void> deleteDoctor(String id) async {
    await _col.doc(id).delete();
  }

  Future<void> toggleStatus(String id, bool isActive) async {
    await _col.doc(id).update({'isActive': isActive});
  }
}
