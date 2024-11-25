import '../models/user_model.dart';

abstract class IAuthService {
  Future<UserModel?> signIn(String email, String password);
  Future<UserModel?> signUp(String email, String password, Map<String, dynamic> userData);
  Future<UserModel?> getCurrentUser();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Stream<UserModel?> get authStateChanges;
}
