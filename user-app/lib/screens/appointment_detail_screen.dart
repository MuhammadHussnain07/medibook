import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../models/appointment_model.dart';

class AppointmentDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _statusColor(appointment.status).withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _statusColor(appointment.status).withAlpha(76),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _statusIcon(appointment.status),
                    size: 48,
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
                  if (appointment.status == AppointmentStatus.pending)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Waiting for clinic confirmation',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Doctor Card
            _InfoSection(
              title: 'Doctor',
              icon: Iconsax.user_octagon,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: appointment.doctorImageUrl,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        appointment.doctorSpecialty,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Appointment Info
            _InfoSection(
              title: 'Appointment Details',
              icon: Iconsax.calendar,
              child: Column(
                children: [
                  _Row(
                    Iconsax.calendar,
                    'Date',
                    DateFormat('EEEE, MMMM d, yyyy').format(appointment.date),
                  ),
                  const SizedBox(height: 10),
                  _Row(Iconsax.clock, 'Time', appointment.timeSlot),
                  const SizedBox(height: 10),
                  _Row(
                    Iconsax.document_text,
                    'Reason',
                    appointment.reason.isEmpty
                        ? 'Not specified'
                        : appointment.reason,
                  ),
                  const SizedBox(height: 10),
                  _Row(
                    Iconsax.calendar_add,
                    'Booked on',
                    DateFormat(
                      'MMM d, yyyy – hh:mm a',
                    ).format(appointment.createdAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.child,
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
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primary),
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
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.textGrey),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textGrey),
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
    );
  }
}
