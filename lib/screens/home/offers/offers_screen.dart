import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/tour_model.dart';
import '../../../widgets/common/app_bar.dart';
import '../bookings/booking_details_screen.dart';
import '../home_content_controller.dart';
import '../widgets/home_today_itinerary_card.dart';
import '../widgets/home_news_card.dart';
import '../widgets/home_section_header.dart';
import '../widgets/home_tour_card.dart';
import '../widgets/offers_carousel.dart';
import 'group_tour_detail_screen.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onTourTap(TourModel tour, {bool isGroupTour = false}) {
    if (isGroupTour) {
      Get.to(() => GroupTourDetailScreen(tour: tour));
      return;
    }
    if (tour.url.isNotEmpty) {
      _openUrl(tour.url);
      return;
    }
    if (tour.id.isNotEmpty) {
      Get.to(() => BookingDetailsScreen(enquiryId: tour.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeContentController());

    return Scaffold(
      backgroundColor: AppColors.kSurfaceColor,
      appBar: const CommonAppBar(
        title: 'Home',
        showBackButton: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.offers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty &&
            controller.offers.isEmpty &&
            controller.groupTours.isEmpty) {
          return _ErrorState(
            message: controller.error.value,
            onRetry: controller.fetchHomeData,
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchHomeData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              const _WelcomeBanner(),
              if (controller.todayItinerary.value != null)
                HomeTodayItineraryCard(
                  itinerary: controller.todayItinerary.value!,
                  onTap: () => Get.to(
                    () => BookingDetailsScreen(
                      enquiryId: controller.todayItinerary.value!.enquiryId,
                    ),
                  ),
                ),
              if (controller.offers.isNotEmpty) ...[
                const HomeSectionHeader(
                  title: 'Special Offers',
                  subtitle: 'Exclusive deals on top destinations',
                  icon: Icons.local_offer_outlined,
                ),
                OffersCarousel(
                  offers: controller.offers,
                  onOfferTap: (offer) => _openUrl(offer.url),
                ),
              ],
              _TourSection(
                title: 'Previous Tours',
                subtitle: 'Trips you have completed',
                icon: Icons.history,
                tours: controller.previousTours,
                maxItems: 3,
                emptyMessage: 'No past tours to show.',
                emptyActionLabel: 'View Bookings',
                onEmptyAction: controller.goToBookings,
                onSeeAll: controller.goToBookings,
                onTourTap: (tour) => _onTourTap(tour),
              ),
              _TourSection(
                title: 'Group Tours',
                subtitle: 'Join group departures & save more',
                icon: Icons.groups_outlined,
                tours: controller.groupTours,
                cardStyle: HomeTourCardStyle.poster,
                listHeight: 330,
                cardWidth: 220,
                emptyMessage: 'Group tour packages coming soon.',
                onSeeAll: controller.goToEnquiry,
                onTourTap: (tour) => _onTourTap(tour, isGroupTour: true),
              ),
              const HomeSectionHeader(
                title: 'News & Updates',
                subtitle: 'Latest from Paarth Holidays',
                icon: Icons.newspaper_outlined,
              ),
              if (controller.news.isNotEmpty)
                ...controller.news.map(
                  (item) => HomeNewsCard(
                    item: item,
                    onTap: () => HomeNewsCard.showDetail(context, item),
                  ),
                )
              else
                const _EmptySection(message: 'No news at the moment.'),
            ],
          ),
        );
      }),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.kPrimaryVariant],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Paarth Holidays',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore tours, offers & travel updates',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.travel_explore,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _TourSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<TourModel> tours;
  final String emptyMessage;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;
  final VoidCallback? onSeeAll;
  final void Function(TourModel tour) onTourTap;
  final HomeTourCardStyle cardStyle;
  final double listHeight;
  final double cardWidth;
  final int? maxItems;

  const _TourSection({
    required this.title,
    this.subtitle,
    this.icon,
    required this.tours,
    required this.emptyMessage,
    this.emptyActionLabel,
    this.onEmptyAction,
    this.onSeeAll,
    required this.onTourTap,
    this.cardStyle = HomeTourCardStyle.standard,
    this.listHeight = 280,
    this.cardWidth = 240,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    final visibleTours = maxItems != null && maxItems! > 0
        ? tours.take(maxItems!).toList()
        : tours;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: title,
          subtitle: subtitle,
          icon: icon,
          actionLabel: tours.isNotEmpty ? 'See All' : null,
          onAction: tours.isNotEmpty ? onSeeAll : null,
        ),
        if (visibleTours.isEmpty)
          _EmptySection(
            message: emptyMessage,
            actionLabel: emptyActionLabel,
            onAction: onEmptyAction,
          )
        else
          SizedBox(
            height: listHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: visibleTours.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return HomeTourCard(
                  tour: visibleTours[index],
                  style: cardStyle,
                  width: cardWidth,
                  height: listHeight,
                  onTap: () => onTourTap(visibleTours[index]),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptySection({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.travel_explore,
            size: 40,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
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
