// Exercise date selection independently of Firebase and other app tabs.
import 'package:awesome_honk_shoo_app/models/calendar_model.dart';
import 'package:awesome_honk_shoo_app/presenters/calendar_presenter.dart';
import 'package:awesome_honk_shoo_app/views/calendar_screen.dart';
import 'package:awesome_honk_shoo_app/models/sleep_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Verify selection survives month navigation and the calendar marks tapped dates.
void main() {
  // Browsing across a year boundary must preserve the selected day.
  test('month browsing preserves selection until another day is selected', () {
    final presenter = CalendarPresenter(
      model: CalendarModel(initialDate: DateTime(2026, 12, 18)),
    );
    addTearDown(presenter.dispose);
    presenter.moveMonth(1);
    expect(presenter.displayedMonth, DateTime(2027, 1));
    expect(presenter.selectedDate, DateTime(2026, 12, 18));
    presenter.moveMonth(-1);
    expect(presenter.selectedDate, DateTime(2026, 12, 18));
    presenter.selectDay(DateTime(2026, 12, 22));
    expect(presenter.selectedDate, DateTime(2026, 12, 22));
  });

  // The selected date remains marked after browsing away and returning.
  testWidgets('tapped date stays selected when browsing months', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: CalendarScreen(model: EmptyCalendarModel())),
    );
    await tester.tap(find.text('15'));
    await tester.pump();
    final selectedText = tester
        .widget<Text>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                (widget.data?.startsWith('Selected:') ?? false),
          ),
        )
        .data;
    await tester.tap(find.byTooltip('Next month'));
    await tester.pump();
    expect(find.text(selectedText!), findsOneWidget);
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.selected == true,
      ),
      findsOneWidget,
    );
  });
}

// Keep widget tests independent of Firebase initialization and network access.
class EmptyCalendarModel extends CalendarModel {
  @override
  Stream<List<SleepLog>> watchMonth(DateTime month) => Stream.value([]);
}
