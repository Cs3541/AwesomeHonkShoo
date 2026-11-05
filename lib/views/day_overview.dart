import 'dart:math';

import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

class DayOverviewScreen extends StatelessWidget {
  // properties for the chart so we can modify it easier
  final double chartRadius = 150;

  // should be fetched from database
  double screenTime = 5.4;
  // should be fetched from database
  double sleepTime = 8.3;
  // starts at 24 hours, reduced by screenTime and sleepTime in the actual chart build.
  final double otherTime = 24;

  DayOverviewScreen({super.key});

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
                      // prevents negative values, which are probably bad
                      value: max(0, otherTime - sleepTime - screenTime),
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
