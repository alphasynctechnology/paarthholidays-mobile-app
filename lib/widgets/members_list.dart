import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../models/enquiry_details_model.dart';
import '../screens/home/bookings/widgets/booking_detail_components.dart';

class MembersList extends StatelessWidget {
  final List<Member> members;

  const MembersList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    return BookingSectionCard(
      title: 'Members',
      icon: Icons.groups_outlined,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${members.length}',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < members.length; i++)
            _MemberCard(
              member: members[i],
              index: i + 1,
              isLast: i == members.length - 1,
            ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final Member member;
  final int index;
  final bool isLast;

  const _MemberCard({
    required this.member,
    required this.index,
    required this.isLast,
  });

  bool get _isMale {
    final g = member.gender.trim().toLowerCase();
    return g == 'm' || g == 'male' || g == '1';
  }

  Color get _genderColor =>
      _isMale ? AppColors.primary : AppColors.kPrimaryVariant;

  String get _initials {
    final parts = member.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatAge(int age) {
    if (age <= 0) return 'Infant';
    if (age == 1) return '1 year';
    return '$age years';
  }

  String? _mealLabel(String mealType) {
    if (mealType.isEmpty || mealType == '0') return null;
    final lower = mealType.toLowerCase();
    if (lower.contains('veg') && !lower.contains('non')) return 'Veg';
    if (lower.contains('non')) return 'Non-Veg';
    return mealType;
  }

  int _calculateAge(String dob) {
    try {
      final birthDate = DateTime.parse(dob);
      final today = DateTime.now();
      var age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age < 0 ? 0 : age;
    } catch (_) {
      return 0;
    }
  }

  String _formatDob(String dob) {
    try {
      final date = DateTime.parse(dob);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dob;
    }
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final age = _calculateAge(member.dob);
    final mealLabel = _mealLabel(member.mealType);
    final genderLabel = _isMale ? 'Male' : 'Female';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _genderColor, width: 2),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: _genderColor.withValues(alpha: 0.1),
                  child: Text(
                    _initials,
                    style: TextStyle(
                      color: _genderColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            member.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.kSurfaceColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Traveler $index',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _DetailChip(
                          icon: _isMale ? Icons.male : Icons.female,
                          label: genderLabel,
                          color: _genderColor,
                        ),
                        _DetailChip(
                          icon: Icons.cake_outlined,
                          label: _formatAge(age),
                          color: AppColors.primary,
                        ),
                        if (member.dob.isNotEmpty)
                          _DetailChip(
                            icon: Icons.event_outlined,
                            label: _formatDob(member.dob),
                            color: AppColors.textSecondary,
                          ),
                        if (mealLabel != null)
                          _DetailChip(
                            icon: mealLabel == 'Veg'
                                ? Icons.eco_outlined
                                : Icons.restaurant_outlined,
                            label: mealLabel,
                            color: mealLabel == 'Veg'
                                ? const Color(0xFF6B8E23)
                                : AppColors.primary,
                          ),
                        if (member.perPersonCost.isNotEmpty &&
                            member.perPersonCost != '0')
                          _DetailChip(
                            icon: Icons.payments_outlined,
                            label: '₹${member.perPersonCost}',
                            color: AppColors.kPrimaryVariant,
                          ),
                      ],
                    ),
                    if (member.contactNumber.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Material(
                        color: AppColors.kSurfaceColor,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () => _callNumber(member.contactNumber),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: 16,
                                  color: _genderColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  member.contactNumber,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _genderColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 11,
                                  color: _genderColor.withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const SizedBox(height: 10),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
