import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "dart:math";

// A class that saves everything that would be loaded on a day_overview.
class DayOfSleep {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // used to calculate screen time (sorry)
  static const int minutesInADay = 1440;

  // Hopefully unique.
  final String id;
  // Time you went to bed.
  DateTime start;
  // Time you woke up.
  DateTime end;
  // Seconds you were on your phone.
  int screenTime;
  // Rating out of 5.
  int stars;
  // The day that the sleep is "recorded" for.
  // For instance, if you went to bed at 10:00 pm on Saturday, this will show up when you open up Saturday.
  // If you go to bed at 2:30 am on Sunday, it will still count as Saturday's sleep. This is why this variable exists.
  DateTime tiedDate;
  // (Optional) Notes on the day of sleep.
  String notes;

  DayOfSleep({
    required this.id,
    required this.start,
    required this.end,
    required this.tiedDate,
    this.stars = 0,
    this.screenTime = 0,
    this.notes = '',
  });

  // my glorious setters!
  // these setters are all accessible by user actions on the day overview screen
  void setStart(DateTime start) {
    this.start = start;
  }

  void setEnd(DateTime end) {
    this.end = end;
  }

  void setScreenTime(int screenTime) {
    this.screenTime = screenTime;
  }

  Duration getDurationOfSleep() {
    return end.difference(start);
  }

  // used to compare to other values of a pie chart easily, since floats of time elapsed don't exist I guess
  int getMinutesOfSleep() {
    return getDurationOfSleep().inMinutes;
  }

  int getMinutesOfScreenTime() {
    return screenTime;
  }

  int getMinutesOfWakeTime() {
    // min of 0 seconds obviously
    return max(
      0,
      minutesInADay - getMinutesOfScreenTime() - getMinutesOfSleep(),
    );
  }
}
