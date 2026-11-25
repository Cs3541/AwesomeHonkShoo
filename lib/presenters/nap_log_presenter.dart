import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NapLogPresenter {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime? _napStart;

  DateTime? get napStart => _napStart;

  void startNap() {
    _napStart = DateTime.now();
  }

  Future<void> endNap({
    String notes = '',
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    if (_napStart == null) {
      throw Exception('No active nap session');
    }

    final end = DateTime.now();

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('napLogs')
        .add({
          'start': Timestamp.fromDate(_napStart!),
          'end': Timestamp.fromDate(end),
        });

    _napStart = null;
  }
}