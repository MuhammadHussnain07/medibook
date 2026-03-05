import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';

class MyAppointmentsScreen extends HookConsumerWidget {
  const MyAppointmentsScreen({super.key});

  Color _statusColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:
        return AppTheme.warning;
      case AppointmentStatus.confirmed:
        return AppTheme.success;
      case AppointmentStatus.cancelled:
        return AppTheme.danger;
      case AppointmentStatus.completed:
        return AppTheme.textGrey;
    }
  }

  IconData _statusIcon(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:
        return Iconsax.clock;
      case AppointmentStatus.confirmed:
        return Iconsax.tick_circle;
      case AppointmentStatus.cancelled:
        return Iconsax.close_circle;
      case AppointmentStatus.completed:
        return Iconsax.medal_star;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(myAppointmentsProvider);
    final selectedFilter = useState<AppointmentStatus?>(null);

    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: Column(
        children: [
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _Chip(
                    label: 'All',
                    isSelected: selectedFilter.value == null,
                    color: AppTheme.primary,
                    onTap: () => selectedFilter.value = null,
                  ),
                  const SizedBox(width: 8),
                  ...AppointmentStatus.values.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _Chip(
                        label: s.label,
                        isSelected: selectedFilter.value == s,
                        color: _statusColor(s),
                        onTap: () => selectedFilter.value =
                            selectedFilter.value == s ? null : s,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: appointmentsAsync.when(
              data: (appointments) {
                final filtered = selectedFilter.value == null
                    ? appointments
                    : appointments
                          .where((a) => a.status == selectedFilter.value)
                          .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Iconsax.calendar_remove,
                          size: 64,
                          color: AppTheme.textGrey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No appointments yet',
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
                  itemBuilder: (_, i) {
                    final apt = filtered[i];
                    return GestureDetector(
                      onTap: () =>
                          context.push('/appointment-detail', extra: apt),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: apt.doctorImageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  width: 60,
                                  height: 60,
                                  color: AppTheme.accent,
                                  child: const Icon(
                                    Iconsax.user,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                errorWidget: (_, _, _) => Container(
                                  width: 60,
                                  height: 60,
                                  color: AppTheme.accent,
                                  child: const Icon(
                                    Iconsax.user,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    apt.doctorName,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  Text(
                                    apt.doctorSpecialty,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Iconsax.calendar,
                                        size: 13,
                                        color: AppTheme.textGrey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat(
                                          'MMM d, yyyy',
                                        ).format(apt.date),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppTheme.textGrey,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Iconsax.clock,
                                        size: 13,
                                        color: AppTheme.textGrey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        apt.timeSlot,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppTheme.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(
                                      apt.status,
                                    ).withAlpha(26),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _statusIcon(apt.status),
                                        size: 12,
                                        color: _statusColor(apt.status),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        apt.status.label,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: _statusColor(apt.status),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Icon(
                                  Iconsax.arrow_right_3,
                                  size: 16,
                                  color: AppTheme.textGrey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : color.withAlpha(51)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.white : color,
          ),
        ),
      ),
    );
  }
}
