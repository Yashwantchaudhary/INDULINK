import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../models/order.dart';

/// Order status timeline widget
class OrderStatusTimeline extends StatelessWidget {
  final Order order;

  const OrderStatusTimeline({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = _getTimelineSteps();

    return Card(
      child: Padding(
        padding: AppConstants.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Status',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(steps.length, (index) {
              final step = steps[index];
              final isLast = index == steps.length - 1;
              return _buildTimelineStep(
                step['title']!,
                step['subtitle'],
                step['isCompleted'] as bool,
                step['isCurrent'] as bool,
                !isLast,
                theme,
              );
            }),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getTimelineSteps() {
    final currentStatusIndex = _getStatusIndex(order.status);
    final dateFormat = DateFormat('MMM dd, hh:mm a');

    return [
      {
        'title': 'Order Placed',
        'subtitle': dateFormat.format(order.createdAt),
        'isCompleted': true,
        'isCurrent': currentStatusIndex == 0,
      },
      {
        'title': 'Confirmed',
        'subtitle': order.confirmedAt != null
            ? dateFormat.format(order.confirmedAt!)
            : null,
        'isCompleted': currentStatusIndex >= 1,
        'isCurrent': currentStatusIndex == 1,
      },
      {
        'title': 'Processing',
        'subtitle': null,
        'isCompleted': currentStatusIndex >= 2,
        'isCurrent': currentStatusIndex == 2,
      },
      {
        'title': 'Shipped',
        'subtitle': order.shippedAt != null
            ? dateFormat.format(order.shippedAt!)
            : null,
        'isCompleted': currentStatusIndex >= 3,
        'isCurrent': currentStatusIndex == 3,
      },
      {
        'title': 'Delivered',
        'subtitle': order.deliveredAt != null
            ? dateFormat.format(order.deliveredAt!)
            : null,
        'isCompleted': currentStatusIndex >= 5,
        'isCurrent': currentStatusIndex == 5,
      },
    ];
  }

  int _getStatusIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.processing:
        return 2;
      case OrderStatus.shipped:
        return 3;
      case OrderStatus.outForDelivery:
        return 4;
      case OrderStatus.delivered:
        return 5;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return -1; // Special handling
    }
  }

  Widget _buildTimelineStep(
    String title,
    String? subtitle,
    bool isCompleted,
    bool isCurrent,
    bool hasLine,
    ThemeData theme,
  ) {
    final iconColor = isCompleted
        ? AppColors.success
        : isCurrent
            ? AppColors.primaryBlue
            : Colors.grey.shade300;

    final lineColor = isCompleted ? AppColors.success : Colors.grey.shade300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon and Line
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                color: Colors.white,
                size: 16,
              ),
            ),
            if (hasLine)
              Container(
                width: 2,
                height: 40,
                color: lineColor,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                    color: isCompleted || isCurrent ? null : Colors.grey,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
