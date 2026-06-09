import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final AppNotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'payment_reminder':
        return Icons.payments_outlined;
      case 'tour_start':
        return Icons.flight_takeoff_outlined;
      case 'daily_activity':
        return Icons.map_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _iconColorForType(String type) {
    switch (type) {
      case 'payment_reminder':
        return const Color(0xFFE65100);
      case 'tour_start':
        return const Color(0xFF1565C0);
      case 'daily_activity':
        return const Color(0xFF2E7D32);
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) {
      return '';
    }

    try {
      final parsed = DateTime.parse(raw);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final date = DateTime(parsed.year, parsed.month, parsed.day);

      if (date == today) {
        return DateFormat('h:mm a').format(parsed);
      }
      if (date == today.subtract(const Duration(days: 1))) {
        return 'Yesterday';
      }
      return DateFormat('d MMM, h:mm a').format(parsed);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _iconColorForType(notification.type);

    return Material(
      color: notification.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.04),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForType(notification.type),
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (notification.createdDate.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(notification.createdDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (notification.enquiryId > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 10),
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
