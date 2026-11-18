// Uses the separate chart model to calculate values for the chart view.
import '../models/bar_chart_model.dart';

// Keeps chart calculations out of the reusable chart widget.
class BarChartPresenter {
  BarChartPresenter(this._model);

  final BarChartModel _model;

  // Include every day of the displayed month, accounting for leap years.
  int get daysInMonth =>
      DateTime(_model.month.year, _model.month.month + 1, 0).day;

  // Treat days without recorded sleep as zero-height bars.
  double hoursForDay(int day) => _model.daily[day] ?? 0;

  // Leave one hour of space above the tallest bar, with a ten-hour baseline.
  double get maximumHours {
    double maximum = 10;
    for (final hours in _model.daily.values) {
      if (hours > maximum) maximum = hours;
    }
    return maximum + 1;
  }
}
