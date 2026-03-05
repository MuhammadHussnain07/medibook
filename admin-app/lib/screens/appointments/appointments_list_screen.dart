import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/side_drawer.dart';

class AppointmentsListScreen extends HookConsumerWidget {
  const AppointmentsListScreen({super.key});

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
    final appointmentsAsync = ref.watch(appointmentsStreamProvider);
    final selectedFilter = useState<AppointmentStatus?>(null);

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      drawer: const SideDrawer(),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: selectedFilter.value == null,
                    color: AppTheme.primary,
                    onTap: () => selectedFilter.value = null,
                  ),
                  const SizedBox(width: 8),
                  ...AppointmentStatus.values.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
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

          // List
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
                          'No appointments found',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final apt = filtered[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () =>
                            context.push('/appointments/detail', extra: apt),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppTheme.primary.withAlpha(
                                      (0.1 * 255).round(),
                                    ),
                                    child: const Icon(
                                      Iconsax.user,
                                      color: AppTheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          apt.patientName,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        Text(
                                          apt.patientPhone,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppTheme.textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(
                                        apt.status,
                                      ).withAlpha((0.12 * 255).round()),
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
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Iconsax.user_octagon,
                                    size: 14,
                                    color: AppTheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    apt.doctorName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '• ${apt.doctorSpecialty}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Iconsax.calendar,
                                    size: 14,
                                    color: AppTheme.textGrey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat(
                                      'EEE, MMM d, yyyy',
                                    ).format(apt.date),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Iconsax.clock,
                                    size: 14,
                                    color: AppTheme.textGrey,
                                  ),
                                  const SizedBox(width: 6),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha((0.08 * 255).round()),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withAlpha((0.2 * 255).round()),
          ),
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
