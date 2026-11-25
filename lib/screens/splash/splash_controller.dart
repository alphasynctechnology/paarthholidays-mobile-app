import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/storage_service.dart';
import '../home/home_screen.dart';
import '../auth/login/add_profile_details_screen.dart';

class SplashController extends GetxController {
  late final StorageService _storageService;

  @override
  void onInit() async {
    super.onInit();
    final prefs = await SharedPreferences.getInstance();
    _storageService = StorageService(prefs);

    await Future.delayed(const Duration(seconds: 2));
    checkAuthAndNavigate();
  }

  void checkAuthAndNavigate() {
    final token = _storageService.getToken();
    final isProfileCompleted = _storageService.getIsProfileCompleted();

    if (token != null && token.isNotEmpty) {
      if (!isProfileCompleted) {
        Get.offAll(() => AddProfileDetailsScreen(mobileNumber: ''));
      } else {
        Get.offAll(() => HomeScreen());
      }
    } else {
      // Guests can browse home; login is required only for private features.
      Get.offAll(() => HomeScreen());
    }
  }
}
