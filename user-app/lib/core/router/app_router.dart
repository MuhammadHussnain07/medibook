import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:medibook/models/appointment_model.dart';
import 'package:medibook/models/doctor_model.dart';
import 'package:medibook/providers/auth_provider.dart';
import 'package:medibook/screens/appointment_detail_screen.dart';
import 'package:medibook/screens/booking_screen.dart';
import 'package:medibook/screens/booking_success_screen.dart';
import 'package:medibook/screens/doctor_detail_screen.dart';
import 'package:medibook/screens/doctors_list_screen.dart';
import 'package:medibook/screens/home_screen.dart';
import 'package:medibook/screens/login_screen.dart';
import 'package:medibook/screens/my_appointments_screen.dart';
import 'package:medibook/screens/onboarding_screen.dart';
import 'package:medibook/screens/profile_screen.dart';
import 'package:medibook/screens/register_screen.dart';
import 'package:medibook/screens/search_screen.dart';
import 'package:medibook/screens/splash_screen.dart';
import 'package:medibook/widgets/bottom_nav_bar.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isLoggedIn = authNotifier.isLoggedIn;
      final loc = state.matchedLocation;
      final publicRoutes = ['/splash', '/onboarding', '/login', '/register'];
      if (!isLoggedIn && !publicRoutes.contains(loc)) return '/login';
      if (isLoggedIn && (loc == '/login' || loc == '/register')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) =>
            MainShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          GoRoute(
            path: '/doctors',
            builder: (_, _) => const DoctorsListScreen(),
          ),
          GoRoute(
            path: '/appointments',
            builder: (_, _) => const MyAppointmentsScreen(),
          ),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/doctor-detail',
        builder: (_, state) {
          final doctor = state.extra as DoctorModel;
          return DoctorDetailScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/booking',
        builder: (_, state) {
          final doctor = state.extra as DoctorModel;
          return BookingScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/booking-success',
        builder: (_, _) => const BookingSuccessScreen(),
      ),
      GoRoute(
        path: '/appointment-detail',
        builder: (_, state) {
          final apt = state.extra as AppointmentModel;
          return AppointmentDetailScreen(appointment: apt);
        },
      ),
      GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
    ],
  );
});
