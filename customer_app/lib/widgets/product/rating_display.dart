import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Rating display widget with stars and review count
class RatingDisplay extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double size;
  final bool showCount;
  final Color? activeColor;
  final Color? inactiveColor;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 16,
    this.showCount = true,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Star icons
        ...List.generate(5, (index) {
          final starValue = index + 1;
          return Icon(
            starValue <= rating.floor()
                ? Icons.star
                : (starValue - 0.5 <= rating
                    ? Icons.star_half
                    : Icons.star_border),
            size: size,
            color: activeColor ?? AppColors.accentYellow,
          );
        }),

        if (showCount && reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ],
    );
  }
}
