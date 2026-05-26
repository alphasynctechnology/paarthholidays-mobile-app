import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/enquiry_details_model.dart';
import '../services/api_service.dart';
import '../services/payment_service.dart';

class EnquiryDetailsController extends GetxController {
  final ApiService _apiService = ApiService();
  final PaymentService _paymentService = PaymentService();
  final Rx<EnquiryDetailsModel?> enquiryDetails = Rx<EnquiryDetailsModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isPaying = false.obs;
  final RxString error = ''.obs;
  final RxBool feedbackSubmitted = false.obs;
  String? _activeEnquiryId;

  @override
  void onClose() {
    _paymentService.dispose();
    super.onClose();
  }

  Future<void> fetchEnquiryDetails(String enquiryId) async {
    try {
      isLoading.value = true;
      error.value = '';
      _activeEnquiryId = enquiryId;

      final result = await _apiService.fetchEnquiryDetails(enquiryId);
      enquiryDetails.value = result;
      feedbackSubmitted.value = result.booking.isFeedbackSubmitted;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> payPendingAmount() async {
    final enquiryId = _activeEnquiryId;
    final summary = enquiryDetails.value?.paymentSummary;
    if (enquiryId == null || summary == null || !summary.canPayOnline) return;

    try {
      isPaying.value = true;
      final order = await _paymentService.createOrder(enquiryId);

      _paymentService.payPendingAmount(
        enquiryId: enquiryId,
        order: order,
        onSuccess: (message) async {
          isPaying.value = false;
          Get.snackbar(
            'Payment Successful',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF2E7D32),
            colorText: Colors.white,
          );
          await fetchEnquiryDetails(enquiryId);
        },
        onFailure: (message) {
          isPaying.value = false;
          if (message != 'Payment cancelled') {
            Get.snackbar(
              'Payment Failed',
              message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.colorScheme.error,
              colorText: Colors.white,
            );
          }
        },
      );
    } catch (e) {
      isPaying.value = false;
      Get.snackbar(
        'Payment Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    }
  }

  void markFeedbackSubmitted() {
    feedbackSubmitted.value = true;
  }

  bool get showFeedbackButton {
    if (feedbackSubmitted.value) return false;
    return enquiryDetails.value?.canShowFeedback ?? false;
  }
}
