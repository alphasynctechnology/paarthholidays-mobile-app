import 'package:flutter/foundation.dart';

import '../models/payment_order_model.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _apiService = ApiService();
  void Function(String message)? _onSuccess;
  void Function(String message)? _onFailure;

  void dispose() {
    
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

  }
  String? _currentEnquiryId;

  Future<PaymentOrderModel> createOrder(String enquiryId) async {
    _currentEnquiryId = enquiryId;
    return _apiService.createPaymentOrder(enquiryId);
  }
}
