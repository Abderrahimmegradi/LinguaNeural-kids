import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  const AuthService();

  User? get currentUser => FirebaseAuth.instance.currentUser;

  Stream<User?> authStateChanges() {
    return FirebaseAuth.instance.authStateChanges();
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return FirebaseAuth.instance.signOut();
  }
}