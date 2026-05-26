import 'package:intl/intl.dart';

import '../models/booking_model.dart';
import '../models/enquiry_details_model.dart';
import '../services/api_service.dart';

class OngoingTourContext {
  final BookingModel booking;
  final EnquiryDetailsModel details;
  final int tripDay;
  final int totalDays;

  OngoingTourContext({
    required this.booking,
    required this.details,
    required this.tripDay,
    required this.totalDays,
  });

  String get planName => booking.planName;
  String get enquiryId => booking.enquiryId;
  String get supportPhone => details.booking.whatsappNumber;
  String get companyName => details.booking.companyName;
}

class OngoingTourHelper {
  OngoingTourHelper._();

  static Future<OngoingTourContext?> resolve(
    ApiService apiService, {
    List<BookingModel>? bookings,
  }) async {
    List<BookingModel> bookingList = bookings ?? [];
    if (bookings == null) {
      try {
        bookingList = await apiService.fetchBookings();
      } catch (_) {}
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final candidates = bookingList.where((booking) {
      if (booking.isBookingDone == '2') return false;
      final departure = parseDate(booking.departureDate);
      return departure != null && !departure.isAfter(today);
    }).toList();

    candidates.sort((a, b) {
      final dateA = parseDate(a.departureDate);
      final dateB = parseDate(b.departureDate);
      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA);
    });

    for (final booking in candidates) {
      try {
        final details = await apiService.fetchEnquiryDetails(booking.enquiryId);
        final departure = parseDate(booking.departureDate);
        if (departure == null || details.activities.isEmpty) continue;

        final tripDay = today.difference(departure).inDays + 1;
        if (tripDay < 1 || tripDay > details.activities.length) continue;

        return OngoingTourContext(
          booking: booking,
          details: details,
          tripDay: tripDay,
          totalDays: details.activities.length,
        );
      } catch (_) {}
    }

    return null;
  }

  static DateTime? parseDate(String value) {
    if (value.isEmpty) return null;

    final formats = [
      'd MMMM yyyy',
      'dd MMMM yyyy',
      'd MMM yyyy',
      'dd MMM yyyy',
      'd, dd MMMM yyyy',
      'dd-MM-yyyy',
      'yyyy-MM-dd',
      'dd/MM/yyyy',
    ];

    for (final pattern in formats) {
      try {
        return DateFormat(pattern).parse(value);
      } catch (_) {}
    }

    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}
