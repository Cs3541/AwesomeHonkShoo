import 'package:cloud_firestore/cloud_firestore.dart';

class NapLog {
  const NapLog({
    required this.id,
    required this.start,
    required this.end,
  });

  final String id;
  final DateTime start;
  final DateTime end;

  // Attribute an overnight sleep to the day the user woke up.
  DateTime get day => DateTime(end.year, end.month, end.day);
  double get hours => end.difference(start).inMinutes / 60;

  factory NapLog.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return NapLog(
      id: doc.id,
      start: (data['start'] as Timestamp).toDate(),
      end: (data['end'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'start': Timestamp.fromDate(start),
    'end': Timestamp.fromDate(end),
  };
}