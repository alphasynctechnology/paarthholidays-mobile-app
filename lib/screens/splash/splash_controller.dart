import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/storage_service.dart';
import '../../services/push_notification_service.dart';
import '../auth/login/login_screen.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';
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
    final isFirstTime = _storageService.getIsFirstTime() ?? true;
    final isProfileCompleted = _storageService.getIsProfileCompleted();

    if (token != null && token.isNotEmpty) {
      PushNotificationService.instance.syncTokenIfLoggedIn();
      if (!isProfileCompleted) {
        Get.offAll(() => AddProfileDetailsScreen(mobileNumber: ''));
      } else {
        Get.offAll(() => HomeScreen());
      }
    } else if (isFirstTime) {
      Get.offAll(() => OnboardingScreen());
      _storageService.setIsFirstTime(false);
    } else {
      Get.offAll(() => LoginScreen());
    }
  }
}
