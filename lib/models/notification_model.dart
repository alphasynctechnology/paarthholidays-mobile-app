class AppNotificationModel {
  final int id;
  final String title;
  final String description;
  final String type;
  final int bookingId;
  final int enquiryId;
  final bool isRead;
  final String createdDate;

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.bookingId,
    required this.enquiryId,
    required this.isRead,
    required this.createdDate,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final readStatus = json['read_status'];
    final isRead = readStatus == 1 ||
        readStatus == '1' ||
        readStatus == true;

    return AppNotificationModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      bookingId: int.tryParse(json['booking_id']?.toString() ?? '') ?? 0,
      enquiryId: int.tryParse(json['enquiry_id']?.toString() ?? '') ?? 0,
      isRead: isRead,
      createdDate: json['created_date']?.toString() ?? '',
    );
  }
}
