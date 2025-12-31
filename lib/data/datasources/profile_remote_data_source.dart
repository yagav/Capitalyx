import 'package:startup_application/core/utils/app_constants.dart';
import 'package:startup_application/data/models/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel?> getProfile(String userId);
  Future<void> updateProfile(UserProfileModel profile);
  Future<void> createProfile(UserProfileModel profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _supabaseClient;

  ProfileRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<UserProfileModel?> getProfile(String userId) async {
    try {
      final response = await _supabaseClient
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfileModel.fromJson(response);
    } catch (e) {
      // In a real app, handle error properly or rethrow custom exception
      rethrow;
    }
  }

  @override
  Future<void> createProfile(UserProfileModel profile) async {
    await _supabaseClient
        .from(AppConstants.profilesTable)
        .insert(profile.toJson());
  }

  @override
  Future<void> updateProfile(UserProfileModel profile) async {
    await _supabaseClient
        .from(AppConstants.profilesTable)
        .update(profile.toJson())
        .eq('id', profile.id);
  }
}
