import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final String imageUrl;
  final int experience;
  final double rating;
  final String bio;
  final List<String> availableDays;
  final List<String> timeSlots;
  final bool isActive;
  final DateTime createdAt;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.experience,
    required this.rating,
    required this.bio,
    required this.availableDays,
    required this.timeSlots,
    required this.isActive,
    required this.createdAt,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> map, String id) {
    return DoctorModel(
      id: id,
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      experience: (map['experience'] ?? 0) as int,
      rating: (map['rating'] ?? 0.0).toDouble(),
      bio: map['bio'] ?? '',
      availableDays: List<String>.from(map['availableDays'] ?? []),
      timeSlots: List<String>.from(map['timeSlots'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialty': specialty,
      'imageUrl': imageUrl,
      'experience': experience,
      'rating': rating,
      'bio': bio,
      'availableDays': availableDays,
      'timeSlots': timeSlots,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
