import 'package:startup_application/data/datasources/auth_remote_data_source.dart';
import 'package:startup_application/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Stream<AuthState> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  Future<AuthResponse> signUp(
      {required String name, required String email, required String password}) {
    return _remoteDataSource.signUp(name: name,email: email, password: password);
  }

  @override
  Future<AuthResponse> signIn(
      {required String email, required String password}) {
    return _remoteDataSource.signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }

  @override
  User? get currentUser => _remoteDataSource.currentUser;

  @override
  Session? get currentSession => _remoteDataSource.currentSession;

  @override
  Future<void> resendVerificationEmail(String email) {
    return _remoteDataSource.resendVerificationEmail(email);
  }

  @override
  Future<void> resetPasswordForEmail(String email, String redirectTo) {
    return _remoteDataSource.resetPasswordForEmail(email, redirectTo);
  }

  @override
  Future<void> updateUserPassword(String newPassword) {
    return _remoteDataSource.updateUserPassword(newPassword);
  }
}
