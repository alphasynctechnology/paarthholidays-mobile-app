import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/enquiry_details_model.dart';
import '../screens/home/bookings/widgets/booking_detail_components.dart';
import '../core/theme/app_colors.dart';

class ActivitiesList extends StatelessWidget {
  final List<Activity> activities;

  const ActivitiesList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return BookingSectionCard(
      title: 'Itinerary',
      icon: Icons.explore_outlined,
      child: Column(
        children: [
          for (var i = 0; i < activities.length; i++)
            _ActivityTimelineItem(
              activity: activities[i],
              isLast: i == activities.length - 1,
            ),
        ],
      ),
    );
  }
}

class _ActivityTimelineItem extends StatefulWidget {
  final Activity activity;
  final bool isLast;

  const _ActivityTimelineItem({
    required this.activity,
    required this.isLast,
  });

  @override
  State<_ActivityTimelineItem> createState() => _ActivityTimelineItemState();
}

class _ActivityTimelineItemState extends State<_ActivityTimelineItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.activity.day,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 16),
              child: BookingInnerCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.activity.plan,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (widget.activity.destName.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.activity.destName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    Html(
                      data: widget.activity.activity,
                      style: {
                        'body': Style(
                          margin: Margins.zero,
                          fontSize: FontSize(13),
                          lineHeight: LineHeight(1.45),
                          padding: HtmlPaddings.zero,
                          maxLines: isExpanded ? null : 4,
                          textOverflow: isExpanded ? null : TextOverflow.ellipsis,
                          color: AppColors.textSecondary,
                        ),
                        'p': Style(margin: Margins(bottom: Margin(6))),
                        'b': Style(fontWeight: FontWeight.bold),
                      },
                    ),
                    if (widget.activity.activity.length > 120)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => setState(() => isExpanded = !isExpanded),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(isExpanded ? 'Show less' : 'Read more'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
