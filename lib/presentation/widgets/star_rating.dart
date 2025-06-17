import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int currentRating;
  final double iconSize;
  final double horizontalPadding;
  final Function(int)? setRating;
  final MainAxisAlignment alignment;

  const StarRating({
    super.key,
    required this.currentRating,
    this.iconSize = 32,
    this.horizontalPadding = 4,
    this.setRating,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: List.generate(5, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: SizedBox.square(
            dimension: iconSize,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                index < currentRating ? Icons.star : Icons.star_border,
                size: iconSize,
                color: index < currentRating ? Colors.black : Colors.black,
              ),
              onPressed:
                  setRating == null
                      ? null
                      : () {
                        final selectedRating = index + 1;
                        // If the same star is pressed, reset to 0, otherwise set the new rating
                        setRating!(
                          selectedRating == currentRating ? 0 : selectedRating,
                        );
                      },
            ),
          ),
        );
      }),
    );
  }
}
