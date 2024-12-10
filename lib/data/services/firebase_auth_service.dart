import 'package:firebase_auth/firebase_auth.dart';
import 'package:thriftcorner/domain/models/user_model.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/services/auth_service.dart';

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth;
  final IUserRepository _userRepository;

  FirebaseAuthService(this._auth, this._userRepository);

  @override
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        return await _userRepository.getUserById(userCredential.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<UserModel?> signUp(String email, String password, Map<String, dynamic> userData) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final user = UserModel(
          id: userCredential.user!.uid,
          username: userData['username'],
          email: email,
          address: userData['address'],
          country: userData['country'],
          phoneNumber: userData['phoneNumber'],
          gender: userData['gender'],
          reviews: [],
          createdAt: DateTime.now(),
        );
        await _userRepository.createUser(user);
        return user;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      return user != null ? await _userRepository.getUserById(user.uid) : null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user != null) {
        // Fetch UserModel from the repository
        return await _userRepository.getUserById(user.uid);
      }
      return null;
    });
  }
}
