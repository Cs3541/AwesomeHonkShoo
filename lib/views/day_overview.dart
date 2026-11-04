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
    return Scaffold(
      appBar: AppBar(title: const Text('Day Overview')),
      body: Center(
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
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                // "Other"
                // prevents negative values, which are probably bad
                value: max(0, otherTime - sleepTime - screenTime),
                title: '',
                badgeWidget: Icon(color: Colors.white, Icons.sunny, size: 48),
                color: Colors.orange,
                radius: chartRadius,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
