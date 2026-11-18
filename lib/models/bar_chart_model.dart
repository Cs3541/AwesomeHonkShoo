// Stores chart data separately from calendar navigation state.
class BarChartModel {
  // Copy daily totals so callers cannot change the chart data unexpectedly.
  BarChartModel({required this.month, required Map<int, double> daily})
    : daily = Map.unmodifiable(daily);

  final DateTime month;
  final Map<int, double> daily;
}
