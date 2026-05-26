import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../utils/phone_launcher.dart';
import '../../../widgets/common/app_bar.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_tour_support_card.dart';
import 'profile_controller.dart';
import 'edit_profile_screen.dart';
import '../../../widgets/common/loader_dialog.dart';
import '../../../utils/referral_share.dart';
import '../../wallet/wallet_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSos(ProfileController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.sos_outlined, color: Color(0xFFC62828)),
            SizedBox(width: 8),
            Text('Emergency SOS'),
          ],
        ),
        content: const Text(
          'This will alert the Paarth Holidays support team immediately '
          'and log your emergency request.\n\nDo you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
            ),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await controller.triggerSosAlert();

    if (controller.supportPhone.isEmpty) return;

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Need immediate help?'),
        content: const Text(
          'You can also call or SMS tour support directly, or dial 112.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.smsSupport(isSos: true);
            },
            child: const Text('SMS Support'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.dialSupport();
            },
            child: const Text('Call Support'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              PhoneLauncher.dial('112');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
            ),
            child: const Text('Call 112'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Obx(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.isLoading.value) {
          if (!(Get.isDialogOpen ?? false)) {
            Get.dialog(const LoaderDialog(), barrierDismissible: false);
          }
        } else {
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
        }
      });

      final profile = controller.profile.value;
      final ongoing = controller.ongoingTour.value;

      return Scaffold(
        appBar: const CommonAppBar(
          title: 'Profile',
          showBackButton: false,
        ),
        body: controller.errorMessage.value.isNotEmpty && profile == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(controller.errorMessage.value),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.fetchUserProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            image: const DecorationImage(
                              image: AssetImage(
                                'assets/images/splash_bg.png',
                              ),
                              fit: BoxFit.cover,
                              alignment: Alignment.centerLeft,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: -50,
                          child: Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.kSurfaceColor,
                              child: CircleAvatar(
                                radius: 46,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  _initials(controller.displayName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    Text(
                      controller.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.displayMobile,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (profile != null) ...[
                      ProfileInfoCard(
                        profile: profile,
                        mobileFallback: controller.mobileFallback,
                      ),
                    ] else
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    if (ongoing != null)
                      ProfileTourSupportCard(
                        tour: ongoing,
                        isSendingSos: controller.isSendingSos.value,
                        onSupportCall: controller.dialSupport,
                        onSupportSms: () => controller.smsSupport(),
                        onSos: () => _confirmSos(controller),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          if (profile != null)
                            _ProfileActionButton(
                              icon: Icons.edit_outlined,
                              label: 'Edit Profile',
                              onPressed: () => Get.to(
                                () => EditProfileScreen(
                                  profile: profile,
                                  mobile: controller.displayMobile,
                                ),
                              ),
                            ),
                          if (profile != null &&
                              profile.referralCode.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _ProfileActionButton(
                              icon: Icons.card_giftcard_outlined,
                              label: 'Refer & Earn',
                              onPressed: () => ReferralShare.share(
                                referralCode: profile.referralCode,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          _ProfileActionButton(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Reward Wallet',
                            onPressed: () => Get.to(() => const WalletScreen()),
                          ),
                          if (profile?.hasPassword == true) ...[
                            const SizedBox(height: 12),
                            _ProfileActionButton(
                              icon: Icons.lock_outline,
                              label: 'Change Password',
                              onPressed: () =>
                                  Get.to(() => const ChangePasswordScreen()),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () =>
                                  _showLogoutDialog(context, controller),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.red.shade50,
                                foregroundColor: Colors.red.shade700,
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    color: Colors.red.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'G';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  void _showLogoutDialog(BuildContext context, ProfileController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: Colors.red.shade700,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ProfileActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          foregroundColor: AppColors.primary,
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
