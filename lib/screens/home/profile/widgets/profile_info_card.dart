import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/profile_model.dart';

class ProfileInfoCard extends StatelessWidget {
  final ProfileModel profile;
  final String mobileFallback;

  const ProfileInfoCard({
    super.key,
    required this.profile,
    this.mobileFallback = '',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildInfoRow(
              Icons.person_outline,
              'Name',
              profile.displayName('Guest'),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.email_outlined,
              'Email',
              profile.displayEmail(),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.phone_outlined,
              'Mobile',
              profile.displayMobile(mobileFallback),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final isPlaceholder = value == 'Not set';

    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isPlaceholder
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
