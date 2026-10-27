import 'package:firebase_auth/firebase_auth.dart';
// password is hello!

class AuthModel{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } catch (e) {
      return e.toString();
      }
    }

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } catch (e) {
      return e.toString();
      }
    }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<String?> resetPassword(String email) async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
    return null;
    } catch (e) {
    return e.toString();
    }
  }
}