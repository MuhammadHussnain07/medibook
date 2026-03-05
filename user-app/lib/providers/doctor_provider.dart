import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import '../services/doctor_service.dart';
import '../models/doctor_model.dart';

final doctorServiceProvider = Provider<DoctorService>((ref) => DoctorService());

final activeDoctorsProvider = StreamProvider<List<DoctorModel>>((ref) {
  return ref.watch(doctorServiceProvider).getActiveDoctors();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchDoctorsProvider = StreamProvider<List<DoctorModel>>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return const Stream.empty();
  return ref.watch(doctorServiceProvider).searchDoctors(query);
});
