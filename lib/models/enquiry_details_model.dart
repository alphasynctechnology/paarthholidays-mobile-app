import 'package:intl/intl.dart';

class EnquiryDetailsModel {
  final BookingDetails booking;
  final String quotationUrl;
  final List<Activity> activities;
  final List<Hotel> hotels;
  final int noOfRooms;
  final int noOfAdults;
  final int noOfChilds;
  final Map<String, int> additionalBeds;
  final List<String> childYears;
  final List<Vehicle> vehicle;
  final List<Member> members;
  final List<Payment> payments;
  final List<dynamic> specialRequests;
  final PaymentSummary? paymentSummary;

  EnquiryDetailsModel({
    required this.booking,
    required this.quotationUrl,
    required this.activities,
    required this.hotels,
    required this.noOfRooms,
    required this.noOfAdults,
    required this.noOfChilds,
    required this.additionalBeds,
    required this.childYears,
    required this.vehicle,
    required this.members,
    required this.payments,
    required this.specialRequests,
    this.paymentSummary,
  });

  factory EnquiryDetailsModel.fromJson(Map<String, dynamic> json) {
    final bookingJson = Map<String, dynamic>.from(json['booking'] ?? {});
    if (!bookingJson.containsKey('is_booking_done') &&
        json['is_booking_done'] != null) {
      bookingJson['is_booking_done'] = json['is_booking_done'];
    }
    if (!bookingJson.containsKey('is_feedback_submitted') &&
        json['is_feedback_submitted'] != null) {
      bookingJson['is_feedback_submitted'] = json['is_feedback_submitted'];
    }

    return EnquiryDetailsModel(
      booking: BookingDetails.fromJson(bookingJson),
      quotationUrl: json['quotation_url'] ?? '',
      activities: (json['activities'] as List).map((e) => Activity.fromJson(e)).toList(),
      hotels: (json['hotels'] as List).map((e) => Hotel.fromJson(e)).toList(),
      noOfRooms: json['no_of_rooms'] ?? 0,
      noOfAdults: json['no_of_adults'] ?? 0,
      noOfChilds: json['no_of_childs'] ?? 0,
      additionalBeds: Map<String, int>.from(json['additional_beds'] ?? {}),
      childYears: List<String>.from(json['child_years'] ?? []),
      vehicle: (json['vehicle'] as List).map((e) => Vehicle.fromJson(e)).toList(),
      members: (json['members'] as List).map((e) => Member.fromJson(e)).toList(),
      payments: (json['payments'] as List).map((e) => Payment.fromJson(e)).toList(),
      specialRequests: json['special_requests'] ?? [],
      paymentSummary: json['payment_summary'] != null
          ? PaymentSummary.fromJson(
              Map<String, dynamic>.from(json['payment_summary']),
            )
          : null,
    );
  }

  /// Feedback is available for completed bookings until it is submitted.
  bool get canShowFeedback {
    if (booking.isFeedbackSubmitted || booking.isCancelled) return false;
    return booking.isTripCompleted;
  }
}

class BookingDetails {
  final String id;
  final String uniqueEnquiryId;
  final String uniqueBookingId;
  final String departureDate;
  final String planName;
  final String companyName;
  final String whatsappNumber;
  final String isBookingDone;
  final bool isFeedbackSubmitted;

  BookingDetails({
    required this.id,
    required this.uniqueEnquiryId,
    required this.uniqueBookingId,
    required this.departureDate,
    required this.planName,
    required this.companyName,
    required this.whatsappNumber,
    required this.isBookingDone,
    required this.isFeedbackSubmitted,
  });

  bool get isCompleted => isBookingDone == '4';

  bool get isCancelled => isBookingDone == '2';

