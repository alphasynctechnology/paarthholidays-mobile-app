import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/common/app_bar.dart';
import 'booking_list_controller.dart';
import 'widgets/enquiry_card.dart';

class BookingListScreen extends GetView<BookingListController> {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BookingListController()).fetchBookings();

    return Scaffold(
      backgroundColor: AppColors.kSurfaceColor,
      appBar: const CommonAppBar(
        title: 'My Bookings',
        showBackButton: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if ((controller.error?.value ?? '').isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.primary, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    controller.error?.value ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.fetchBookings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.luggage_outlined,
                  size: 56,
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No bookings found',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchBookings,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
            itemCount: controller.bookings.length,
            itemBuilder: (context, index) {
              return BookingCard(enquiry: controller.bookings[index]);
            },
          ),
        );
      }),
    );
  }
}
