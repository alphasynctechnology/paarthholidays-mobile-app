import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/notifications_controller.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/wallet/wallet_screen.dart';
import '../../utils/auth_guard.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showWalletIcon;
  final bool showNotificationIcon;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.showWalletIcon = true,
    this.showNotificationIcon = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<void> _openNotifications() async {
    final allowed = await AuthGuard.requireLogin(
      message: 'Please login to view your notifications.',
    );
    if (!allowed) return;

    if (Get.isRegistered<NotificationsController>()) {
      final controller = Get.find<NotificationsController>();
      await Get.to(() => const NotificationsScreen());
      controller.fetchNotifications();
    } else {
      Get.to(() => const NotificationsScreen());
    }
  }

  Future<void> _openWallet() async {
    final allowed = await AuthGuard.requireLogin(
      message: 'Please login to view your reward wallet.',
    );
    if (!allowed) return;
    Get.to(() => const WalletScreen());
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
      ),
      centerTitle: true,
      elevation: 1,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => _handleBack(context),
            )
          : null,
      actions: [
        if (showNotificationIcon && Get.isRegistered<NotificationsController>())
          Obx(() {
            final controller = Get.find<NotificationsController>();
            final unreadCount = controller.unreadCount;

            return IconButton(
              tooltip: 'Notifications',
              onPressed: _openNotifications,
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(fontSize: 10),
                ),
                backgroundColor: Colors.white,
                textColor: AppColors.primary,
                child: const Icon(Icons.notifications_outlined),
              ),
            );
          }),
        if (showNotificationIcon && !Get.isRegistered<NotificationsController>())
          IconButton(
            tooltip: 'Notifications',
            onPressed: _openNotifications,
            icon: const Icon(Icons.notifications_outlined),
          ),
        if (showWalletIcon)
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: _openWallet,
          ),
        if (actions != null) ...actions!,
        const SizedBox(width: 8),
      ],
    );
  }

  void _handleBack(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    }
  }
}
