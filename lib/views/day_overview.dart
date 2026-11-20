import 'dart:io';

import 'package:awesome_honk_shoo_app/models/day_overview_model.dart';
import 'package:awesome_honk_shoo_app/presenters/day_overview_presenter.dart';
import 'package:awesome_honk_shoo_app/views/star_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

class DayOverviewScreen extends StatefulWidget {
  DayOverviewScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DayOverviewScreenState();
}

class _DayOverviewScreenState extends State<DayOverviewScreen> {
  bool _isLoading = true;

  DayOfSleep? _dayOfSleep;
  // properties for the chart so we can modify it easier
  final double chartRadius = 150;

  // pie chart data itself
  final List<Map<String, dynamic>> pieChartData = [
    {'label': 'On screens', 'value': 10},
    {'label': 'Asleep', 'value': 10},
    {'label': 'Awake and off screens', 'value': 10},
  ];

  // determines what value to display in the text box below the pie chart
  int pieChartTouchedIndex = -1;

  // should be fetched from database; in minutes
  int screenTime = 15;
  // should be fetched from database; in minutes
  int sleepTime = 8;
  // starts at 24 hours, reduced by screenTime and sleepTime in the actual chart build. In minutes.
  int otherTime = 24;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void changeStarRating(int stars) {
    _dayOfSleep!.stars = stars;
  }

  // Gather ye data!
  Future<void> _loadData() async {
    try {
      _dayOfSleep = await DayOverviewPresenter.fetchSleepDay();
    } catch (e) {
      print("Error" + e.toString());
    } finally {
      setState(() {
        reloadDayOfSleepData();
        _isLoading = false;
      });
    }
  }

  // run whenever properties in the DayOfSleep change, or the day itself changes.
  void reloadDayOfSleepData() {
    sleepTime = _dayOfSleep?.getMinutesOfSleep() ?? 1;
    screenTime = _dayOfSleep?.getMinutesOfScreenTime() ?? 1;
    otherTime = _dayOfSleep?.getMinutesOfWakeTime() ?? 1;
    readyPieChartData();
  }

  // matches pie chart data to the ACTUAL data yippe wahoo
  void readyPieChartData() {
    pieChartData.elementAt(0)["value"] = screenTime;
    pieChartData.elementAt(1)["value"] = sleepTime;
    pieChartData.elementAt(2)["value"] = otherTime;
  }

  // if isBedtime is true, it'll set the bedtime instead of waketime.
  Future<void> modifyDateTime(bool isBedtime) async {
    DateTime initialDateTime;
    if (isBedtime) {
      initialDateTime = _dayOfSleep?.start ?? DateTime.now();
    } else {
      initialDateTime = _dayOfSleep?.end ?? DateTime.now();
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2200),
    );

    // give up if the user wimped out
    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );

    // give up if the user wimped out AGAIN
    if (pickedTime == null || !mounted) return;

    DateTime result;
    // when day and time are selected, set it to either bedtime or waketime, then update all that stuff
    setState(() {
      result = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      if (isBedtime) {
        _dayOfSleep?.setStart(result);
      } else {
        _dayOfSleep?.setEnd(result);
      }
      reloadDayOfSleepData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // used for percentage-based screen sizing
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Day Overview')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: screenWidth * 0.15,
                    ),
                    child: SizedBox(
                      height: 120,
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
                  Text(
                    pieChartTouchedIndex != -1
                        ? '${pieChartData[pieChartTouchedIndex]['label']} for ${(pieChartData[pieChartTouchedIndex]['value'] / 60.0).toStringAsFixed(2)} hours'
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          enabled: true,
                          touchCallback:
                              (
                                FlTouchEvent event,
                                PieTouchResponse? pieTouchResponse,
                              ) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    pieChartTouchedIndex = -1;
                                    return;
                                  }
                                  pieChartTouchedIndex = pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                                });
                              },
                        ),
                        sectionsSpace: 4,
                        centerSpaceRadius: 0,
                        sections: [
                          PieChartSectionData(
                            // Screen time
                            value: pieChartData[0]["value"].toDouble(),
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
                            value: pieChartData[1]["value"].toDouble(),
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
                            value: pieChartData[2]["value"].toDouble(),
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
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: screenWidth * 0.15,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        modifyDateTime(true);
                      },
                      icon: const Icon(Icons.edit_calendar),
                      label: Text('Bedtime'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: screenWidth * 0.15,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        modifyDateTime(false);
                      },
                      icon: const Icon(Icons.edit_calendar),
                      label: Text('Wakeup Time'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: screenWidth * 0.15,
                    ),
                    child: Text("Screen Time"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: screenWidth * 0.15,
                    ),
                    child: SizedBox(
                      height: 120,
                      child: CupertinoTimerPicker(
                        mode: CupertinoTimerPickerMode
                            .hm, // Hours and minutes only
                        initialTimerDuration: Duration(
                          days: 0,
                          hours: (screenTime / 60).toInt(),
                          minutes: screenTime % 60,
                          seconds: 0,
                        ),
                        onTimerDurationChanged: (Duration newDuration) {
                          setState(() {
                            _dayOfSleep?.screenTime = newDuration.inMinutes;
                            reloadDayOfSleepData();
                          });
                        },
                      ),
                    ),
                    //child: ElevatedButton.icon(
                    //onPressed: () {
                    //debugPrint('Add button pressed');
                    //},
                    //icon: const Icon(Icons.edit),
                    //label: Text(
                    //'Screentime: ' +
                    // (screenTime / 60.0).toStringAsFixed(2) +
                    //' hours',
                    //),
                    //),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: screenWidth * 0.15,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 256),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            StarRatingWidget(
                              onRatingChanged: (newRating) {
                                changeStarRating(newRating);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
