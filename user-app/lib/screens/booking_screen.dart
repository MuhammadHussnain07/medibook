import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../core/theme/app_theme.dart';
import '../models/appointment_model.dart';
import '../models/doctor_model.dart';
import '../providers/auth_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/patient_provider.dart';

class BookingScreen extends HookConsumerWidget {
  final DoctorModel doctor;
  const BookingScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = useState<DateTime?>(null);
    final selectedSlot = useState<String?>(null);
    final reasonCtrl = useTextEditingController();
    final isLoading = useState(false);
    final bookedSlots = useState<List<String>>([]);
    final focusedDay = useState(DateTime.now());

    Future<void> loadBookedSlots(DateTime day) async {
      try {
        final slots = await ref
            .read(appointmentServiceProvider)
            .getBookedSlots(doctor.id, day);
        bookedSlots.value = slots;
      } catch (_) {
        bookedSlots.value = [];
      }
    }

    Future<void> book() async {
      if (selectedDay.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date'),
            backgroundColor: AppTheme.warning,
          ),
        );
        return;
      }
      if (selectedSlot.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a time slot'),
            backgroundColor: AppTheme.warning,
          ),
        );
        return;
      }

      isLoading.value = true;
      try {
        final uid = ref.read(authNotifierProvider).uid;
        final profile = ref.read(myProfileProvider).asData?.value;

        final appointment = AppointmentModel(
          id: '',
          patientId: uid,
          patientName: profile?.name ?? 'Patient',
          patientPhone: profile?.phone ?? '',
          doctorId: doctor.id,
          doctorName: doctor.name,
          doctorSpecialty: doctor.specialty,
          doctorImageUrl: doctor.imageUrl,
          date: selectedDay.value!,
          timeSlot: selectedSlot.value!,
          status: AppointmentStatus.pending,
          reason: reasonCtrl.text.trim(),
          createdAt: DateTime.now(),
        );

        await ref.read(appointmentServiceProvider).bookAppointment(appointment);

        if (context.mounted) {
          context.go('/booking-success');
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
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Mini Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.accent,
                    child: Icon(Iconsax.user_octagon, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        doctor.specialty,
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
            const SizedBox(height: 20),

            // Calendar
            Text(
              'Select Date',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 60)),
                focusedDay: focusedDay.value,
                selectedDayPredicate: (day) =>
                    isSameDay(selectedDay.value, day),
                calendarFormat: CalendarFormat.month,
                enabledDayPredicate: (day) {
                  final dayName = DateFormat('EEEE').format(day);
                  return doctor.availableDays.contains(dayName);
                },
                onDaySelected: (selected, focused) {
                  selectedDay.value = selected;
                  focusedDay.value = focused;
                  selectedSlot.value = null;
                  loadBookedSlots(selected);
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppTheme.secondary.withAlpha(102),
                    shape: BoxShape.circle,
                  ),
                  disabledTextStyle: const TextStyle(color: Color(0xFFCBCBCB)),
                  defaultTextStyle: GoogleFonts.poppins(fontSize: 13),
                  selectedTextStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Time Slots
            if (selectedDay.value != null) ...[
              Text(
                'Select Time Slot',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: doctor.timeSlots.map((slot) {
                  final isBooked = bookedSlots.value.contains(slot);
                  final isSelected = selectedSlot.value == slot;
                  return GestureDetector(
                    onTap: isBooked ? null : () => selectedSlot.value = slot,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isBooked
                            ? const Color(0xFFF3F4F6)
                            : isSelected
                            ? AppTheme.primary
                            : AppTheme.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isBooked
                              ? const Color(0xFFE5E7EB)
                              : isSelected
                              ? AppTheme.primary
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.clock,
                            size: 14,
                            color: isBooked
                                ? AppTheme.textGrey
                                : isSelected
                                ? AppTheme.white
                                : AppTheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            slot,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isBooked
                                  ? AppTheme.textGrey
                                  : isSelected
                                  ? AppTheme.white
                                  : AppTheme.textDark,
                            ),
                          ),
                          if (isBooked) ...[
                            const SizedBox(width: 4),
                            Text(
                              'Full',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppTheme.textGrey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Reason
            Text(
              'Reason for Visit (Optional)',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe your symptoms or reason...',
                hintStyle: GoogleFonts.poppins(color: AppTheme.textGrey),
                filled: true,
                fillColor: AppTheme.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading.value ? null : book,
              child: isLoading.value
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: AppTheme.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('Confirm Booking'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