  /// Matches booking list logic: departure date is in the past.
  bool get isTripCompleted {
    if (isCompleted) return true;

    final departure = parseDepartureDate(departureDate);
    if (departure == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(departure);
  }

  /// Hotel and vehicle vouchers are visible from 1 day before departure.
  bool get canViewVouchers {
    final departure = parseDepartureDate(departureDate);
    if (departure == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final unlockDate = departure.subtract(const Duration(days: 1));

    return !today.isBefore(unlockDate);
  }

  static DateTime? parseDepartureDate(String value) => _parseDepartureDate(value);

  static DateTime? _parseDepartureDate(String value) {
    if (value.isEmpty) return null;

    final formats = [
      'd MMMM yyyy',
      'dd MMMM yyyy',
      'd, dd MMMM yyyy',
      'dd-MM-yyyy',
      'yyyy-MM-dd',
      'dd/MM/yyyy',
      'd MMM yyyy',
      'dd MMM yyyy',
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

  factory BookingDetails.fromJson(Map<String, dynamic> json) {
    return BookingDetails(
      id: json['id']?.toString() ?? '',
      uniqueEnquiryId: json['unique_enquiry_id'] ?? '',
      uniqueBookingId: json['unique_booking_id'] ??
          json['unique_booking_number'] ??
          json['booking_number'] ??
          '',
      departureDate: json['departure_date'] ?? '',
      planName: json['plan_name'] ?? '',
      companyName: json['company_name'] ?? '',
      whatsappNumber: json['whatsapp_number'] ?? '',
      isBookingDone: json['is_booking_done']?.toString() ?? '',
      isFeedbackSubmitted: json['is_feedback_submitted'] == true ||
          json['is_feedback_submitted']?.toString() == '1',
    );
  }

  String get displayBookingId {
    final raw = uniqueBookingId.isNotEmpty
        ? uniqueBookingId
        : (id.isNotEmpty && id != uniqueEnquiryId ? id : '');
    if (raw.isEmpty) return '';
    return _formatBookingId(raw);
  }

  static String _formatBookingId(String value) {
    final trimmed = value.trim().toUpperCase();
    if (trimmed.startsWith('BKG')) return trimmed;
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return trimmed;
    return 'BKG$digits';
  }
}

class Activity {
  final String id;
  final String day;
  final String plan;
  final String activity;
  final String destName;

  Activity({
    required this.id,
    required this.day,
    required this.plan,
    required this.activity,
    required this.destName,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? '',
      day: json['day'] ?? '',
      plan: json['plan'] ?? '',
      activity: json['activity'] ?? '',
      destName: json['DestName'] ?? '',
    );
  }
}

class Hotel {
  final String hotelName;
  final String checkIn;
  final String checkOut;
  final String voucher;
  final String city;
  final String email;
  final Package package;
  final String bookingNumber;
  final int noOfRooms;
  final int noOfDays;

  Hotel({
    required this.hotelName,
    required this.checkIn,
    required this.checkOut,
    required this.voucher,
    required this.city,
    required this.email,
    required this.package,
    required this.bookingNumber,
    required this.noOfRooms,
    required this.noOfDays,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      hotelName: json['hotel_name'] ?? '',
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
      voucher: json['voucher'] ?? '',
      city: json['city'] ?? '',
      email: json['email'] ?? '',
      package: Package.fromJson(json['package'] ?? {}),
      bookingNumber: json['booking_number'] ?? '',
      noOfRooms: int.tryParse(json['no_of_rooms']?.toString() ?? '0') ?? 0,
      noOfDays: int.tryParse(json['no_of_days']?.toString() ?? '0') ?? 0,
    );
  }
}

class Package {
  final String typeName;
  final String description;

  Package({
    required this.typeName,
    required this.description,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      typeName: json['type_name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class Vehicle {
  final String typeName;
  final String vehicleImage;
  final String voucher;
  final String pickupFrom;
  final String dropFrom;
  final String pickUpTime;
  final String dropTime;
  final String agentName;
  final String contactNumber;

  Vehicle({
    required this.typeName,
    required this.vehicleImage,
    required this.voucher,
    required this.pickupFrom,
    required this.dropFrom,
    required this.pickUpTime,
    required this.dropTime,
    required this.agentName,
    required this.contactNumber,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      typeName: json['type_name'] ?? '',
      vehicleImage: json['vehicle_image'] ?? '',
      voucher: json['voucher'] ?? '',
      pickupFrom: json['pickup_from'] ?? '',
      dropFrom: json['drop_from'] ?? '',
      pickUpTime: json['pick_up_time'] ?? '',
      dropTime: json['drop_time'] ?? '',
      agentName: json['agent_name'] ?? '',
      contactNumber: json['contact_number'] ?? '',
    );
  }

  factory Vehicle.placeholder() {
    return Vehicle(
      typeName: 'Transportation',
      vehicleImage: '',
      voucher: '',
      pickupFrom: '',
      dropFrom: '',
      pickUpTime: '',
      dropTime: '',
      agentName: '',
      contactNumber: '',
    );
  }

  bool get isPlaceholder => typeName == 'Transportation' && pickupFrom.isEmpty;

  String get displayTitle =>
      isPlaceholder ? 'Vehicle & Transportation' : typeName;

  String get displaySubtitle {
    if (isPlaceholder) {
      return 'Rate your overall transport experience';
    }
    final parts = <String>[];
    if (pickupFrom.isNotEmpty) parts.add('Pickup: $pickupFrom');
    if (dropFrom.isNotEmpty) parts.add('Drop: $dropFrom');
    if (agentName.isNotEmpty) parts.add('Driver: $agentName');
    return parts.join(' • ');
  }
}

class Member {
  final String name;
  final String contactNumber;
  final String gender;
  final String dob;
  final String mealType;
  final String perPersonCost;

  Member({
    required this.name,
    required this.contactNumber,
    required this.gender,
    required this.dob,
    required this.mealType,
    required this.perPersonCost,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      name: json['name'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      mealType: json['meal_type'] ?? '',
      perPersonCost: json['per_person_cost'] ?? '',
    );
  }
}

class Payment {
  final String name;
  final String uniquePaymentId;
  final String amount;
  final String paymentComment;
  final String createdDate;
  final String invoice;
  final int status;
  final String statusLabel;

  Payment({
    required this.name,
    required this.uniquePaymentId,
    required this.amount,
    required this.paymentComment,
    required this.createdDate,
    required this.invoice,
    this.status = 1,
    this.statusLabel = 'Paid',
  });

  bool get isPaid => status == 1;

  factory Payment.fromJson(Map<String, dynamic> json) {
    final statusValue = int.tryParse(json['status']?.toString() ?? '1') ?? 1;
    return Payment(
      name: json['name'] ?? '',
      uniquePaymentId: json['unique_payment_id'] ?? '',
      amount: json['amount']?.toString() ?? '',
      paymentComment: json['payment_comment'] ?? '',
      createdDate: json['created_date'] ?? '',
      invoice: json['invoice'] ?? '',
      status: statusValue,
      statusLabel: json['status_label']?.toString() ??
          (statusValue == 1 ? 'Paid' : 'Pending'),
    );
  }
}

class PaymentSummary {
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final String currency;
  final bool isFullyPaid;
  final bool canPayOnline;
  final String razorpayKeyId;
  final String companyName;

  PaymentSummary({
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.currency,
    required this.isFullyPaid,
    required this.canPayOnline,
    this.razorpayKeyId = '',
    this.companyName = 'Paarth Holidays',
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '0') ?? 0;
    }

    return PaymentSummary(
      totalAmount: toDouble(json['total_amount']),
      paidAmount: toDouble(json['paid_amount']),
      pendingAmount: toDouble(json['pending_amount']),
      currency: json['currency']?.toString() ?? 'INR',
      isFullyPaid: json['is_fully_paid'] == true ||
          json['is_fully_paid'] == 1 ||
          json['is_fully_paid'] == '1',
      canPayOnline: json['can_pay_online'] == true ||
          json['can_pay_online'] == 1 ||
          json['can_pay_online'] == '1',
      razorpayKeyId: json['razorpay_key_id']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? 'Paarth Holidays',
    );
  }
} 