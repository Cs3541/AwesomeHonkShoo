// Imports presentation widgets and the calendar's navigation presenter.
import 'package:flutter/material.dart';

import '../presenters/calendar_presenter.dart';
import '../models/calendar_model.dart';

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
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Selected: ${localizations.formatFullDate(_presenter.selectedDate)}',
                semanticsLabel:
                    'Selected day: ${localizations.formatFullDate(_presenter.selectedDate)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            // Render dates from presenter state so month browsing cannot select a day.
            _buildCalendar(context),
            // Explain the duration colors without displaying exact daily sleep data.
            const SizedBox(height: 16),
            const Text('Sleep duration • grouped by wake-up day'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: SleepDurationBand.values
                  .map(
                    (band) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _bandColor(band),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(_bandLabel(band)),
                      ],
                    ),
                  )
                  .toList(),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Ring: selected day • Underlined number: today'),
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

  // Build a locale-aware month grid with separate selected-day and today markers.
  Widget _buildCalendar(BuildContext context) {
    final labels = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final month = _presenter.displayedMonth;
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = labels.firstDayOfWeekIndex;
    final leadingDays = (month.weekday % 7 - firstWeekday + 7) % 7;
    final cellCount = ((leadingDays + days + 6) ~/ 7) * 7;

    // Match weekday headings to the user's local first day of the week.
    return Column(
      children: [
        Row(
          children: List.generate(
            7,
            (index) => Expanded(
              child: Center(
                child: Text(labels.narrowWeekdays[(firstWeekday + index) % 7]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Reserve blank cells around the month to keep weekday columns aligned.
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 48,
          ),
          itemCount: cellCount,
          itemBuilder: (context, index) {
            final number = index - leadingDays + 1;
            if (number < 1 || number > days) return const SizedBox.shrink();
            final day = DateTime(month.year, month.month, number);
            final selected = DateUtils.isSameDay(day, _presenter.selectedDate);
            final band = _presenter.bandForDay(day);
            final today = DateUtils.isSameDay(day, DateTime.now());

            // Announce selection to screen readers and provide a keyboard-focusable tap target.
            return Semantics(
              selected: selected,
              label:
                  '${labels.formatFullDate(day)}, ${_bandLabel(band)}${today ? ', today' : ''}',
              excludeSemantics: true,
              child: TextButton(
                onPressed: () => _presenter.selectDay(day),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: band == SleepDurationBand.noData
                      ? theme.colorScheme.onSurface
                      : Colors.black,
                ),
                // Keep the selection ring outside the sleep color so both remain visible.
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(
                            color: theme.colorScheme.onSurface,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _bandColor(band),
                    ),
                    child: Text(
                      labels.formatDecimal(number),
                      // Make today heavier and larger while retaining its underline.
                      style: TextStyle(
                        fontSize: today ? 18 : 14,
                        fontWeight: today ? FontWeight.w900 : FontWeight.normal,
                        decoration: today ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Use light fills so day numbers remain readable in both app themes.
  Color? _bandColor(SleepDurationBand band) => switch (band) {
    SleepDurationBand.noData => null,
    SleepDurationBand.underSix => const Color(0xFFFFAB91),
    SleepDurationBand.sixToSeven => const Color(0xFFFFE082),
    SleepDurationBand.sevenToNine => const Color(0xFFA5D6A7),
    SleepDurationBand.overNine => const Color(0xFFB39DDB),
  };

  // Reuse identical descriptions for the legend and accessible date labels.
  String _bandLabel(SleepDurationBand band) => switch (band) {
    SleepDurationBand.noData => 'No sleep logged',
    SleepDurationBand.underSix => 'Under 6 hours',
    SleepDurationBand.sixToSeven => '6–under 7 hours',
    SleepDurationBand.sevenToNine => '7–9 hours',
    SleepDurationBand.overNine => 'Over 9 hours',
  };
}
