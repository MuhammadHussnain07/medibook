import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme/app_theme.dart';
import '../providers/doctor_provider.dart';
import '../widgets/doctor_card.dart';
import '../widgets/shimmer_doctor_list.dart';

class DoctorsListScreen extends HookConsumerWidget {
  const DoctorsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(activeDoctorsProvider);
    final selectedSpecialty = useState('All');

    const specialties = [
      'All',
      'General Medicine',
      'Cardiology',
      'Dermatology',
      'Pediatrics',
      'Orthopedics',
      'Neurology',
      'Gynecology',
      'Dentistry',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('All Doctors')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: specialties.length,
              itemBuilder: (_, i) {
                final s = specialties[i];
                final isSelected = selectedSpecialty.value == s;
                return GestureDetector(
                  onTap: () => selectedSpecialty.value = s,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : AppTheme.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        s,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isSelected
                              ? AppTheme.white
                              : AppTheme.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: doctorsAsync.when(
              data: (doctors) {
                final filtered = selectedSpecialty.value == 'All'
                    ? doctors
                    : doctors
                          .where((d) => d.specialty == selectedSpecialty.value)
                          .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Iconsax.user_octagon,
                          size: 64,
                          color: AppTheme.textGrey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No doctors found',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textGrey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => DoctorCard(
                    doctor: filtered[i],
                    onTap: () =>
                        context.push('/doctor-detail', extra: filtered[i]),
                  ),
                );
              },
              loading: () => const ShimmerDoctorList(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
