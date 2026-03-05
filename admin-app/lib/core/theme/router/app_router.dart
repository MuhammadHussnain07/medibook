import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:medibookadmin/models/appointment_model.dart';
import 'package:medibookadmin/models/doctor_model.dart';
import 'package:medibookadmin/providers/auth_provider.dart';
import 'package:medibookadmin/screens/appointments/appointment_detail_screen.dart';
import 'package:medibookadmin/screens/appointments/appointments_list_screen.dart';
import 'package:medibookadmin/screens/dashboard_screen.dart';
import 'package:medibookadmin/screens/doctors/add_edit_doctor_screen.dart';
import 'package:medibookadmin/screens/doctors/doctor_detail_screen.dart';
import 'package:medibookadmin/screens/doctors/doctors_list_screen.dart';
import 'package:medibookadmin/screens/login_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isLoggedIn = authNotifier.isLoggedIn;
      final isLoginPage = state.matchedLocation == '/login';
      if (!isLoggedIn && !isLoginPage) return '/login';
      if (isLoggedIn && isLoginPage) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/doctors',
        builder: (context, state) => const DoctorsListScreen(),
      ),
      GoRoute(
        path: '/doctors/add',
        builder: (context, state) => const AddEditDoctorScreen(),
      ),
      GoRoute(
        path: '/doctors/edit',
        builder: (context, state) {
          final doctor = state.extra as DoctorModel;
          return AddEditDoctorScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/doctors/detail',
        builder: (context, state) {
          final doctor = state.extra as DoctorModel;
          return DoctorDetailScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/appointments',
        builder: (context, state) => const AppointmentsListScreen(),
      ),
      GoRoute(
        path: '/appointments/detail',
        builder: (context, state) {
          final appointment = state.extra as AppointmentModel;
          return AppointmentDetailScreen(appointment: appointment);
        },
      ),
    ],
  );
});
