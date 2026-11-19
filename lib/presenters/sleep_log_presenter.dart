import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SleepLogPresenter {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime? _sleepStart;

  DateTime? get sleepStart => _sleepStart;

  void startSleep() {
    _sleepStart = DateTime.now();
  }

  Future<void> endSleep({
    String notes = '',
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    if (_sleepStart == null) {
      throw Exception('No active sleep session');
    }

    final end = DateTime.now();

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('sleepLogs')
        .add({
          'start': Timestamp.fromDate(_sleepStart!),
          'end': Timestamp.fromDate(end),
          'notes': notes,
        });

    _sleepStart = null;
  }
}