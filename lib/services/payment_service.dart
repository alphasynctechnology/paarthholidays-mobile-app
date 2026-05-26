import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../models/payment_order_model.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _apiService = ApiService();
  Razorpay? _razorpay;
  void Function(String message)? _onSuccess;
  void Function(String message)? _onFailure;

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }

  Future<void> payPendingAmount({
    required String enquiryId,
    required PaymentOrderModel order,
    required void Function(String message) onSuccess,
    required void Function(String message) onFailure,
  }) async {
    _currentEnquiryId = enquiryId;
    _onSuccess = onSuccess;
    _onFailure = onFailure;

    _razorpay?.clear();
    _razorpay = Razorpay();
    _razorpay!
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handleError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    final options = {
      'key': order.keyId,
      'amount': order.amountPaise,
      'currency': order.currency,
      'order_id': order.orderId,
      'name': order.companyName,
      'description': order.description,
      'prefill': {
        if (order.prefill['name']?.isNotEmpty == true) 'name': order.prefill['name'],
        if (order.prefill['email']?.isNotEmpty == true) 'email': order.prefill['email'],
        if (order.prefill['contact']?.isNotEmpty == true) 'contact': order.prefill['contact'],
      },
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      onFailure('Unable to open payment gateway');
    }
  }

  Future<void> _handleSuccess(PaymentSuccessResponse response) async {
    try {
      final orderId = response.orderId ?? '';
      final paymentId = response.paymentId ?? '';
      final signature = response.signature ?? '';

      if (orderId.isEmpty || paymentId.isEmpty || signature.isEmpty) {
        _onFailure?.call('Incomplete payment response');
        return;
      }

      final enquiryId = _currentEnquiryId;
      if (enquiryId == null) {
        _onFailure?.call('Booking reference missing');
        return;
      }

      final message = await _apiService.verifyPayment(
        enquiryId: enquiryId,
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );
      _onSuccess?.call(message);
    } catch (e) {
      _onFailure?.call(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _handleError(PaymentFailureResponse response) {
    final message = response.message ?? 'Payment failed';
    final code = response.code;
    if (code == Razorpay.PAYMENT_CANCELLED) {
      _onFailure?.call('Payment cancelled');
      return;
    }
    _onFailure?.call(message);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet selected: ${response.walletName}');
  }

  String? _currentEnquiryId;

  Future<PaymentOrderModel> createOrder(String enquiryId) async {
    _currentEnquiryId = enquiryId;
    return _apiService.createPaymentOrder(enquiryId);
  }
}
