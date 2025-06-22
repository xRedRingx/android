enum UserRole { customer, barber }

class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final String? bio;
  final List<String>? specialties;
  final Map<String, dynamic>? schedule;
  final String? fcmToken; // Added fcmToken

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.bio,
    this.specialties,
    this.schedule,
    this.fcmToken, // Added to constructor
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values[map['role'] ?? 0],
      bio: map['bio'],
      specialties: List<String>.from(map['specialties'] ?? []),
      schedule: map['schedule'] != null ? Map<String, dynamic>.from(map['schedule']) : null,
      fcmToken: map['fcmToken'], // Handle fcmToken
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.index,
      'bio': bio,
      'specialties': specialties,
      'schedule': schedule,
      'fcmToken': fcmToken, // Add to map
    };
  }
}
