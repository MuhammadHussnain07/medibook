import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';

class DoctorService {
  final _col = FirebaseFirestore.instance.collection('doctors');

  Stream<List<DoctorModel>> getActiveDoctors() {
    return _col
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => DoctorModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  Future<DoctorModel?> getDoctorById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return DoctorModel.fromMap(doc.data()!, doc.id);
  }

  Stream<List<DoctorModel>> searchDoctors(String query) {
    return _col
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => DoctorModel.fromMap(d.data(), d.id))
              .where(
                (doc) =>
                    doc.name.toLowerCase().contains(query.toLowerCase()) ||
                    doc.specialty.toLowerCase().contains(query.toLowerCase()),
              )
              .toList(),
        );
  }
}
