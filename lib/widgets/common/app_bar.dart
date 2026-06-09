import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/notifications_controller.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/wallet/wallet_screen.dart';

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
              onPressed: () async {
                await Get.to(() => const NotificationsScreen());
                controller.fetchNotifications();
              },
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
            onPressed: () => Get.to(() => const NotificationsScreen()),
            icon: const Icon(Icons.notifications_outlined),
          ),
        // Wallet icon
        if (showWalletIcon)
        IconButton(
          icon: const Icon(Icons.account_balance_wallet),
          onPressed: () {
            Get.to(() => const WalletScreen());
          },
        ),
        // Additional actions if provided
        if (actions != null) ...actions!,
        const SizedBox(width: 8), // Add some padding at the end
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