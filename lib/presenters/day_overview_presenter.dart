import 'package:awesome_honk_shoo_app/models/day_overview_model.dart';

class DayOverviewPresenter {
  DayOfSleep? _dayOfSleep;

  Future setDay(DayOfSleep newDay) async {
    _dayOfSleep = newDay;
  }

  DayOfSleep? getDay() {
    return _dayOfSleep;
  }
}
