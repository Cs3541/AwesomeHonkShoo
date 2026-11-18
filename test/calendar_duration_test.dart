// Verify duration boundaries and wake-up date aggregation without Firebase.
import 'package:awesome_honk_shoo_app/models/calendar_model.dart';
import 'package:awesome_honk_shoo_app/models/sleep_log.dart';
import 'package:flutter_test/flutter_test.dart';

// Construct persisted-style sleep sessions with precise fractional-hour durations.
SleepLog session(int day, int minutes) {
  final end = DateTime(2026, 11, day, 8);
  return SleepLog(
    id: '$day-$minutes',
    start: end.subtract(Duration(minutes: minutes)),
    end: end,
  );
}

// Exercise every boundary and distinguish missing records from recorded durations.
void main() {
  test('duration bands honor exact boundaries and combine daily sessions', () {
    final model = CalendarModel();
    model.replaceLogs([
      session(1, 359),
      session(2, 360),
      session(3, 419),
      session(4, 420),
      session(5, 540),
      session(6, 541),
      session(7, 180),
      session(7, 240),
    ]);
    expect(model.bandForDay(DateTime(2026, 11, 1)), SleepDurationBand.underSix);
    expect(
      model.bandForDay(DateTime(2026, 11, 2)),
      SleepDurationBand.sixToSeven,
    );
    expect(
      model.bandForDay(DateTime(2026, 11, 3)),
      SleepDurationBand.sixToSeven,
    );
    expect(
      model.bandForDay(DateTime(2026, 11, 4)),
      SleepDurationBand.sevenToNine,
    );
    expect(
      model.bandForDay(DateTime(2026, 11, 5)),
      SleepDurationBand.sevenToNine,
    );
    expect(model.bandForDay(DateTime(2026, 11, 6)), SleepDurationBand.overNine);
    expect(
      model.bandForDay(DateTime(2026, 11, 7)),
      SleepDurationBand.sevenToNine,
    );
    expect(model.bandForDay(DateTime(2026, 11, 8)), SleepDurationBand.noData);
    model.replaceLogs([]);
    expect(model.bandForDay(DateTime(2026, 11, 7)), SleepDurationBand.noData);
  });
}
