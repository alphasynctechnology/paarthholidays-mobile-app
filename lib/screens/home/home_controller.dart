import 'package:get/get.dart';

import '../../utils/auth_guard.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;

  static const _authRequiredTabs = {1, 2, 3};

  Future<void> changeTabIndex(int index) async {
    if (!_authRequiredTabs.contains(index)) {
      selectedIndex.value = index;
      return;
    }

    final allowed = await AuthGuard.requireLogin(
      title: 'Login required',
      message: _loginMessageForTab(index),
    );
    if (allowed) {
      selectedIndex.value = index;
    }
  }

  String _loginMessageForTab(int index) {
    switch (index) {
      case 1:
        return 'Please login to view your bookings.';
      case 2:
        return 'Please login to raise or view enquiries.';
      case 3:
        return 'Please login to access your profile.';
      default:
        return 'Please login to continue.';
    }
  }
}
