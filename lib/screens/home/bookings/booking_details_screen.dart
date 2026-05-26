import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/enquiry_details_model.dart';
import '../../../../widgets/activities_list.dart';
import '../../../../widgets/hotels_list.dart';
import '../../../../widgets/members_list.dart';
import '../../../../widgets/payments_list.dart';
import '../../../../widgets/vehicles_list.dart';
import '../../../../controllers/enquiry_details_controller.dart';
import 'widgets/booking_detail_components.dart';
import 'widgets/booking_feedback_sheet.dart';
import 'widgets/booking_payment_summary.dart';
import 'pdf_viewer_screen.dart';
import '../../wallet/wallet_screen.dart';

class BookingDetailsScreen extends StatelessWidget {
  final String enquiryId;
  final EnquiryDetailsController controller = Get.put(EnquiryDetailsController());

  BookingDetailsScreen({
    super.key,
    required this.enquiryId,
  }) {
    controller.fetchEnquiryDetails(enquiryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kSurfaceColor,
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () => Get.to(() => const WalletScreen()),
            tooltip: 'Wallet',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return _ErrorView(
            message: controller.error.value,
            onRetry: () => controller.fetchEnquiryDetails(enquiryId),
          );
        }

        if (controller.enquiryDetails.value == null) {
          return const Center(child: Text('No details available'));
        }

        final details = controller.enquiryDetails.value!;
        final showFeedback = controller.showFeedbackButton;
        final paymentSummary = details.paymentSummary;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 0, 16, showFeedback ? 100 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroHeader(details: details),
                  const SizedBox(height: 20),
                  if (paymentSummary != null) ...[
                    BookingPaymentSummary(summary: paymentSummary),
                    const SizedBox(height: 20),
                  ],
                  if (details.quotationUrl.isNotEmpty) ...[
                    _QuotationButton(
                      onTap: () => Get.to(
                        () => PDFViewerScreen(
                          pdfUrl: details.quotationUrl,
                          title: 'Quotation',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  BookingSectionCard(
                    title: 'Travel Details',
                    icon: Icons.luggage_outlined,
                    child: Row(
                      children: [
                        BookingStatTile(
                          icon: Icons.bed_outlined,
                          value: '${details.noOfRooms}',
                          label: 'Rooms',
                        ),
                        BookingStatTile(
                          icon: Icons.person_outline,
                          value: '${details.noOfAdults}',
                          label: 'Adults',
                        ),
                        BookingStatTile(
                          icon: Icons.child_care_outlined,
                          value: '${details.noOfChilds}',
                          label: 'Children',
                        ),
                      ],
                    ),
                  ),
                  MembersList(members: details.members),
                  if (details.hotels.isNotEmpty)
                    HotelsList(
                      hotels: details.hotels,
                      showVouchers: details.booking.canViewVouchers,
                    ),
                  if (details.activities.isNotEmpty)
                    ActivitiesList(activities: details.activities),
                  if (details.vehicle.isNotEmpty)
                    VehiclesList(
                      vehicles: details.vehicle,
                      showVouchers: details.booking.canViewVouchers,
                    ),
                  if (details.payments.isNotEmpty)
                    PaymentsList(payments: details.payments),
                ],
              ),
            ),
            if (showFeedback)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: SafeArea(
                  top: false,
                  child: _FeedbackFooterButton(
                    onTap: () async {
                      final submitted = await BookingFeedbackSheet.show(
                        details: details,
                        enquiryId: enquiryId,
                      );
                      if (submitted == true) {
                        controller.markFeedbackSubmitted();
                      }
                    },
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final EnquiryDetailsModel details;

  const _HeroHeader({required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.kPrimaryVariant],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              details.booking.planName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    if (details.booking.uniqueEnquiryId.isNotEmpty)
                      Expanded(
                        child: _IdColumn(
                          label: 'Enquiry ID',
                          value: details.booking.uniqueEnquiryId,
                        ),
                      ),
                    if (details.booking.uniqueEnquiryId.isNotEmpty &&
                        details.booking.displayBookingId.isNotEmpty)
                      VerticalDivider(
                        width: 24,
                        thickness: 1,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    if (details.booking.displayBookingId.isNotEmpty)
                      Expanded(
                        child: _IdColumn(
                          label: 'Booking ID',
                          value: details.booking.displayBookingId,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _InfoChip(
              icon: Icons.calendar_today_outlined,
              label: details.booking.departureDate,
            ),
          ],
        ),
    );
  }
}

class _IdColumn extends StatelessWidget {
  final String label;
  final String value;

  const _IdColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackFooterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FeedbackFooterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: AppColors.primary.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.kPrimaryVariant],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_outlined, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Give Feedback',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuotationButton extends StatelessWidget {
  final VoidCallback onTap;

  const _QuotationButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
                SizedBox(width: 10),
                Text(
                  'View Quotation',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.primary, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
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
}
