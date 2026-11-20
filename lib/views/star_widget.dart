import 'package:awesome_honk_shoo_app/models/day_overview_model.dart';
import 'package:flutter/material.dart';

class StarRatingWidget extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int> onRatingChanged;

  // referenced for the actual rating values

  StarRatingWidget({
    Key? key,
    this.initialRating = 3,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  _StarRatingWidgetState createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  late int _currentRating;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  Future<void> _handleStarTap(int selectedRating) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the external callback passed from the parent widget
      widget.onRatingChanged(selectedRating);

      setState(() {
        _currentRating = selectedRating;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isLoading ? 0.6 : 1.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          int starIndex = index + 1;
          return IconButton(
            icon: Icon(
              starIndex <= _currentRating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 32,
            ),
            // Disable buttons while waiting for the backend response
            onPressed: _isLoading ? null : () => _handleStarTap(starIndex),
          );
        }),
      ),
    );
  }
}
