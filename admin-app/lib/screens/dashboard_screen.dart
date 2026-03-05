import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../providers/doctor_provider.dart';
import '../providers/appointment_provider.dart';
import '../models/appointment_model.dart';
import '../widgets/stat_card.dart';
import '../widgets/side_drawer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorsStreamProvider);
    final allAppointmentsAsync = ref.watch(appointmentsStreamProvider);
    final todayAsync = ref.watch(todayAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Iconsax.notification), onPressed: () {}),
        ],
      ),
      drawer: const SideDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textGrey,
              ),
            ),
            const SizedBox(height: 16),
            // Stat Cards
            allAppointmentsAsync.when(
              data: (appointments) {
                final pending = appointments
                    .where((a) => a.status == AppointmentStatus.pending)
                    .length;
                final confirmed = appointments
                    .where((a) => a.status == AppointmentStatus.confirmed)
                    .length;
                final todayCount = todayAsync.asData?.value.length ?? 0;
                final totalDoctors = doctorsAsync.asData?.value.length ?? 0;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    StatCard(
                      title: 'Total Doctors',
                      value: '$totalDoctors',
                      icon: Iconsax.user_octagon,
                      color: AppTheme.primary,
                    ),
                    StatCard(
                      title: "Today's Appts",
                      value: '$todayCount',
                      icon: Iconsax.calendar,
                      color: AppTheme.secondary,
                    ),
                    StatCard(
                      title: 'Pending',
                      value: '$pending',
                      icon: Iconsax.clock,
                      color: AppTheme.warning,
                    ),
                    StatCard(
                      title: 'Confirmed',
                      value: '$confirmed',
                      icon: Iconsax.tick_circle,
                      color: AppTheme.success,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),
            // Quick Actions
            Text(
              'Quick Actions',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Iconsax.user_add,
                    label: 'Add Doctor',
                    color: AppTheme.primary,
                    onTap: () => context.push('/doctors/add'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Iconsax.user_octagon,
                    label: 'All Doctors',
                    color: AppTheme.secondary,
                    onTap: () => context.push('/doctors'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Iconsax.calendar_1,
                    label: 'Appointments',
                    color: AppTheme.warning,
                    onTap: () => context.push('/appointments'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Recent Appointments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Appointments',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/appointments'),
                  child: Text(
                    'See All',
                    style: GoogleFonts.poppins(color: AppTheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            allAppointmentsAsync.when(
              data: (appointments) {
                final recent = appointments.take(5).toList();
                if (recent.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No appointments yet',
                        style: GoogleFonts.poppins(color: AppTheme.textGrey),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recent.length,
                  itemBuilder: (context, i) =>
                      _AppointmentTile(appointment: recent[i]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha((0.2 * 255).round())),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final AppointmentModel appointment;
  const _AppointmentTile({required this.appointment});

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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withAlpha((0.1 * 255).round()),
          child: const Icon(Iconsax.user, color: AppTheme.primary),
        ),
        title: Text(
          appointment.patientName,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${appointment.doctorName} • ${appointment.timeSlot}',
          style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textGrey),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(
              appointment.status,
            ).withAlpha((0.12 * 255).round()),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            appointment.status.label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: _statusColor(appointment.status),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
