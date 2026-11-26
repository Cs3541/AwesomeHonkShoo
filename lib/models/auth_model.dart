import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './account_info.dart';

// password is hello!


class AuthModel{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  Future<String?> signUp(String email, String password, AccountInfo info) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) return 'Failed to retrieve UID.';

      await _firestore.collection('users').doc(uid).set({
        'email': email,
        ...info.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

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

  Future<AccountInfo?> getAccountInfo() async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return null;

  final doc = await _firestore.collection('users').doc(uid).get();
  if (!doc.exists || doc.data() == null) return null;

  return AccountInfo.fromMap(doc.data()!);
}

}
