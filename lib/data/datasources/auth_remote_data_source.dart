import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Session? get currentSession;
  Stream<AuthState> get authStateChanges;
  Future<AuthResponse> signUp(
      {required String name, required String email, required String password});
  Future<AuthResponse> signIn(
      {required String email, required String password});
  Future<void> signOut();
  User? get currentUser;
  Future<void> resendVerificationEmail(String email);
  Future<void> resetPasswordForEmail(String email, String redirectTo);
  Future<void> updateUserPassword(String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSourceImpl(this._supabaseClient);

  @override
  Session? get currentSession => _supabaseClient.auth.currentSession;

  @override
  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;

  @override
  Future<AuthResponse> signUp(
      {required String name,
      required String email,
      required String password}) async {
    return await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
  }

  @override
  Future<AuthResponse> signIn(
      {required String email, required String password}) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  User? get currentUser => _supabaseClient.auth.currentUser;

  @override
  Future<void> resendVerificationEmail(String email) async {
    await _supabaseClient.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  @override
  Future<void> resetPasswordForEmail(String email, String redirectTo) async {
    await _supabaseClient.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo,
    );
  }

  @override
  Future<void> updateUserPassword(String newPassword) async {
    await _supabaseClient.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
