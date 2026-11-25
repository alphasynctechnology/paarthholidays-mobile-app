import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/home_screen.dart';
import 'login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8F3), // Very light orange tint
              Color(0xFFFFF5F0), // Even lighter orange tint
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight -
                    media.padding.top -
                    media.padding.bottom -
                    media.viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    // Logo Section with enhanced styling
                    Container(
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/paarth_logo_3.png',
                        width: 240,
                        height: 220,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Welcome Title and Subtitle
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue your journey',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Mobile Number Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.phone_android,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mobile Number',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: controller.mobileController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            onChanged: (value) {
                              if (value.length == 10) {
                                FocusScope.of(context).unfocus();
                              }
                            },
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your mobile number',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                              ),
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              filled: true,
                              fillColor: AppColors.kSurfaceColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(14),
                                child: Text(
                                  '+91',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    // OTP Field - Initially Hidden
                    Obx(
                      () => controller.isOtpSent.value
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.lock_outline,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Enter OTP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                AutofillGroup(
                                  child: Row(
                                    children: List.generate(6, (index) {
                                      return Expanded(
                                        child: Container(
                                          height: 56,
                                          margin: EdgeInsets.only(
                                            left: index == 0 ? 0 : 4,
                                            right: index == 5 ? 0 : 4,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withValues(alpha: 0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            controller: controller
                                                .otpControllers[index],
                                            focusNode: controller
                                                .otpFocusNodes[index],
                                            keyboardType:
                                                const TextInputType
                                                    .numberWithOptions(
                                              signed: false,
                                              decimal: false,
                                            ),
                                            textInputAction: index < 5
                                                ? TextInputAction.next
                                                : TextInputAction.done,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                            cursorColor: AppColors.primary,
                                            showCursor: true,
                                            autofocus: index == 0,
                                            enableSuggestions: false,
                                            autocorrect: false,
                                            enableIMEPersonalizedLearning:
                                                false,
                                            smartDashesType:
                                                SmartDashesType.disabled,
                                            smartQuotesType:
                                                SmartQuotesType.disabled,
                                            autofillHints: index == 0
                                                ? const [
                                                    AutofillHints.oneTimeCode,
                                                  ]
                                                : null,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                index == 0 ? 6 : 1,
                                              ),
                                            ],
                                            decoration: InputDecoration(
                                              counterText: '',
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 14,
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: const BorderSide(
                                                  color: AppColors.primary,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              controller.otpFocusNodes[index]
                                                  .requestFocus();
                                            },
                                            onChanged: (value) => controller
                                                .onOtpChanged(index, value),
                                            onSubmitted: (_) {
                                              if (index < 5) {
                                                controller
                                                    .otpFocusNodes[index + 1]
                                                    .requestFocus();
                                              } else {
                                                controller.verifyOtp();
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 32),
                    // Send OTP Button - Hidden after OTP is sent
                    Obx(
                      () =>
                          !controller.isOtpSent.value
                              ? Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.kPrimaryVariant,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed:
                                      controller.isLoading.value
                                          ? null
                                          : controller.sendOtp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child:
                                      controller.isLoading.value
                                          ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.send,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Send OTP',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 20),
                    // Verify OTP Button - Initially Hidden
                    Obx(
                      () =>
                          controller.isOtpSent.value
                              ? Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.kPrimaryVariant,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed:
                                      controller.isLoading.value
                                          ? null
                                          : controller.verifyOtp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child:
                                      controller.isLoading.value
                                          ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.verified,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Verify OTP',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                    if (controller.isOtpSent.value) ...[
                      const SizedBox(height: 16),
                      Obx(() => controller.resendSecondsLeft.value > 0
                        ? Center(
                            child: Text(
                              'Resend OTP in ${controller.resendTimerText}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          )
                        : Center(
                            child: TextButton.icon(
                              onPressed: controller.resendOtp,
                              icon: const Icon(
                                Icons.refresh,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              label: Text(
                                'Resend OTP',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Get.back();
                        } else {
                          Get.offAll(() => HomeScreen());
                        }
                      },
                      child: Text(
                        'Continue browsing',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
