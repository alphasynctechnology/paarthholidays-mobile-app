import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/enquiry_details_model.dart';
import '../../../../services/api_service.dart';

class BookingFeedbackSheet extends StatefulWidget {
  final EnquiryDetailsModel details;
  final String enquiryId;

  const BookingFeedbackSheet({
    super.key,
    required this.details,
    required this.enquiryId,
  });

  static Future<bool?> show({
    required EnquiryDetailsModel details,
    required String enquiryId,
  }) {
    return Get.bottomSheet<bool>(
      BookingFeedbackSheet(details: details, enquiryId: enquiryId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<BookingFeedbackSheet> createState() => _BookingFeedbackSheetState();
}

class _BookingFeedbackSheetState extends State<BookingFeedbackSheet> {
  final ApiService _apiService = ApiService();
  final _companyCommentController = TextEditingController();

  late final List<TextEditingController> _hotelCommentControllers;
  late final List<TextEditingController> _vehicleCommentControllers;
  late final List<Vehicle> _vehicleItems;

  int _companyRating = 0;
  late List<int> _hotelRatings;
  late List<int> _vehicleRatings;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _vehicleItems = widget.details.vehicle.isNotEmpty
        ? widget.details.vehicle
        : [Vehicle.placeholder()];

    _hotelRatings = List.filled(widget.details.hotels.length, 0);
    _vehicleRatings = List.filled(_vehicleItems.length, 0);
    _hotelCommentControllers = List.generate(
      widget.details.hotels.length,
      (_) => TextEditingController(),
    );
    _vehicleCommentControllers = List.generate(
      _vehicleItems.length,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    _companyCommentController.dispose();
    for (final c in _hotelCommentControllers) {
      c.dispose();
    }
    for (final c in _vehicleCommentControllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _isValid {
    if (_companyRating == 0) return false;
    if (widget.details.hotels.isNotEmpty) {
      for (final rating in _hotelRatings) {
        if (rating == 0) return false;
      }
    }
    for (final rating in _vehicleRatings) {
      if (rating == 0) return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_isValid) {
      final missing = <String>['company', 'vehicle'];
      if (widget.details.hotels.isNotEmpty) missing.add('hotels');
      Get.snackbar(
        'Incomplete feedback',
        'Please rate ${missing.join(', ')}.',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _apiService.submitFeedback(
        enquiryId: widget.enquiryId,
        companyRating: _companyRating,
        companyComment: _companyCommentController.text.trim(),
        hotelFeedback: [
          for (var i = 0; i < widget.details.hotels.length; i++)
            {
              'name': widget.details.hotels[i].hotelName,
              'city': widget.details.hotels[i].city,
              'rating': _hotelRatings[i],
              'comment': _hotelCommentControllers[i].text.trim(),
            },
        ],
        vehicleFeedback: [
          for (var i = 0; i < _vehicleItems.length; i++)
            {
              'type': _vehicleItems[i].typeName,
              'pickup_from': _vehicleItems[i].pickupFrom,
              'drop_from': _vehicleItems[i].dropFrom,
              'rating': _vehicleRatings[i],
              'comment': _vehicleCommentControllers[i].text.trim(),
            },
        ],
      );

      if (!mounted) return;
      Get.back(result: true);
      Get.snackbar(
        'Thank you!',
        'Your feedback has been submitted successfully.',
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Submission failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: AppColors.kErrorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final companyName = widget.details.booking.companyName.isNotEmpty
        ? widget.details.booking.companyName
        : 'Paarth Holidays';

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Share Your Feedback',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How was your tour experience? Rate each section below.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FeedbackSection(
                      icon: Icons.business_outlined,
                      title: 'Company',
                      subtitle: companyName,
                      rating: _companyRating,
                      onRatingChanged: (v) => setState(() => _companyRating = v),
                      commentController: _companyCommentController,
                      commentHint: 'Share your experience with the company...',
                    ),
                    if (widget.details.hotels.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SectionLabel(
                        icon: Icons.hotel_outlined,
                        title: 'Hotels',
                      ),
                      const SizedBox(height: 10),
                      for (var i = 0; i < widget.details.hotels.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _FeedbackSection(
                            icon: Icons.bed_outlined,
                            title: widget.details.hotels[i].hotelName,
                            subtitle: widget.details.hotels[i].city,
                            rating: _hotelRatings[i],
                            onRatingChanged: (v) =>
                                setState(() => _hotelRatings[i] = v),
                            commentController: _hotelCommentControllers[i],
                            commentHint: 'Comments about this hotel (optional)',
                            compact: true,
                          ),
                        ),
                    ],
                    const SizedBox(height: 20),
                    _SectionLabel(
                      icon: Icons.directions_car_outlined,
                      title: 'Vehicle & Transportation',
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < _vehicleItems.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _FeedbackSection(
                          icon: Icons.directions_car_filled_outlined,
                          title: _vehicleItems[i].displayTitle,
                          subtitle: _vehicleItems[i].displaySubtitle,
                          rating: _vehicleRatings[i],
                          onRatingChanged: (v) =>
                              setState(() => _vehicleRatings[i] = v),
                          commentController: _vehicleCommentControllers[i],
                          commentHint:
                              'How was the vehicle, driver and transport service?',
                          compact: _vehicleItems.length > 1,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Submit Feedback',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final TextEditingController commentController;
  final String commentHint;
  final bool compact;

  const _FeedbackSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.onRatingChanged,
    required this.commentController,
    required this.commentHint,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: AppColors.kSurfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: compact ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StarRating(value: rating, onChanged: onRatingChanged),
          const SizedBox(height: 12),
          TextField(
            controller: commentController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: commentHint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _StarRating({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final star = index + 1;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: () => onChanged(star),
          icon: Icon(
            star <= value ? Icons.star_rounded : Icons.star_outline_rounded,
            color: star <= value ? AppColors.primary : AppColors.border,
            size: 32,
          ),
        );
      }),
    );
  }
}
