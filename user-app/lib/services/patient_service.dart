import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';

class PatientService {
  final _col = FirebaseFirestore.instance.collection('patients');

  Stream<PatientModel?> getPatient(String id) {
    return _col.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return PatientModel.fromMap(doc.data()!, doc.id);
    });
  }

  Future<void> updatePatient(String id, String name, String phone) async {
    await _col.doc(id).update({'name': name, 'phone': phone});
  }
}
