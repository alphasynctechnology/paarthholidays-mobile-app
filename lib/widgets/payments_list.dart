import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../models/enquiry_details_model.dart';
import '../screens/home/bookings/pdf_viewer_screen.dart';
import '../screens/home/bookings/widgets/booking_detail_components.dart';

class PaymentsList extends StatelessWidget {
  final List<Payment> payments;

  const PaymentsList({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    final total = payments.fold<double>(
      0,
      (sum, p) => sum + (double.tryParse(p.amount.replaceAll(',', '')) ?? 0),
    );

    return BookingSectionCard(
      title: 'Payments',
      icon: Icons.payments_outlined,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '₹${total.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: Column(
        children: payments.map((payment) => _PaymentCard(payment: payment)).toList(),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Payment payment;

  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    return BookingInnerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (payment.uniquePaymentId.isNotEmpty)
                      Text(
                        payment.uniquePaymentId,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (payment.isPaid ? const Color(0xFF4CAF50) : const Color(0xFFE65100))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '₹${payment.amount}',
                  style: TextStyle(
                    color: payment.isPaid
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE65100),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BookingInfoRow(
            icon: Icons.info_outline,
            label: 'Status',
            value: payment.statusLabel,
          ),
          BookingInfoRow(icon: Icons.event_outlined, label: 'Date', value: payment.createdDate),
          if (payment.paymentComment.isNotEmpty)
            BookingInfoRow(icon: Icons.notes_outlined, label: 'Note', value: payment.paymentComment),
          if (payment.invoice.isNotEmpty) ...[
            const SizedBox(height: 4),
            BookingPdfButton(
              label: 'View Invoice',
              onTap: () => Get.to(
                () => PDFViewerScreen(
                  pdfUrl: payment.invoice,
                  title: 'Payment Invoice',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
