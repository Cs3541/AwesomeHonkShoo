import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SleepLogPresenter {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime? _sleepStart;

  DocumentReference<Map<String, dynamic>>? _activeSleepRef;

  Future<void> startSleep() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    _sleepStart = DateTime.now();

    // Creates the sleep session immediately so notes can be attached while the user is still sleeping.
    _activeSleepRef = await _db
        .collection('users')
        .doc(user.uid)
        .collection('sleepLogs')
        .add({
          'start': Timestamp.fromDate(_sleepStart!),
          'notes': '',
          'active': true,
        });
  }

  Future<void> saveJournalNote(String note) async {
    if (_activeSleepRef == null) {
      throw Exception('No active sleep session');
    }

    await _activeSleepRef!.update({
      'notes': note,
    });
  }

  Future<void> endSleep() async {

    if (_activeSleepRef == null||_sleepStart == null) {
      throw Exception('No active sleep session');
    }

    final end = DateTime.now();

    await _activeSleepRef!.update({
          'active': false,
          'end': Timestamp.fromDate(end),
        });

    _sleepStart = null;
    _activeSleepRef = null;
  }
}