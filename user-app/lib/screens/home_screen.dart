import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme/app_theme.dart';
import '../providers/doctor_provider.dart';
import '../providers/patient_provider.dart';
import '../widgets/doctor_card.dart';
import '../widgets/shimmer_doctor_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _specialties = [
    {'label': 'All', 'icon': Iconsax.category},
    {'label': 'Cardiology', 'icon': Iconsax.heart},
    {'label': 'Dermatology', 'icon': Iconsax.sun_1},
    {'label': 'Pediatrics', 'icon': Iconsax.people},
    {'label': 'Orthopedics', 'icon': Iconsax.activity},
    {'label': 'Neurology', 'icon': Iconsax.cpu},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final doctorsAsync = ref.watch(activeDoctorsProvider);

    final greeting = _getGreeting();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppTheme.white.withAlpha(204),
                                ),
                              ),
                              profileAsync.when(
                                data: (patient) => Text(
                                  patient?.name ?? 'Patient',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.white,
                                  ),
                                ),
                                loading: () => Text(
                                  'Loading...',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    color: AppTheme.white,
                                  ),
                                ),
                                error: (_, _) => Text(
                                  'Patient',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    color: AppTheme.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/profile'),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: AppTheme.white.withAlpha(51),
                            child: const Icon(
                              Iconsax.user,
                              color: AppTheme.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                    GestureDetector(
                      onTap: () => context.push('/search'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.search_normal,
                              color: AppTheme.textGrey,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Search doctors, specialties...',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppTheme.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Book Your Appointment',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.white,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Find the best doctors near you',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.white.withAlpha(217),
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => context.go('/doctors'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Find Now',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Iconsax.hospital,
                        size: 80,
                        color: Colors.white24,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Specialties
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Specialties',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _specialties.length,
                  itemBuilder: (_, i) {
                    final spec = _specialties[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _SpecialtyItem(
                        label: spec['label'] as String,
                        icon: spec['icon'] as IconData,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Doctors
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Doctors',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/doctors'),
                      child: Text(
                        'See All',
                        style: GoogleFonts.poppins(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: doctorsAsync.when(
                  data: (doctors) {
                    if (doctors.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No doctors available yet',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ),
                      );
                    }
                    final preview = doctors.take(4).toList();
                    return Column(
                      children: preview
                          .map(
                            (d) => DoctorCard(
                              doctor: d,
                              onTap: () =>
                                  context.push('/doctor-detail', extra: d),
                            ),
                          )
                          .toList(),
                    );
                  },
                  loading: () => const ShimmerDoctorList(),
                  error: (e, _) => Text('Error: $e'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}

class _SpecialtyItem extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SpecialtyItem({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppTheme.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
