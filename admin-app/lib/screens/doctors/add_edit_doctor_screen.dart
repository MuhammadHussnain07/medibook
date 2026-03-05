import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_theme.dart';
import '../../models/doctor_model.dart';
import '../../providers/doctor_provider.dart';

class AddEditDoctorScreen extends HookConsumerWidget {
  final DoctorModel? doctor;
  const AddEditDoctorScreen({super.key, this.doctor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEdit = doctor != null;
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final isLoading = useState(false);

    final nameCtrl = useTextEditingController(text: doctor?.name ?? '');
    final imageUrlCtrl = useTextEditingController(text: doctor?.imageUrl ?? '');
    final experienceCtrl = useTextEditingController(
      text: doctor?.experience.toString() ?? '',
    );
    final ratingCtrl = useTextEditingController(
      text: doctor?.rating.toString() ?? '',
    );
    final bioCtrl = useTextEditingController(text: doctor?.bio ?? '');

    final specialty = useState(doctor?.specialty ?? 'General Medicine');
    final selectedDays = useState<List<String>>(
      List.from(
        doctor?.availableDays ??
            ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      ),
    );
    final selectedSlots = useState<List<String>>(
      List.from(doctor?.timeSlots ?? []),
    );

    const specialties = [
      'General Medicine',
      'Cardiology',
      'Dermatology',
      'Pediatrics',
      'Orthopedics',
      'Neurology',
      'Gynecology',
      'Dentistry',
      'ENT',
      'Ophthalmology',
    ];

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const slots = [
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
    ];

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;
      if (selectedDays.value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one available day'),
            backgroundColor: AppTheme.warning,
          ),
        );
        return;
      }
      if (selectedSlots.value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one time slot'),
            backgroundColor: AppTheme.warning,
          ),
        );
        return;
      }

      isLoading.value = true;
      try {
        final newDoctor = DoctorModel(
          id: doctor?.id ?? '',
          name: nameCtrl.text.trim(),
          specialty: specialty.value,
          imageUrl: imageUrlCtrl.text.trim(),
          experience: int.tryParse(experienceCtrl.text.trim()) ?? 0,
          rating: double.tryParse(ratingCtrl.text.trim()) ?? 0.0,
          bio: bioCtrl.text.trim(),
          availableDays: selectedDays.value,
          timeSlots: selectedSlots.value,
          isActive: true,
          createdAt: doctor?.createdAt ?? DateTime.now(),
        );

        if (isEdit) {
          await ref.read(doctorServiceProvider).updateDoctor(newDoctor);
        } else {
          await ref.read(doctorServiceProvider).addDoctor(newDoctor);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEdit ? 'Doctor updated!' : 'Doctor added!'),
              backgroundColor: AppTheme.success,
            ),
          );
          context.pop();
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
      appBar: AppBar(title: Text(isEdit ? 'Edit Doctor' : 'Add Doctor')),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Basic Information'),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Iconsax.user, color: AppTheme.primary),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter doctor name' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: specialty.value,
                decoration: const InputDecoration(
                  labelText: 'Specialty',
                  prefixIcon: Icon(Iconsax.hospital, color: AppTheme.primary),
                ),
                items: specialties
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) specialty.value = val;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: imageUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Photo URL (Unsplash link)',
                  prefixIcon: Icon(Iconsax.image, color: AppTheme.primary),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter image URL' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: experienceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Experience (yrs)',
                        prefixIcon: Icon(
                          Iconsax.briefcase,
                          color: AppTheme.primary,
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: ratingCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Rating (0-5)',
                        prefixIcon: Icon(Iconsax.star, color: AppTheme.primary),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final d = double.tryParse(v);
                        if (d == null || d < 0 || d > 5) return '0 to 5';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: bioCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio / Description',
                  prefixIcon: Icon(
                    Iconsax.document_text,
                    color: AppTheme.primary,
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter bio' : null,
              ),
              const SizedBox(height: 20),
              _SectionTitle('Available Days'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: days.map((day) {
                  final selected = selectedDays.value.contains(day);
                  return FilterChip(
                    label: Text(
                      day.substring(0, 3),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: selected ? AppTheme.white : AppTheme.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: selected,
                    selectedColor: AppTheme.primary,
                    checkmarkColor: AppTheme.white,
                    backgroundColor: AppTheme.white,
                    onSelected: (val) {
                      final list = List<String>.from(selectedDays.value);
                      if (val) {
                        list.add(day);
                      } else {
                        list.remove(day);
                      }
                      selectedDays.value = list;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _SectionTitle('Time Slots'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: slots.map((slot) {
                  final selected = selectedSlots.value.contains(slot);
                  return FilterChip(
                    label: Text(
                      slot,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: selected ? AppTheme.white : AppTheme.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: selected,
                    selectedColor: AppTheme.secondary,
                    checkmarkColor: AppTheme.white,
                    backgroundColor: AppTheme.white,
                    onSelected: (val) {
                      final list = List<String>.from(selectedSlots.value);
                      if (val) {
                        list.add(slot);
                      } else {
                        list.remove(slot);
                      }
                      selectedSlots.value = list;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading.value ? null : save,
                child: isLoading.value
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: AppTheme.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(isEdit ? 'Update Doctor' : 'Add Doctor'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppTheme.textDark,
      ),
    );
  }
}
