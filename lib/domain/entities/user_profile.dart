import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String startupName;
  final String startupSector;
  final String founderDetails;
  final bool isOnboarded;

  const UserProfile({
    required this.id,
    required this.email,
    required this.startupName,
    required this.startupSector,
    required this.founderDetails,
    required this.isOnboarded,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        startupName,
        startupSector,
        founderDetails,
        isOnboarded,
      ];
}
