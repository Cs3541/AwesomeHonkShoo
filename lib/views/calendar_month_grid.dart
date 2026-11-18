// Renders the month grid and forwards date selections to the presenter.
import 'package:flutter/material.dart';

import '../presenters/calendar_presenter.dart';
import '../models/calendar_model.dart';
import 'calendar_styles.dart';

// This view uses the screen-owned presenter and never disposes it.
class CalendarMonthGrid extends StatelessWidget {
  // Receive the same presenter as the screen so all controls share state.
  const CalendarMonthGrid({super.key, required this.presenter});

  final CalendarPresenter presenter;

  // Build a locale-aware month grid with separate selected-day and today markers.
  @override
  Widget build(BuildContext context) {
    final labels = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final month = presenter.displayedMonth;
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
            final selected = DateUtils.isSameDay(day, presenter.selectedDate);
            final band = presenter.bandForDay(day);
            // Future results override only the fill; selection and today stay visible.
            final matched = presenter.isMatchedDay(day);
            final today = DateUtils.isSameDay(day, DateTime.now());

            // Announce selection to screen readers and provide a keyboard-focusable tap target.
            return Semantics(
              selected: selected,
              label:
                  '${labels.formatFullDate(day)}, ${calendarBandLabel(band)}${matched ? ', search or filter match' : ''}${today ? ', today' : ''}',
              excludeSemantics: true,
              child: TextButton(
                onPressed: () => presenter.selectDay(day),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: matched
                      ? Colors.white
                      : band == SleepDurationBand.noData
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
                      color: matched
                          ? calendarMatchColor
                          : calendarBandColor(band),
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
}
