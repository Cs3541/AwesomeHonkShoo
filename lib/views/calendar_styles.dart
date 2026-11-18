// Shared visual rules keep the calendar grid and its legend consistent.
import 'package:flutter/material.dart';

import '../models/calendar_model.dart';

// Search matches use a vivid fill distinct from all sleep-duration bands.
const calendarMatchColor = Color(0xFF0057D9);

// Use light fills so day numbers remain readable in both app themes.
Color? calendarBandColor(SleepDurationBand band) => switch (band) {
  SleepDurationBand.noData => null,
  SleepDurationBand.underSix => const Color(0xFFFFAB91),
  SleepDurationBand.sixToSeven => const Color(0xFFFFE082),
  SleepDurationBand.sevenToNine => const Color(0xFFA5D6A7),
  SleepDurationBand.overNine => const Color(0xFFB39DDB),
};

// Reuse identical descriptions for the legend and accessible date labels.
String calendarBandLabel(SleepDurationBand band) => switch (band) {
  SleepDurationBand.noData => 'No sleep logged',
  SleepDurationBand.underSix => 'Under 6 hours',
  SleepDurationBand.sixToSeven => '6–under 7 hours',
  SleepDurationBand.sevenToNine => '7–9 hours',
  SleepDurationBand.overNine => 'Over 9 hours',
};
