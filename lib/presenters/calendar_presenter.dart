// Connects calendar navigation actions to the calendar model.
import 'dart:async';

import 'package:awesome_honk_shoo_app/views/day_overview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../models/calendar_model.dart';
import '../models/bar_chart_model.dart';
import '../models/sleep_log.dart';

// Notifies the calendar view when its date or month changes.
class CalendarPresenter extends ChangeNotifier {
  CalendarPresenter({CalendarModel? model}) : _model = model ?? CalendarModel();

  final CalendarModel _model;
  StreamSubscription<List<SleepLog>>? _subscription;
  int _loadVersion = 0;
  bool loading = false;
  String? error;

  // Expose draft controls without querying journal entries or ratings.
  String get journalQuery => _model.journalQuery;
  int? get selectedRating => _model.selectedRating;

  // Remember typed search text for the future search integration.
  void updateJournalQuery(String query) {
    _model.journalQuery = query;
    // Old results no longer describe the edited search criteria.
    _model.clearMatchedDays();
    notifyListeners();
  }

  // Store an exact 0–5 rating, or null for Any, without filtering real data yet.
  void setSelectedRating(int? rating) {
    if (rating != null && (rating < 0 || rating > 5)) {
      throw ArgumentError.value(
        rating,
        'rating',
        'Must be 0–5 or null for Any',
      );
    }
    _model.selectedRating = rating;
    // Recompute matching dates after a filter change once data is connected.
    _model.clearMatchedDays();
    notifyListeners();
  }

  // The view asks only whether a date matches; it does not perform searches.
  bool isMatchedDay(DateTime day) => _model.isMatchedDay(day);

  // INTEGRATION: after journal search and rating filtering, pass the final matching
  // dates here. If both controls are active, pass dates satisfying both criteria.
  // This updates highlights only; it never queries or edits Day Overview data.
  void showMatchingDays(Iterable<DateTime> days) {
    _model.replaceMatchedDays(days);
    notifyListeners();
  }

  // Restore ordinary sleep colors when results are dismissed or criteria cleared.
  void clearMatchingDays() {
    _model.clearMatchedDays();
    notifyListeners();
  }

  // Pass the displayed month's totals to the separate chart model without
  // mixing chart calculations into calendar navigation or search highlights.
  BarChartModel get monthlyChart => BarChartModel(
    month: displayedMonth,
    daily: {
      for (final entry in _model.dailyHours.entries)
        if (entry.key.year == displayedMonth.year &&
            entry.key.month == displayedMonth.month)
          entry.key.day: entry.value,
    },
  );

  // Provide duration categories while keeping color choices in the view.
  SleepDurationBand bandForDay(DateTime day) => _model.bandForDay(day);

  // Replace the old month subscription and discard any late results from it.
  void loadMonth() {
    final version = ++_loadVersion;
    _subscription?.cancel();
    _model.dailyHours.clear();
    loading = true;
    error = null;
    notifyListeners();
    try {
      _subscription = _model
          .watchMonth(displayedMonth)
          .listen(
            (logs) {
              if (version != _loadVersion) return;
              _model.replaceLogs(logs);
              loading = false;
              notifyListeners();
            },
            onError: (Object failure) {
              if (version != _loadVersion) return;
              _model.dailyHours.clear();
              loading = false;
              error = 'Could not load sleep colors. Please try again.';
              notifyListeners();
            },
          );
    } catch (_) {
      loading = false;
      error = 'Could not load sleep colors. Please try again.';
      notifyListeners();
    }
  }

  // Cancel database updates when this presenter leaves the widget tree.
  @override
  void dispose() {
    _loadVersion++;
    _subscription?.cancel();
    super.dispose();
  }

  // Expose the dates needed to render the calendar.
  DateTime get selectedDate => _model.selectedDate;
  DateTime get displayedMonth => _model.displayedMonth;

  // Record the chosen day and keep its month in sync.
  void selectDay(DateTime day) {
    final monthChanged =
        day.year != displayedMonth.year || day.month != displayedMonth.month;
    _model.selectedDate = DateTime(day.year, day.month, day.day);
    _model.displayedMonth = DateTime(day.year, day.month);
    if (monthChanged) loadMonth();
    notifyListeners();
    switchToDayOverview();
    print("You picked a day. THIS IS IMPORTANT KEVIN BEYER");
  }

  // Browse months without changing the day the user selected.
  void showMonth(DateTime month) {
    _model.displayedMonth = DateTime(month.year, month.month);
    loadMonth();
  }

  // Move through months while staying inside the date picker's supported range.
  void moveMonth(int offset) {
    final month = DateTime(displayedMonth.year, displayedMonth.month + offset);
    if (month.isBefore(DateTime(1900)) || month.isAfter(DateTime(2200, 12))) {
      return;
    }
    showMonth(month);
  }

  // Reset both the selected date and displayed month to today.
  void selectToday() => selectDay(DateTime.now());

  // Tells the Navigator to switch screens.
  void switchToDayOverview() {
    _model.switchToDayOverview();
  }
}
