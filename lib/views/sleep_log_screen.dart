import 'package:flutter/material.dart';
import '../models/sleep_log_model.dart';
import '../presenters/sleep_log_presenter.dart';

class SleepLogScreen extends StatefulWidget {
  const SleepLogScreen({super.key});

  @override
  State<SleepLogScreen> createState() => _SleepLogScreenState();
}

class _SleepLogScreenState extends State<SleepLogScreen> {
  final SleepLogPresenter _presenter = SleepLogPresenter();

  DateTime? _sleepTime;
  DateTime? _wakeTime;

  final TextEditingController _qualityController =
      TextEditingController();

  final TextEditingController _notesController =
      TextEditingController();

  Future<void> _pickSleepTime() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _sleepTime = picked;
      });
    }
  }

  Future<void> _pickWakeTime() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _wakeTime = picked;
      });
    }
  }

  Future<void> _saveSleepLog() async {
    if (_sleepTime == null || _wakeTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select sleep and wake times'),
        ),
      );
      return;
    }

    final quality = double.tryParse(_qualityController.text);

    if (quality == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid sleep quality'),
        ),
      );
      return;
    }

    final log = SleepLog(
      id: '',
      sleepTime: _sleepTime!,
      wakeTime: _wakeTime!,
      quality: quality,
      notes: _notesController.text,
    );

    await _presenter.saveSleepLog(log);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sleep log saved'),
      ),
    );

    _qualityController.clear();
    _notesController.clear();

    setState(() {
      _sleepTime = null;
      _wakeTime = null;
    });
  }

  @override
  void dispose() {
    _qualityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickSleepTime,
              child: Text(
                _sleepTime == null
                    ? 'Select Sleep Time'
                    : 'Sleep: ${_sleepTime.toString()}',
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _pickWakeTime,
              child: Text(
                _wakeTime == null
                    ? 'Select Wake Time'
                    : 'Wake: ${_wakeTime.toString()}',
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _qualityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Sleep Quality',
                hintText: 'Example: 8',
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveSleepLog,
              child: const Text('Save Sleep Log'),
            ),
          ],
        ),
      ),
    );
  }
}