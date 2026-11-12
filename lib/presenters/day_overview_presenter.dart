import 'package:awesome_honk_shoo_app/models/day_overview_model.dart';

import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class DayOverviewPresenter {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  DayOfSleep? _dayOfSleep;

  Future setDay(DayOfSleep newDay) async {
    _dayOfSleep = newDay;
  }

  DayOfSleep? getDay() {
    return _dayOfSleep;
  }

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

    try {
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
    } catch (e) {
      return DayOfSleep(
        id: "3",
        start: DateTime(2026, 11, 4, 21, 4, 2),
        end: DateTime(2026, 11, 5, 7, 3, 1),
        tiedDate: DateTime(2026, 11, 4, 21, 4, 2),
        screenTime: 1,
        notes: "no notes!",
      );
    }
  }
}
