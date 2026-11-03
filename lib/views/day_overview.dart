import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

class DayOverviewScreen extends StatelessWidget {
  // properties for the chart so we can modify it easier
  final double chartRadius = 150;

  const DayOverviewScreen({super.key});

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
                value: 10,
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
                value: 30,
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
                value: 20,
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
