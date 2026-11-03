import '../models/sleep_log_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SleepLogPresenter {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveSleepLog(SleepLog log) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _db
        .collection('users')
        .doc(userId)
        .collection('sleepLogs')
        .add(log.toMap());
  }

  Future<List<SleepLog>> getSleepLogs() async {
    return await SleepLog.getSleepLogs();
  }
}