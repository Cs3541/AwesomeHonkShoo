// Displays monthly sleep totals using the separate chart model and presenter.
import 'package:flutter/material.dart';

import '../presenters/calendar_presenter.dart';
import '../presenters/bar_chart_presenter.dart';
import 'sleep_chart.dart';

// The calendar owns the presenter; this popup only observes it while open.
class MonthlySleepDialog extends StatelessWidget {
  const MonthlySleepDialog({super.key, required this.presenter});

  final CalendarPresenter presenter;

  // Keep loading, error, average, and chart views current as sleep data arrives.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: presenter,
      builder: (context, _) {
        final model = presenter.monthlyChart;
        final chartPresenter = BarChartPresenter(model);
        final average = chartPresenter.averageHours;
        return AlertDialog(
          title: Text(
            MaterialLocalizations.of(context).formatMonthYear(model.month),
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Distinguish unavailable data from a month with no sleep records.
                  if (presenter.loading)
                    const LinearProgressIndicator()
                  else if (presenter.error != null) ...[
                    Text(presenter.error!),
                    TextButton(
                      onPressed: presenter.loadMonth,
                      child: const Text('Retry'),
                    ),
                  ] else ...[
                    Text(
                      average == null
                          ? 'No sleep logged this month.'
                          : 'Average: ${average.toStringAsFixed(1)} hours',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      average == null
                          ? 'An average will appear once sleep is recorded.'
                          : 'Based on ${chartPresenter.loggedDays} logged days. Days without logs are excluded.',
                    ),
                    const SizedBox(height: 20),
                    // Display monthly sleep totals without changing calendar selection.
                    SizedBox(
                      height: 220,
                      child: SleepChart(month: model.month, daily: model.daily),
                    ),
                    const SizedBox(height: 8),
                    const Text('Sleep hours by wake-up day.'),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
