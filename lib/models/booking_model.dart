class BookingModel {
  final String img;
  final String enquiryId;
  final String uniqueEnquiryId;
  final String uniqueBookingId;
  final String departureDate;
  final String planId;
  final String planName;
  final String isBookingDone;

  BookingModel({
    required this.img,
    required this.enquiryId,
    required this.uniqueEnquiryId,
    required this.uniqueBookingId,
    required this.departureDate,
    required this.planId,
    required this.planName,
    required this.isBookingDone,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      img: json['img'] ?? '',
      enquiryId: json['enquiry_id']?.toString() ?? '',
      uniqueEnquiryId: json['unique_enquiry_id'] ?? '',
      uniqueBookingId: json['unique_booking_id'] ??
          json['unique_booking_number'] ??
          json['booking_number'] ??
          '',
      departureDate: json['departure_date'] ?? '',
      planId: json['plan_id']?.toString() ?? '',
      planName: json['plan_name'] ?? '',
      isBookingDone: json['is_booking_done']?.toString() ?? '',
    );
  }

  String get displayBookingId {
    if (uniqueBookingId.isNotEmpty) {
      return _formatBookingId(uniqueBookingId);
    }
    final enquiry = uniqueEnquiryId.trim().toUpperCase();
    if (enquiry.startsWith('ENQ') && enquiry.length > 3) {
      return 'BKG${enquiry.substring(3)}';
    }
    if (enquiryId.isNotEmpty) {
      return _formatBookingId(enquiryId);
    }
    return '';
  }

  static String _formatBookingId(String value) {
    final trimmed = value.trim().toUpperCase();
    if (trimmed.startsWith('BKG')) return trimmed;
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return trimmed;
    return 'BKG$digits';
  }

  static List<BookingModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => BookingModel.fromJson(json)).toList();
  }
} 