import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/sleep_log.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CollectionReference<Map<String, dynamic>>? _sleepLogs;
  DateTime _selected = DateUtils.dateOnly(DateTime.now());
  late DateTime _month;
  Stream<List<SleepLog>>? _logs;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _sleepLogs = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sleepLogs');
    }
    _month = DateTime(_selected.year, _selected.month);
    _loadMonth();
  }

  void _loadMonth() {
    // Read only the entries whose wake-up time is in this month.
    _logs = _sleepLogs
        ?.where('end', isGreaterThanOrEqualTo: Timestamp.fromDate(_month))
        .where(
          'end',
          isLessThan: Timestamp.fromDate(
            DateTime(_month.year, _month.month + 1),
          ),
        )
        .orderBy('end')
        .snapshots()
        .map((snapshot) {
          final logs = <SleepLog>[];
          for (final document in snapshot.docs) {
            logs.add(SleepLog.fromDocument(document));
          }
          return logs;
        });
  }

  void _moveMonth(int offset) {
    setState(() {
      _month = DateTime(_month.year, _month.month + offset);
      _selected = _month;
      _loadMonth();
    });
  }

  Future<void> _edit([SleepLog? log]) async {
    final result = await showDialog<SleepLog>(
      context: context,
      builder: (_) => _SleepLogDialog(day: _selected, log: log),
    );
    if (result == null || !mounted) return;
    try {
      if (result.id.isEmpty) {
        await _sleepLogs!.add(result.toMap());
      } else {
        await _sleepLogs!.doc(result.id).update(result.toMap());
      }
      if (!mounted) return;
      setState(() {
        _selected = result.day;
        if (_month.year != result.day.year ||
            _month.month != result.day.month) {
          _month = DateTime(result.day.year, result.day.month);
          _loadMonth();
        }
      });
      _message('Sleep log saved.');
    } catch (_) {
      _message('Could not save your sleep log. Please try again.');
    }
  }

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> _delete(SleepLog log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete sleep log?'),
        content: const Text('This will permanently remove this sleep entry.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _sleepLogs!.doc(log.id).delete();
      _message('Sleep log deleted.');
    } catch (_) {
      _message('Could not delete your sleep log. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Calendar'),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _selected = DateUtils.dateOnly(DateTime.now());
              _month = DateTime(_selected.year, _selected.month);
              _loadMonth();
            }),
            child: const Text('Today'),
          ),
        ],
      ),
      floatingActionButton: _sleepLogs == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _edit(),
              icon: const Icon(Icons.add),
              label: const Text('Log sleep'),
            ),
      body: _sleepLogs == null
          ? const Center(child: Text('Sign in to view your sleep history.'))
          : StreamBuilder<List<SleepLog>>(
              stream: _logs,
              builder: (context, snapshot) {
                final logs = snapshot.data ?? [];
                final daily = <int, double>{};
                final selectedLogs = <SleepLog>[];
                double totalHours = 0;
                for (final log in logs) {
                  final day = log.day.day;
                  daily[day] = (daily[day] ?? 0) + log.hours;
                  totalHours += log.hours;
                  if (DateUtils.isSameDay(log.day, _selected)) {
                    selectedLogs.add(log);
                  }
                }
                double averageHours = 0;
                if (daily.isNotEmpty) {
                  averageHours = totalHours / daily.length;
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          tooltip: 'Previous month',
                          onPressed: () => _moveMonth(-1),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text(
                          localizations.formatMonthYear(_month),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          tooltip: 'Next month',
                          onPressed: () => _moveMonth(1),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    // A whole-number width prevents a Flutter calendar error
                    // on the Android emulator.
                    LayoutBuilder(
                      builder: (context, constraints) => Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: constraints.maxWidth.floorToDouble(),
                          child: CalendarDatePicker(
                            key: ValueKey(_selected),
                            initialDate: _selected,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2200),
                            onDateChanged: (day) =>
                                setState(() => _selected = day),
                            onDisplayedMonthChanged: (month) => setState(() {
                              _month = month;
                              _selected = month;
                              _loadMonth();
                            }),
                          ),
                        ),
                      ),
                    ),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const LinearProgressIndicator(),
                    if (snapshot.hasError) ...[
                      const Text(
                        'Could not load sleep history. Check your connection and try again.',
                      ),
                      TextButton(
                        onPressed: () => setState(_loadMonth),
                        child: const Text('Retry'),
                      ),
                    ] else if (snapshot.connectionState !=
                        ConnectionState.waiting) ...[
                      Text(
                        'Monthly sleep history',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        daily.isEmpty
                            ? 'No sleep logged this month. Add your first entry below.'
                            : '${logs.length} entries · ${averageHours.toStringAsFixed(1)} hours average per logged day',
                      ),
                      const Text(
                        'Sleep is grouped by wake-up date. Tap a bar to view that day.',
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: _SleepChart(
                          month: _month,
                          daily: daily,
                          onSelect: (day) => setState(
                            () => _selected = DateTime(
                              _month.year,
                              _month.month,
                              day,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        localizations.formatFullDate(_selected),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (selectedLogs.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('No sleep logged for this day.'),
                        ),
                      for (final log in selectedLogs)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${log.hours.toStringAsFixed(1)} hours',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                Text(
                                  '${localizations.formatShortDate(log.start)} ${TimeOfDay.fromDateTime(log.start).format(context)} – ${localizations.formatShortDate(log.end)} ${TimeOfDay.fromDateTime(log.end).format(context)}',
                                ),
                                if (log.notes.isNotEmpty) Text(log.notes),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _edit(log),
                                      icon: const Icon(Icons.edit_outlined),
                                      label: const Text('Edit'),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _delete(log),
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
    );
  }
}

class _SleepChart extends StatelessWidget {
  const _SleepChart({
    required this.month,
    required this.daily,
    required this.onSelect,
  });
  final DateTime month;
  final Map<int, double> daily;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    double maxHours = 10;
    final bars = <BarChartGroupData>[];
    for (int day = 1; day <= days; day++) {
      final hours = daily[day] ?? 0;
      if (hours > maxHours) {
        maxHours = hours;
      }
      bars.add(
        BarChartGroupData(
          x: day,
          barRods: [
            BarChartRodData(
              toY: hours,
              color: Theme.of(context).colorScheme.primary,
              width: 6,
            ),
          ],
        ),
      );
    }
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxHours + 1,
        alignment: BarChartAlignment.spaceAround,
        barGroups: bars,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text('Hours'),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 2,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) =>
                  value == 1 || value.toInt() % 5 == 0
                  ? Text(value.toInt().toString())
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchCallback: (event, response) {
            if (event is FlTapUpEvent && response?.spot != null) {
              onSelect(response!.spot!.touchedBarGroup.x);
            }
          },
        ),
      ),
    );
  }
}

