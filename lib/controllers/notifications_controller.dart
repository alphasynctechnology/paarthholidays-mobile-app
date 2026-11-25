import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class NotificationsController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<AppNotificationModel> notifications = <AppNotificationModel>[].obs;

  int get unreadCount =>
      notifications.where((notification) => !notification.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    if (!StorageService(prefs).isLoggedIn) {
      notifications.clear();
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final rows = await _apiService.fetchNotifications();
      notifications.assignAll(
        rows.map(AppNotificationModel.fromJson).toList(),
      );
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    if (notificationId <= 0) {
      return;
    }

    try {
      await _apiService.markNotificationsRead(notificationId: notificationId);
      final index = notifications.indexWhere((item) => item.id == notificationId);
      if (index >= 0) {
        final current = notifications[index];
        notifications[index] = AppNotificationModel(
          id: current.id,
          title: current.title,
          description: current.description,
          type: current.type,
          bookingId: current.bookingId,
          enquiryId: current.enquiryId,
          isRead: true,
          createdDate: current.createdDate,
        );
      }
    } catch (_) {
      // Keep UI responsive even if mark-read fails silently.
    }
  }

  Future<void> markAllAsRead() async {
    if (unreadCount == 0) {
      return;
    }

    try {
      await _apiService.markNotificationsRead();
      notifications.assignAll(
        notifications
            .map(
              (item) => AppNotificationModel(
                id: item.id,
                title: item.title,
                description: item.description,
                type: item.type,
                bookingId: item.bookingId,
                enquiryId: item.enquiryId,
                isRead: true,
                createdDate: item.createdDate,
              ),
            )
            .toList(),
      );
    } catch (_) {
      // Ignore; user can pull to refresh.
    }
  }
}
