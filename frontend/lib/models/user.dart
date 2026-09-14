enum UserRole { artisan, buyer, admin }

class User {
  final int id;
  final String email;
  final String fullName;
  final String? phone;
  final UserRole role;
  final bool isActive;
  final int? artisanProfileId;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    this.isActive = true,
    this.artisanProfileId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    UserRole parsedRole = UserRole.buyer;
    final roleStr = (json['role'] as String?)?.toLowerCase() ?? 'buyer';
    if (roleStr == 'artisan') {
      parsedRole = UserRole.artisan;
    } else if (roleStr == 'admin') {
      parsedRole = UserRole.admin;
    }

    return User(
      id: json['id'] ?? json['user_id'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? 'Artisan Connect User',
      phone: json['phone'],
      role: parsedRole,
      isActive: json['is_active'] ?? true,
      artisanProfileId: json['artisan_profile_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role.name,
      'is_active': isActive,
      'artisan_profile_id': artisanProfileId,
    };
  }
}
