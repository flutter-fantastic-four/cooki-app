import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int currentRating;
  final double iconSize;
  final Function(int) onPressed;
  final Color selectedColor;
  final Color unselectedColor;

  const StarRating({
    super.key,
    required this.currentRating,
    required this.iconSize,
    required this.onPressed,
    this.selectedColor = Colors.black,
    this.unselectedColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: SizedBox.square(
            dimension: iconSize,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                index < currentRating ? Icons.star : Icons.star_border,
                size: iconSize,
                color: index < currentRating ? selectedColor : unselectedColor,
              ),
              onPressed: () {
                final selectedRating = index + 1;
                // If the same star is pressed, reset to 0, otherwise set the new rating
                onPressed(selectedRating == currentRating ? 0 : selectedRating);
              },
            ),
          ),
        );
      }),
    );
  }
}
