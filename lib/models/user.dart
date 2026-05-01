class User {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String classLevel; // SSC, HSC, Admission
  final int pointsBalance;
  final bool isVerified;
  final DateTime createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.classLevel,
    this.pointsBalance = 0,
    this.isVerified = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      classLevel: json['class_level'] as String,
      pointsBalance: json['points_balance'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'class_level': classLevel,
      'points_balance': pointsBalance,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? fullName,
    String? classLevel,
    int? pointsBalance,
  }) {
    return User(
      id: id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber,
      classLevel: classLevel ?? this.classLevel,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      isVerified: isVerified,
      createdAt: createdAt,
    );
  }
}
