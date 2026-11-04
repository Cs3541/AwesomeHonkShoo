import 'package:cloud_firestore/cloud_firestore.dart';

class SleepLog {
  const SleepLog({
    required this.id,
    required this.start,
    required this.end,
    this.notes = '',
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final String notes;

  // Attribute an overnight sleep to the day the user woke up.
  DateTime get day => DateTime(end.year, end.month, end.day);
  double get hours => end.difference(start).inMinutes / 60;

  factory SleepLog.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return SleepLog(
      id: doc.id,
      start: (data['start'] as Timestamp).toDate(),
      end: (data['end'] as Timestamp).toDate(),
      notes: data['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'start': Timestamp.fromDate(start),
    'end': Timestamp.fromDate(end),
    'notes': notes,
  };
}