class _SleepLogDialog extends StatefulWidget {
  const _SleepLogDialog({required this.day, this.log});
  final DateTime day;
  final SleepLog? log;

  @override
  State<_SleepLogDialog> createState() => _SleepLogDialogState();
}

class _SleepLogDialogState extends State<_SleepLogDialog> {
  late DateTime _start;
  late DateTime _end;
  late final TextEditingController _notes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _end =
        widget.log?.end ??
        DateTime(widget.day.year, widget.day.month, widget.day.day, 7);
    _start =
        widget.log?.start ??
        DateTime(widget.day.year, widget.day.month, widget.day.day - 1, 23);
    _notes = TextEditingController(text: widget.log?.notes ?? '');
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pick(bool start) async {
    final current = start ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null || !mounted) return;
    setState(() {
      final value = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (start) {
        _start = value;
      } else {
        _end = value;
      }
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels = MaterialLocalizations.of(context);
    String format(DateTime date) =>
        '${labels.formatShortDate(date)} ${TimeOfDay.fromDateTime(date).format(context)}';
    return AlertDialog(
      title: Text(widget.log == null ? 'Log sleep' : 'Edit sleep log'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton(
              onPressed: () => _pick(true),
              child: Text('Bedtime: ${format(_start)}'),
            ),
            OutlinedButton(
              onPressed: () => _pick(false),
              child: Text('Wake-up: ${format(_end)}'),
            ),
            TextField(
              controller: _notes,
              maxLength: 1000,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_end.isAfter(_start) ||
                _end.difference(_start) > const Duration(hours: 24)) {
              setState(
                () =>
                    _error = 'Wake-up must be after bedtime, within 24 hours.',
              );
            } else if (_end.isAfter(DateTime.now())) {
              setState(() => _error = 'Choose a wake-up time in the past.');
            } else {
              Navigator.pop(
                context,
                SleepLog(
                  id: widget.log?.id ?? '',
                  start: _start,
                  end: _end,
                  notes: _notes.text.trim(),
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
