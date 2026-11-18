// Connects calendar navigation actions to the calendar model.
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/calendar_model.dart';
import '../models/sleep_log.dart';

// Notifies the calendar view when its date or month changes.
class CalendarPresenter extends ChangeNotifier {
  CalendarPresenter({CalendarModel? model}) : _model = model ?? CalendarModel();

  final CalendarModel _model;
  StreamSubscription<List<SleepLog>>? _subscription;
  int _loadVersion = 0;
  bool loading = false;
  String? error;

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
}
