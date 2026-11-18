// Renders draft search controls; state and future integration stay in the presenter.
import 'package:flutter/material.dart';

import '../presenters/calendar_presenter.dart';

// This view uses the screen-owned presenter and never disposes it.
class CalendarSearchControls extends StatelessWidget {
  // Receive the same presenter as the screen so all controls share state.
  const CalendarSearchControls({super.key, required this.presenter});

  final CalendarPresenter presenter;

  // Present the future search area while clearly marking its unconnected state.
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accept draft search text without reading or searching saved notes.
            TextFormField(
              initialValue: presenter.journalQuery,
              onChanged: presenter.updateJournalQuery,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Search journal entries',
                hintText: 'Enter a word or phrase',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            // Allow the draft filter to be selected without filtering real data.
            Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Keep Any last in the menu and map it to null in the model.
                SizedBox(
                  width: 180,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Star rating',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: presenter.selectedRating ?? -1,
                        isExpanded: true,
                        items: [
                          for (int rating = 0; rating <= 5; rating++)
                            DropdownMenuItem(
                              value: rating,
                              child: Text(
                                '$rating ${rating == 1 ? 'star' : 'stars'}',
                              ),
                            ),
                          const DropdownMenuItem(value: -1, child: Text('Any')),
                        ],
                        onChanged: (value) => presenter.setSelectedRating(
                          value == -1 ? null : value,
                        ),
                      ),
                    ),
                  ),
                ),
                // Keep Search visibly unavailable until its data source is ready.
                FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Search and rating filters are not connected yet.'),
          ],
        ),
      ),
    );
  }
}
