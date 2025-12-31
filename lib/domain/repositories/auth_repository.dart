import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Stream<AuthState> get authStateChanges;
  Future<AuthResponse> signUp(
      {required String name, required String email, required String password});
  Future<AuthResponse> signIn(
      {required String email, required String password});
  Future<void> signOut();
  User? get currentUser;
  Session? get currentSession;
  Future<void> resendVerificationEmail(String email);
  Future<void> resetPasswordForEmail(String email, String redirectTo);
  Future<void> updateUserPassword(String newPassword);
}
