import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/home_screen.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import 'dart:async';

import 'add_profile_details_screen.dart';

class LoginController extends GetxController {
  final TextEditingController mobileController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  final RxBool isLoading = false.obs;
  final RxBool isOtpSent = false.obs;
  final RxInt resendSecondsLeft = 0.obs;
  Timer? _resendTimer;
  String? _otpToken;

  final ApiService _apiService = ApiService();
  StorageService? _storageService;

  String get resendTimerText {
    final int min = resendSecondsLeft.value ~/ 60;
    final int sec = resendSecondsLeft.value % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void _startResendTimer() {
    resendSecondsLeft.value = 120;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSecondsLeft.value > 0) {
        resendSecondsLeft.value--;
      } else {
        _resendTimer?.cancel();
      }
    });
  }

  Future<StorageService> _storage() async {
    if (_storageService != null) return _storageService!;
    final prefs = await SharedPreferences.getInstance();
    _storageService = StorageService(prefs);
    return _storageService!;
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }

  void clearOtpFields() {
    for (final c in otpControllers) {
      c.clear();
    }
  }

  /// Opens the iOS/Android keyboard on the first OTP box after fields appear.
  void focusFirstOtpField() {
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (isClosed) return;
        if (otpFocusNodes.isNotEmpty) {
          otpFocusNodes.first.requestFocus();
        }
      });
    });
  }

  void onOtpChanged(int index, String value) {
    if (value.length > 1) {
      // iOS SMS autofill / paste can deliver the full code into one field.
      _distributeOtp(value);
      return;
    }

    if (value.isNotEmpty && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }

    if (index == 5 && value.isNotEmpty) {
      final otp = otpControllers.map((c) => c.text).join('');
      if (otp.length == 6) {
        otpFocusNodes[index].unfocus();
      }
    }
  }

  void _distributeOtp(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;

    for (var i = 0; i < otpControllers.length; i++) {
      otpControllers[i].text = i < digits.length ? digits[i] : '';
    }

    final focusIndex = digits.length.clamp(0, 5);
    if (digits.length >= 6) {
      otpFocusNodes[5].unfocus();
    } else {
      otpFocusNodes[focusIndex].requestFocus();
    }
  }

  Future<void> sendOtp() async {
    if (mobileController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your mobile number',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (mobileController.text.length != 10) {
      Get.snackbar(
        'Error',
        'Please enter a valid 10-digit mobile number',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final token = await _apiService.otpSignIn(mobileController.text);
      _otpToken = token;
      clearOtpFields();
      isOtpSent.value = true;
      _startResendTimer();
      focusFirstOtpField();
      Get.snackbar(
        'Success',
        'OTP sent to your mobile number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      isOtpSent.value = false;
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (mobileController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your mobile number',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final otp = otpControllers.map((controller) => controller.text).join('');
    if (otp.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the OTP',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (otp.length != 6) {
      Get.snackbar(
        'Error',
        'Please enter a valid 6-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_otpToken == null || _otpToken!.isEmpty) {
      Get.snackbar(
        'Error',
        'OTP token missing. Please request OTP again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final result = await _apiService.validateOtp(token: _otpToken!, otp: otp);
      final authToken = result['auth_token']?.toString() ?? '';
      if (authToken.isEmpty) {
        throw Exception('Login failed. Please try again.');
      }

      final storage = await _storage();
      final profileCompleted = _asBool(result['is_profile_completed']);

      await storage.saveToken(authToken);
      await storage.saveMobile(mobileController.text.trim());
      await storage.saveLoginMethod('otp');
      await storage.saveIsProfileCompleted(profileCompleted);

      if (profileCompleted) {
        if (Get.key.currentState?.canPop() ?? false) {
          Get.back(result: true);
        } else {
          Get.offAll(() => HomeScreen());
        }
        Get.snackbar(
          'Success',
          'Login successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
      } else {
        Get.offAll(
          () => AddProfileDetailsScreen(mobileNumber: mobileController.text),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resendOtp() {
    if (mobileController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your mobile number first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    sendOtp();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    mobileController.dispose();
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final node in otpFocusNodes) {
      node.dispose();
    }
    super.onClose();
  }
}
