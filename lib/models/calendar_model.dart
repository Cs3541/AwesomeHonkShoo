// Reads persisted sleep logs while keeping Firebase access out of the view.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'sleep_log.dart';

// Describes duration bands without attaching Flutter colors to the model.
enum SleepDurationBand { noData, underSix, sixToSeven, sevenToNine, overNine }

// Stores the selected date and displayed month without depending on Flutter.
class CalendarModel {
  // Open the calendar at today's date unless an initial date is supplied.
  CalendarModel({DateTime? initialDate}) {
    final day = initialDate ?? DateTime.now();
    selectedDate = DateTime(day.year, day.month, day.day);
    displayedMonth = DateTime(day.year, day.month);
  }

  late DateTime selectedDate;
  late DateTime displayedMonth;

  // Hold draft search controls until journal and rating data are connected.
  String journalQuery = '';
  // Null means Any; zero is a distinct selectable rating for future data.
  int? selectedRating;

  // Keep result dates separate from sleep totals so clearing results restores sleep colors.
  final Set<DateTime> _matchedDays = {};

  // Future search/filter code supplies its final matching dates here, across any months.
  void replaceMatchedDays(Iterable<DateTime> days) {
    _matchedDays
      ..clear()
      ..addAll(days.map((day) => DateTime(day.year, day.month, day.day)));
  }

  // Compare calendar dates only so timestamps with a time component still match.
  bool isMatchedDay(DateTime day) =>
      _matchedDays.contains(DateTime(day.year, day.month, day.day));

  // Remove result markers without changing selection or recorded sleep data.
  void clearMatchedDays() => _matchedDays.clear();

  // Store totals by wake-up date; missing dates remain distinct from zero hours.
  final Map<DateTime, double> dailyHours = {};

  // Query only sleep entries whose wake-up date belongs to the displayed month.
  Stream<List<SleepLog>> watchMonth(DateTime month) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(const <SleepLog>[]);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('sleepLogs')
        .where('end', isGreaterThanOrEqualTo: Timestamp.fromDate(month))
        .where(
          'end',
          isLessThan: Timestamp.fromDate(DateTime(month.year, month.month + 1)),
        )
        .orderBy('end')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(SleepLog.fromDocument).toList());
  }

  // Sum multiple sleep sessions attributed to the same wake-up date.
  void replaceLogs(List<SleepLog> logs) {
    dailyHours.clear();
    for (final log in logs) {
      if (!log.hours.isFinite || log.hours < 0) continue;
      dailyHours.update(
        log.day,
        (hours) => hours + log.hours,
        ifAbsent: () => log.hours,
      );
    }
  }

  // Classify recorded hours using the same boundaries displayed in the legend.
  SleepDurationBand bandForDay(DateTime day) {
    final hours = dailyHours[DateTime(day.year, day.month, day.day)];
    if (hours == null) return SleepDurationBand.noData;
    if (hours < 6) return SleepDurationBand.underSix;
    if (hours < 7) return SleepDurationBand.sixToSeven;
    if (hours <= 9) return SleepDurationBand.sevenToNine;
    return SleepDurationBand.overNine;
  }
}
