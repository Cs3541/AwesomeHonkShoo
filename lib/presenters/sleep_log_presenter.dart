import '../models/sleep_log_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SleepLogPresenter {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveSleepLog(SleepLog log) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final newLogRef = _db.child('sleepLogs/$userId').push();

    await newLogRef.set(log.toMap());
  }

  Future<List<SleepLog>> getSleepLogs() async {
    return await SleepLog.getSleepLogs();
  }
}