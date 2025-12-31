import 'package:startup_application/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.startupName,
    required super.startupSector,
    required super.founderDetails,
    required super.isOnboarded,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      startupName: json['startup_name'] as String? ?? '',
      startupSector: json['startup_sector'] as String? ?? '',
      founderDetails: json['founder_details'] as String? ?? '',
      isOnboarded: json['is_onboarded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'startup_name': startupName,
      'startup_sector': startupSector,
      'founder_details': founderDetails,
      'is_onboarded': isOnboarded,
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? email,
    String? startupName,
    String? startupSector,
    String? founderDetails,
    bool? isOnboarded,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      startupName: startupName ?? this.startupName,
      startupSector: startupSector ?? this.startupSector,
      founderDetails: founderDetails ?? this.founderDetails,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }
}
