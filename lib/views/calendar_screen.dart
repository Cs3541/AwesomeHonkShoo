// Imports presentation widgets and the calendar's navigation presenter.
import 'package:flutter/material.dart';

import '../presenters/calendar_presenter.dart';
import '../models/calendar_model.dart';
import 'calendar_month_grid.dart';
import 'calendar_search_controls.dart';
import 'calendar_legend_dialog.dart';
import 'monthly_sleep_dialog.dart';

// Displays only the calendar; daily details and journal entry belong elsewhere.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.model});

  // Allow isolated calendar data sources in widget tests.
  final CalendarModel? model;

  // Create the state that owns this screen's presenter.
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

// Owns presenter lifetime while keeping navigation logic out of the view.
class _CalendarScreenState extends State<CalendarScreen> {
  late final CalendarPresenter _presenter;

  // Start observing the displayed month's persisted sleep entries.
  @override
  void initState() {
    super.initState();
    _presenter = CalendarPresenter(model: widget.model)..loadMonth();
  }

  // Release presenter listeners when the calendar leaves the widget tree.
  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  // Rebuild the calendar when the presenter reports a date change.
  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return AnimatedBuilder(
      animation: _presenter,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Sleep Calendar'),
          actions: [
            // Open color and marker explanations without taking calendar space.
            TextButton(onPressed: _showLegend, child: const Text('Legend')),
            // Return to today's date without loading daily details.
            TextButton(
              onPressed: _presenter.selectToday,
              child: const Text('Today'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            // Show draft journal and rating controls above the calendar.
            CalendarSearchControls(presenter: _presenter),
            const SizedBox(height: 4),
            // Display the current month with previous and next month controls.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'Previous month',
                  onPressed: () => _presenter.moveMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  localizations.formatMonthYear(_presenter.displayedMonth),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  tooltip: 'Next month',
                  onPressed: () => _presenter.moveMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            // Keep the selected date visible in text when browsing another month.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Selected: ${localizations.formatFullDate(_presenter.selectedDate)}',
                semanticsLabel:
                    'Selected day: ${localizations.formatFullDate(_presenter.selectedDate)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            // Render dates from presenter state so month browsing cannot select a day.
            CalendarMonthGrid(presenter: _presenter),
            // Temporary access to monthly trends without expanding the calendar.
            TextButton.icon(
              onPressed: _showMonthlyAverage,
              icon: const Icon(Icons.bar_chart),
              label: const Text('Show monthly average'),
            ),
            // Distinguish loading and failed requests from an empty sleep history.
            if (_presenter.loading) const LinearProgressIndicator(),
            if (_presenter.error != null) ...[
              Text(_presenter.error!),
              TextButton(
                onPressed: _presenter.loadMonth,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Open the chart popup with the screen-owned presenter for live month updates.
  void _showMonthlyAverage() {
    showDialog<void>(
      context: context,
      builder: (context) => MonthlySleepDialog(presenter: _presenter),
    );
  }

  // Open the self-contained legend view without changing calendar state.
  void _showLegend() {
    showDialog<void>(
      context: context,
      builder: (context) => const CalendarLegendDialog(),
    );
  }
}
