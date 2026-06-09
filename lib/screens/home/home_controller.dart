import 'package:get/get.dart';

import '../../services/push_notification_service.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    PushNotificationService.instance.scheduleDeferredTokenSync();
  }

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }
}
