import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/appointment_service.dart';
import '../models/appointment_model.dart';

final appointmentServiceProvider = Provider<AppointmentService>(
  (ref) => AppointmentService(),
);

final appointmentsStreamProvider = StreamProvider<List<AppointmentModel>>((
  ref,
) {
  return ref.watch(appointmentServiceProvider).getAllAppointments();
});

final todayAppointmentsProvider = StreamProvider<List<AppointmentModel>>((ref) {
  return ref.watch(appointmentServiceProvider).getTodayAppointments();
});
