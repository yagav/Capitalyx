import 'package:startup_application/data/datasources/profile_remote_data_source.dart';
import 'package:startup_application/data/models/user_profile_model.dart';
import 'package:startup_application/domain/entities/user_profile.dart';
import 'package:startup_application/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserProfile?> getProfile(String userId) async {
    return await _remoteDataSource.getProfile(userId);
  }

  @override
  Future<void> createProfile(UserProfile profile) async {
    // Convert entity to model
    final model = UserProfileModel(
      id: profile.id,
      email: profile.email,
      startupName: profile.startupName,
      startupSector: profile.startupSector,
      founderDetails: profile.founderDetails,
      isOnboarded: profile.isOnboarded,
    );
    await _remoteDataSource.createProfile(model);
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final model = UserProfileModel(
      id: profile.id,
      email: profile.email,
      startupName: profile.startupName,
      startupSector: profile.startupSector,
      founderDetails: profile.founderDetails,
      isOnboarded: profile.isOnboarded,
    );
    await _remoteDataSource.updateProfile(model);
  }
}
