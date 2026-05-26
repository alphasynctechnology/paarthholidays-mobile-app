import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/enquiry_details_model.dart';
import 'booking_detail_components.dart';

class BookingPaymentSummary extends StatelessWidget {
  final PaymentSummary summary;

  const BookingPaymentSummary({
    super.key,
    required this.summary,
  });

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return BookingSectionCard(
      title: 'Payment Summary',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AmountRow(
            label: 'Total Amount',
            value: '₹${_formatAmount(summary.totalAmount)}',
          ),
          const SizedBox(height: 8),
          _AmountRow(
            label: 'Paid',
            value: '₹${_formatAmount(summary.paidAmount)}',
            valueColor: const Color(0xFF2E7D32),
          ),
          const SizedBox(height: 8),
          _AmountRow(
            label: 'Pending',
            value: '₹${_formatAmount(summary.pendingAmount)}',
            valueColor: summary.pendingAmount > 0
                ? const Color(0xFFE65100)
                : const Color(0xFF2E7D32),
            emphasize: true,
          ),
          if (summary.isFullyPaid) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'All payments completed',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  const _AmountRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: emphasize ? 15 : 14,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasize ? 18 : 15,
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
