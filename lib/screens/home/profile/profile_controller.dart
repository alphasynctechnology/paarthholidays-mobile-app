import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/profile_model.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../../controllers/notifications_controller.dart';
import '../../../utils/ongoing_tour_helper.dart';
import '../../../utils/phone_launcher.dart';
import '../home_screen.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = ApiService();
  late final StorageService _storageService;

  var profile = Rxn<ProfileModel>();
  var ongoingTour = Rxn<OngoingTourContext>();
  var isLoading = false.obs;
  var isSendingSos = false.obs;
  var errorMessage = ''.obs;
  String _storedMobile = '';

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _storageService = StorageService(prefs);
    _storedMobile = _storageService.getMobile() ?? '';
    await Future.wait([
      fetchUserProfile(),
      _loadOngoingTour(),
    ]);
  }

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _apiService.fetchUserProfile();
      profile.value = result;

      if (result.mobile.isNotEmpty) {
        await _storageService.saveMobile(result.mobile);
        _storedMobile = result.mobile;
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadOngoingTour() async {
    try {
      ongoingTour.value = await OngoingTourHelper.resolve(_apiService);
    } catch (_) {
      ongoingTour.value = null;
    }
  }

  String get displayName =>
      profile.value?.displayName('Guest') ?? 'Guest';

  String get displayEmail =>
      profile.value?.displayEmail() ?? 'Not set';

  String get displayMobile =>
      profile.value?.displayMobile(_storedMobile) ??
      (_storedMobile.isNotEmpty ? _storedMobile : 'Not set');

  String get mobileFallback => _storedMobile;

  String get supportPhone =>
      PhoneLauncher.cleanPhone(ongoingTour.value?.supportPhone ?? '');

  String supportSmsBody({bool isSos = false}) {
    final tour = ongoingTour.value;
    if (tour == null) return '';

    final prefix = isSos ? 'SOS! ' : '';
    return '$prefix I need assistance with my ongoing tour "${tour.planName}" '
        '(Day ${tour.tripDay} of ${tour.totalDays}). '
        '- $displayName ($displayMobile)';
  }

  Future<bool> dialSupport() async {
    if (supportPhone.isEmpty) {
      _showUnavailable('Support number is not available right now.');
      return false;
    }
    final launched = await PhoneLauncher.dial(supportPhone);
    if (!launched) {
      _showUnavailable('Could not open the phone dialer.');
    }
    return launched;
  }

  Future<bool> smsSupport({bool isSos = false}) async {
    if (supportPhone.isEmpty) {
      _showUnavailable('Support number is not available right now.');
      return false;
    }
    final launched =
        await PhoneLauncher.sms(supportPhone, body: supportSmsBody(isSos: isSos));
    if (!launched) {
      _showUnavailable('Could not open the SMS app.');
    }
    return launched;
  }

  Future<void> triggerSosAlert() async {
    final tour = ongoingTour.value;
    if (tour == null) return;

    isSendingSos.value = true;
    try {
      final response = await _apiService.submitSos(
        enquiryId: tour.enquiryId,
        tripDay: tour.tripDay,
        message: supportSmsBody(isSos: true),
      );

      Get.snackbar(
        'SOS Sent',
        response['message']?.toString() ?? 'Support team has been alerted.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC62828),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'SOS Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.kErrorColor,
        colorText: Colors.white,
      );
    } finally {
      isSendingSos.value = false;
    }
  }

  void _showUnavailable(String message) {
    Get.snackbar(
      'Unavailable',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _storageService.clearAuthSession();
      if (Get.isRegistered<NotificationsController>()) {
        await Get.delete<NotificationsController>(force: true);
      }
      Get.offAll(() => HomeScreen());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
