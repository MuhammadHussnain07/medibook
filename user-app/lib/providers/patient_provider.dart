import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/patient_service.dart';
import '../models/patient_model.dart';
import 'auth_provider.dart';

final patientServiceProvider = Provider<PatientService>(
  (ref) => PatientService(),
);

final myProfileProvider = StreamProvider<PatientModel?>((ref) {
  final uid = ref.watch(authNotifierProvider).uid;
  if (uid.isEmpty) return const Stream.empty();
  return ref.watch(patientServiceProvider).getPatient(uid);
});
