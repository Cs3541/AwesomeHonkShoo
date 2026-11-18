// Verify the future search-results hook without connecting any data sources.
import 'package:awesome_honk_shoo_app/models/calendar_model.dart';
import 'package:awesome_honk_shoo_app/models/sleep_log.dart';
import 'package:awesome_honk_shoo_app/presenters/calendar_presenter.dart';
import 'package:flutter_test/flutter_test.dart';

// Cover date normalization, replacing results, and clearing stale criteria.
void main() {
  test('matching dates ignore time and preserve sleep data and selection', () {
    final model = CalendarModel(initialDate: DateTime(2026, 11, 18));
    final presenter = CalendarPresenter(model: model);
    addTearDown(presenter.dispose);
    model.replaceLogs([
      SleepLog(
        id: 'test',
        start: DateTime(2026, 11, 17, 23),
        end: DateTime(2026, 11, 18, 7),
      ),
    ]);
    presenter.showMatchingDays([
      DateTime(2026, 11, 18, 12),
      DateTime(2026, 12, 1),
    ]);
    expect(presenter.isMatchedDay(DateTime(2026, 11, 18)), isTrue);
    expect(presenter.isMatchedDay(DateTime(2026, 12, 1, 8)), isTrue);
    presenter.clearMatchingDays();
    expect(presenter.isMatchedDay(DateTime(2026, 11, 18)), isFalse);
    expect(
      presenter.bandForDay(DateTime(2026, 11, 18)),
      SleepDurationBand.sevenToNine,
    );
    expect(presenter.selectedDate, DateTime(2026, 11, 18));
  });

  // Changing either draft control must discard markers for the previous criteria.
  test('new results replace old dates and criteria edits clear them', () {
    final presenter = CalendarPresenter();
    addTearDown(presenter.dispose);
    final first = DateTime(2026, 11, 1);
    final second = DateTime(2026, 11, 2);
    presenter.showMatchingDays([first]);
    presenter.showMatchingDays([second]);
    expect(presenter.isMatchedDay(first), isFalse);
    expect(presenter.isMatchedDay(second), isTrue);
    presenter.updateJournalQuery('coffee');
    expect(presenter.isMatchedDay(second), isFalse);
    presenter.showMatchingDays([second]);
    presenter.setSelectedRating(2);
    expect(presenter.isMatchedDay(second), isFalse);
  });
}
