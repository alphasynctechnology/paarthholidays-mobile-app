import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';
import '../controllers/notifications_controller.dart';
import '../screens/auth/login/login_screen.dart';
import '../services/storage_service.dart';

class AuthGuard {
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs).isLoggedIn;
  }

  /// Returns true if the user is logged in (or logs in successfully).
  static Future<bool> requireLogin({
    String title = 'Login required',
    String message = 'Please login to continue.',
  }) async {
    if (await isLoggedIn()) return true;

    final shouldLogin = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Login'),
          ),
        ],
      ),
      barrierDismissible: true,
    );

    if (shouldLogin != true) return false;

    await Get.to(() => LoginScreen());
    final loggedIn = await isLoggedIn();
    if (loggedIn && Get.isRegistered<NotificationsController>()) {
      Get.find<NotificationsController>().fetchNotifications();
    }
    return loggedIn;
  }
}
