import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SleepLog {
  final String id;
  final DateTime sleepTime;
  final DateTime wakeTime;
  final double quality;
  final String notes;

  SleepLog({
    required this.id,
    required this.sleepTime,
    required this.wakeTime,
    required this.quality,
    required this.notes,
  });

  static final DatabaseReference _db = FirebaseDatabase.instance.ref();
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<List<SleepLog>> getSleepLogs() async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final snapshot = await _db.child('sleepLogs/$userId').get();

    final List<SleepLog> sleepLogs = [];

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      data.forEach((key, value) {
        sleepLogs.add(
          SleepLog.fromMap(
            key,
            Map<String, dynamic>.from(value),
          ),
        );
      });
    }

    return sleepLogs;
  }

  Map<String, dynamic> toMap() {
    return {
      'sleepTime': sleepTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'quality': quality,
      'notes': notes,
    };
  }

  factory SleepLog.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return SleepLog(
      id: id,
      sleepTime: DateTime.parse(map['sleepTime']),
      wakeTime: DateTime.parse(map['wakeTime']),
      quality: (map['quality'] as num).toDouble(),
      notes: map['notes'] ?? '',
    );
  }
}