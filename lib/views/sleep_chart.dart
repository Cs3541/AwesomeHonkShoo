// Imports the chart widgets and their separate MVP data components.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/bar_chart_model.dart';
import '../presenters/bar_chart_presenter.dart';

// Renders the reusable sleep chart without adding it to the calendar tab.
class SleepChart extends StatelessWidget {
  // Accept the month and recorded daily totals for a display-only chart.
  const SleepChart({super.key, required this.month, required this.daily});
  final DateTime month;
  final Map<int, double> daily;

  // Build chart bars from presenter values and apply the app theme.
  @override
  Widget build(BuildContext context) {
    // Let the presenter calculate chart values independently of the widgets.
    final presenter = BarChartPresenter(
      BarChartModel(month: month, daily: daily),
    );
    final bars = <BarChartGroupData>[];
    // Build one bar for each calendar day, including days without sleep logs.
    for (int day = 1; day <= presenter.daysInMonth; day++) {
      bars.add(
        BarChartGroupData(
          x: day,
          barRods: [
            BarChartRodData(
              toY: presenter.hoursForDay(day),
              color: Theme.of(context).colorScheme.primary,
              width: 6,
            ),
          ],
        ),
      );
    }
    // Draw the bars and axes without navigation or touch interactions.
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: presenter.maximumHours,
        alignment: BarChartAlignment.spaceAround,
        barGroups: bars,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text('Hours'),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 2,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) =>
                  value == 1 || value.toInt() % 5 == 0
                  ? Text(value.toInt().toString())
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        // Keep the chart display-only when tapped or hovered.
        barTouchData: BarTouchData(enabled: false),
      ),
    );
  }
}
