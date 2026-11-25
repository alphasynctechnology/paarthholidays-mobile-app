import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/tour_model.dart';
import '../../../utils/auth_guard.dart';
import '../../../widgets/common/app_bar.dart';
import '../home_controller.dart';
import '../leads/create_lead_screen.dart';

class GroupTourDetailScreen extends StatelessWidget {
  final TourModel tour;

  const GroupTourDetailScreen({super.key, required this.tour});

  void _goToEnquiry() async {
    final allowed = await AuthGuard.requireLogin(
      message: 'Please login to raise an enquiry for this tour.',
    );
    if (!allowed) return;

    final homeController = Get.find<HomeController>();
    await homeController.changeTabIndex(2);
    Get.back();
    Get.to(() => const CreateLeadScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kSurfaceColor,
      appBar: CommonAppBar(
        title: tour.name,
        showWalletIcon: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tour.image.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 16 / 10,
                      child: CachedNetworkImage(
                        imageUrl: tour.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => Container(
                          color: AppColors.border,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.border,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tour.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (tour.location.isNotEmpty)
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Destination',
                            value: tour.location,
                          ),
                        if (tour.departureDate.isNotEmpty)
                          _InfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Departure',
                            value: tour.departureDate,
                          ),
                        if (tour.duration.isNotEmpty)
                          _InfoRow(
                            icon: Icons.timelapse_outlined,
                            label: 'Duration',
                            value: tour.duration,
                          ),
                        if (tour.price.isNotEmpty)
                          _InfoRow(
                            icon: Icons.payments_outlined,
                            label: 'Starting from',
                            value: tour.price,
                          ),
                        if (tour.description.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'About this tour',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tour.description,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _goToEnquiry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Enquire Now',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
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
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
