import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../models/enquiry_details_model.dart';
import '../screens/home/bookings/pdf_viewer_screen.dart';
import '../screens/home/bookings/widgets/booking_detail_components.dart';

class HotelsList extends StatelessWidget {
  final List<Hotel> hotels;
  final bool showVouchers;

  const HotelsList({
    super.key,
    required this.hotels,
    this.showVouchers = true,
  });

  @override
  Widget build(BuildContext context) {
    return BookingSectionCard(
      title: 'Hotels',
      icon: Icons.hotel_outlined,
      child: Column(
        children: hotels.map((hotel) => _HotelCard(hotel: hotel, showVouchers: showVouchers)).toList(),
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  final Hotel hotel;
  final bool showVouchers;

  const _HotelCard({required this.hotel, required this.showVouchers});

  @override
  Widget build(BuildContext context) {
    return BookingInnerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hotel.hotelName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (hotel.city.isNotEmpty)
                BookingTag(
                  label: hotel.city,
                  color: AppColors.primary,
                  icon: Icons.location_on_outlined,
                ),
            ],
          ),
          const SizedBox(height: 12),
          BookingInfoRow(icon: Icons.login, label: 'Check-in', value: hotel.checkIn),
          BookingInfoRow(icon: Icons.logout, label: 'Check-out', value: hotel.checkOut),
          BookingInfoRow(icon: Icons.confirmation_number_outlined, label: 'Booking #', value: hotel.bookingNumber),
          BookingInfoRow(icon: Icons.bed_outlined, label: 'Rooms', value: '${hotel.noOfRooms}'),
          BookingInfoRow(icon: Icons.timelapse_outlined, label: 'Duration', value: '${hotel.noOfDays} days'),
          BookingInfoRow(icon: Icons.card_travel_outlined, label: 'Package', value: hotel.package.typeName),
          if (hotel.package.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                hotel.package.description,
                style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
              ),
            ),
          ],
          if (showVouchers && hotel.voucher.isNotEmpty) ...[
            const SizedBox(height: 8),
            BookingPdfButton(
              label: 'View Hotel Voucher',
              onTap: () => Get.to(
                () => PDFViewerScreen(pdfUrl: hotel.voucher, title: 'Hotel Voucher'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
