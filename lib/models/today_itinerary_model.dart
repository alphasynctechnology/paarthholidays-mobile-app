import 'enquiry_details_model.dart';

class TodayItineraryModel {
  final String enquiryId;
  final String planName;
  final String imageUrl;
  final int tripDay;
  final int totalDays;
  final Activity activity;
  final String? hotelName;
  final String? hotelCity;

  TodayItineraryModel({
    required this.enquiryId,
    required this.planName,
    required this.imageUrl,
    required this.tripDay,
    required this.totalDays,
    required this.activity,
    this.hotelName,
    this.hotelCity,
  });

  String get activityPreview {
    final text = activity.activity
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.length <= 160) return text;
    return '${text.substring(0, 157)}...';
  }
}
