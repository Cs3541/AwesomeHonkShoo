import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

// A class that saves everything that would be loaded on a day_overview.
class DayOfSleep {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // Hopefully unique.
  final String id;
  // Time you went to bed.
  final DateTime start;
  // Time you woke up.
  final DateTime end;
  // Hours you were on your dang phone.
  final double screenTime;
  // The day that the sleep is "recorded" for.
  // For instance, if you went to bed at 10:00 pm on Saturday, this will show up when you open up Saturday.
  // If you go to bed at 2:30 am on Sunday, it will still count as Saturday's sleep. This is why this variable exists.
  final DateTime tiedDate;
  // (Optional) Notes on the day of sleep.
  final String notes;

  const DayOfSleep({
    required this.id,
    required this.start,
    required this.end,
    required this.tiedDate,
    this.screenTime = 0,
    this.notes = '',
  });

  // returns day of sleep for a given selected day.
  // If multiple days have the same "day" assigned, they will misbehave. This is a bug. Eek.
  // It also shouldn't work yet.
  static Future<DayOfSleep> fetchSleepDay() async {
    // userId will never be null don't worry about it
    final userId = _auth.currentUser?.uid;

    final snapshot = await _firestore
        .collection("newSleepLog")
        .where("userId", isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return DayOfSleep(
        id: data["id"],
        start: data["start"],
        end: data["end"],
        tiedDate: data["tiedDate"],
        screenTime: data["screenTime"],
        notes: data["notes"],
      );
    }).first;
  }
}
