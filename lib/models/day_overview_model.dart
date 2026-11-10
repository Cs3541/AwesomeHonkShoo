import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

// A class that saves everything that would be loaded on a day_overview.
class DayOfSleep {
  const DayOfSleep({
    required this.id,
    required this.start,
    required this.end,
    this.screenTime = 0,
    this.notes = '',
  });

  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // Hopefully unique.
  final String id;
  // Time you went to bed.
  final DateTime start;
  // Time you woke up.
  final DateTime end;
  // Hours you slept.
  final double screenTime;
  // (Optional) Notes on the day of sleep.
  final String notes;
}
