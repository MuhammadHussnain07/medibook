import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/appointment_service.dart';
import '../models/appointment_model.dart';
import 'auth_provider.dart';

final appointmentServiceProvider = Provider<AppointmentService>(
  (ref) => AppointmentService(),
);

final myAppointmentsProvider = StreamProvider<List<AppointmentModel>>((ref) {
  final uid = ref.watch(authNotifierProvider).uid;
  if (uid.isEmpty) return const Stream.empty();
  return ref.watch(appointmentServiceProvider).getMyAppointments(uid);
});
