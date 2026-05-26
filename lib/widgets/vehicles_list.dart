import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/enquiry_details_model.dart';
import '../screens/home/bookings/pdf_viewer_screen.dart';
import '../screens/home/bookings/widgets/booking_detail_components.dart';
import '../core/theme/app_colors.dart';

class VehiclesList extends StatelessWidget {
  final List<Vehicle> vehicles;
  final bool showVouchers;

  const VehiclesList({
    super.key,
    required this.vehicles,
    this.showVouchers = true,
  });

  String _formatTime(String time) {
    try {
      final timeParts = time.split(':');
      if (timeParts.length >= 2) {
        final hour = int.parse(timeParts[0]);
        final minute = timeParts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$hour12:$minute $period';
      }
    } catch (_) {}
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return BookingSectionCard(
      title: 'Transportation',
      icon: Icons.directions_car_outlined,
      child: Column(
        children: vehicles.map((vehicle) {
          return BookingInnerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.typeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                BookingInfoRow(
                  icon: Icons.trip_origin,
                  label: 'Pickup',
                  value: vehicle.pickupFrom,
                ),
                BookingInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Drop',
                  value: vehicle.dropFrom,
                ),
                BookingInfoRow(
                  icon: Icons.schedule,
                  label: 'Pickup time',
                  value: _formatTime(vehicle.pickUpTime),
                ),
                BookingInfoRow(
                  icon: Icons.schedule_outlined,
                  label: 'Drop time',
                  value: _formatTime(vehicle.dropTime),
                ),
                BookingInfoRow(
                  icon: Icons.support_agent_outlined,
                  label: 'Agent',
                  value: vehicle.agentName,
                ),
                BookingInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Contact',
                  value: vehicle.contactNumber,
                ),
                if (showVouchers && vehicle.voucher.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  BookingPdfButton(
                    label: 'View Vehicle Voucher',
                    onTap: () => Get.to(
                      () => PDFViewerScreen(
                        pdfUrl: vehicle.voucher,
                        title: 'Vehicle Voucher',
                      ),
                    ),
                  ),
                ],
                if (vehicle.vehicleImage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: vehicle.vehicleImage,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        height: 140,
                        color: AppColors.border,
                        child: const Icon(Icons.directions_car_outlined),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
