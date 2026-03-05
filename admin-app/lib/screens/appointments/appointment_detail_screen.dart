import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';

class AppointmentDetailScreen extends ConsumerWidget {
  final AppointmentModel appointment;
  const AppointmentDetailScreen({super.key, required this.appointment});

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

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    AppointmentStatus newStatus,
  ) async {
    try {
      await ref
          .read(appointmentServiceProvider)
          .updateStatus(appointment.id, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${newStatus.label}'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  void _showStatusDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Status',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            ...AppointmentStatus.values
                .where((s) => s != appointment.status)
                .map(
                  (s) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(
                        s,
                      ).withAlpha((0.12 * 255).round()),
                      child: Icon(
                        _statusIcon(s),
                        color: _statusColor(s),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      s.label,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: _statusColor(s),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _updateStatus(context, ref, s);
                    },
                  ),
                ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Detail'),
        actions: [
          TextButton.icon(
            onPressed: () => _showStatusDialog(context, ref),
            icon: const Icon(Iconsax.edit, color: AppTheme.white, size: 18),
            label: Text(
              'Status',
              style: GoogleFonts.poppins(color: AppTheme.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _statusColor(
                  appointment.status,
                ).withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _statusColor(
                    appointment.status,
                  ).withAlpha((0.3 * 255).round()),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _statusIcon(appointment.status),
                    size: 40,
                    color: _statusColor(appointment.status),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appointment.status.label,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(appointment.status),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Patient Info
            _InfoCard(
              title: 'Patient Information',
              icon: Iconsax.user,
              children: [
                _InfoRow(Iconsax.user, 'Name', appointment.patientName),
                _InfoRow(Iconsax.call, 'Phone', appointment.patientPhone),
              ],
            ),
            const SizedBox(height: 12),

            // Doctor Info
            _InfoCard(
              title: 'Doctor Information',
              icon: Iconsax.user_octagon,
              children: [
                _InfoRow(
                  Iconsax.user_octagon,
                  'Doctor',
                  appointment.doctorName,
                ),
                _InfoRow(
                  Iconsax.hospital,
                  'Specialty',
                  appointment.doctorSpecialty,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Appointment Info
            _InfoCard(
              title: 'Appointment Details',
              icon: Iconsax.calendar,
              children: [
                _InfoRow(
                  Iconsax.calendar,
                  'Date',
                  DateFormat('EEEE, MMMM d, yyyy').format(appointment.date),
                ),
                _InfoRow(Iconsax.clock, 'Time', appointment.timeSlot),
                _InfoRow(
                  Iconsax.document_text,
                  'Reason',
                  appointment.reason.isEmpty
                      ? 'Not specified'
                      : appointment.reason,
                ),
                _InfoRow(
                  Iconsax.calendar_add,
                  'Booked On',
                  DateFormat(
                    'MMM d, yyyy – h:mm a',
                  ).format(appointment.createdAt),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (appointment.status == AppointmentStatus.pending) ...[
              ElevatedButton.icon(
                onPressed: () =>
                    _updateStatus(context, ref, AppointmentStatus.confirmed),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                ),
                icon: const Icon(Iconsax.tick_circle, size: 18),
                label: const Text('Confirm Appointment'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () =>
                    _updateStatus(context, ref, AppointmentStatus.cancelled),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  side: const BorderSide(color: AppTheme.danger),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Iconsax.close_circle, size: 18),
                label: Text(
                  'Cancel Appointment',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
            if (appointment.status == AppointmentStatus.confirmed)
              ElevatedButton.icon(
                onPressed: () =>
                    _updateStatus(context, ref, AppointmentStatus.completed),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textGrey,
                ),
                icon: const Icon(Iconsax.medal_star, size: 18),
                label: const Text('Mark as Completed'),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.textGrey),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
