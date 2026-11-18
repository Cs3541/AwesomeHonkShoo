// Explains calendar colors and markers without occupying screen space.
import 'package:flutter/material.dart';

import '../models/calendar_model.dart';
import 'calendar_styles.dart';

// Owns only legend layout; it has no data subscriptions or mutable state.
class CalendarLegendDialog extends StatelessWidget {
  const CalendarLegendDialog({super.key});

  // Allow long legend content to scroll on small screens or with larger text.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Legend'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sleep duration • grouped by wake-up day'),
            const SizedBox(height: 12),
            // Reuse the same colors and duration labels as the calendar cells.
            for (final band in SleepDurationBand.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: calendarBandColor(band),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(calendarBandLabel(band))),
                  ],
                ),
              ),
            const Divider(),
            // Explain search highlights and the independent date markers.
            const Row(
              children: [
                Icon(Icons.circle, color: calendarMatchColor, size: 18),
                SizedBox(width: 10),
                Expanded(child: Text('Blue: search or rating filter match')),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Outer ring: selected day'),
            const SizedBox(height: 8),
            const Text('Extra-bold, underlined number: today'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
