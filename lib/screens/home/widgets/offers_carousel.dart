import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/offer_model.dart';

class OffersCarousel extends StatelessWidget {
  final List<OfferModel> offers;
  final void Function(OfferModel offer)? onOfferTap;

  const OffersCarousel({
    super.key,
    required this.offers,
    this.onOfferTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Offer posters are portrait-style; use nearly square viewport so nothing is cropped.
    final slideWidth = screenWidth * 0.88;
    final slideHeight = slideWidth * 1.05;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FlutterCarousel(
        items: offers.map((offer) {
          return GestureDetector(
            onTap: onOfferTap != null ? () => onOfferTap!(offer) : null,
            child: Container(
              width: slideWidth,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ColoredBox(
                  color: Colors.white,
                  child: CachedNetworkImage(
                    imageUrl: offer.image,
                    fit: BoxFit.contain,
                    width: slideWidth,
                    height: slideHeight,
                    placeholder: (context, url) => SizedBox(
                      width: slideWidth,
                      height: slideHeight,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => SizedBox(
                      width: slideWidth,
                      height: slideHeight,
                      child: const Icon(Icons.broken_image_outlined, size: 48),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        options: CarouselOptions(
          showIndicator: true,
          height: slideHeight + 8,
          viewportFraction: 0.88,
          enlargeCenterPage: false,
          padEnds: true,
          autoPlay: offers.length > 1,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.easeInOut,
          slideIndicator: SequentialFillIndicator(),
        ),
      ),
    );
  }
}
