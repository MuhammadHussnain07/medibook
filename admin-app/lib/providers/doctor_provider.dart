import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/doctor_service.dart';
import '../models/doctor_model.dart';

final doctorServiceProvider = Provider<DoctorService>((ref) => DoctorService());

final doctorsStreamProvider = StreamProvider<List<DoctorModel>>((ref) {
  return ref.watch(doctorServiceProvider).getDoctors();
});
