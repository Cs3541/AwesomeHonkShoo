import 'dart:ffi';
import 'dart:math';

import 'package:awesome_honk_shoo_app/presenters/day_overview_presenter.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

class DayOverviewScreen extends StatelessWidget {
  bool _isLoading = true;
  DayOverviewPresenter _dayOverviewPresenter = DayOverviewPresenter();

  // properties for the chart so we can modify it easier
  final double chartRadius = 150;

  // should be fetched from database; in seconds
  int screenTime = 5;
  // should be fetched from database; in seconds
  int sleepTime = 8;
  // starts at 24 hours, reduced by screenTime and sleepTime in the actual chart build. In seconds I guess.
  int otherTime = 24;

  DayOverviewScreen({super.key});

  // Gather ye data!
  Future<void> _loadData() async {
    await _dayOverviewPresenter.setDay();
    setState(() {
      _isLoading = false;
      if (!(_dayOverviewPresenter.getDay() != null)) {
        return;
      }
      sleepTime = _dayOverviewPresenter.getDay()?.getSecondsOfSleep() ?? 1;
      screenTime =
          _dayOverviewPresenter.getDay()?.getSecondsOfScreenTime() ?? 1;
      otherTime = _dayOverviewPresenter.getDay()?.getSecondsOfWakeTime() ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // used for percentage-based screen sizing
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Day Overview')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: screenWidth * 0.15,
              ),
              child: SizedBox(
                height: 200,
                child: TextField(
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: "Notes...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 0,
                  sections: [
                    PieChartSectionData(
                      // Screen time
                      value: screenTime,
                      title: '',
                      badgeWidget: Icon(
                        color: Colors.white,
                        Icons.phone_android,
                        size: 48,
                      ),
                      color: Colors.blue,
                      radius: chartRadius,
                    ),
                    PieChartSectionData(
                      // Sleep
                      value: sleepTime,
                      title: '',
                      badgeWidget: Icon(
                        color: Colors.white,
                        Icons.nightlight_round_outlined,
                        size: 48,
                      ),
                      color: Colors.purple,
                      radius: chartRadius,
                    ),
                    PieChartSectionData(
                      // "Other"
                      value: otherTime,
                      title: '',
                      badgeWidget: Icon(
                        color: Colors.white,
                        Icons.sunny,
                        size: 48,
                      ),
                      color: Colors.orange,
                      radius: chartRadius,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
