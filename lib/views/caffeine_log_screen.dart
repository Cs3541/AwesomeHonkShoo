import 'package:flutter/material.dart';

class CaffeineLogScreen extends StatefulWidget {
  const CaffeineLogScreen({super.key});

  @override
  State<CaffeineLogScreen> createState() => _CaffeineLogScreenState();
}

class _CaffeineLogScreenState extends State<CaffeineLogScreen> {
  TimeOfDay? _intakeTime;
  final TextEditingController _quantityController =
      TextEditingController();

  Future<void> _selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        _intakeTime = selectedTime;
      });
    }
  }

  void _saveCaffeineLog() {
    if (_intakeTime == null ||
        _quantityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the intake time and quantity.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Caffeine log recorded.'),
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caffeine Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _selectTime,
              child: Text(
                _intakeTime == null
                    ? 'Select Intake Time'
                    : 'Time: ${_intakeTime!.format(context)}',
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Caffeine Quantity',
                hintText: 'Example: 100 mg',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveCaffeineLog,
              child: const Text('Save Log'),
            ),
          ],
        ),
      ),
    );
  }
}