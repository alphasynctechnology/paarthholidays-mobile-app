import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/app_bar.dart';
import '../../controllers/wallet_controller.dart';
import '../home/widgets/home_section_header.dart';
import 'widgets/wallet_widgets.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());

    return Scaffold(
      backgroundColor: AppColors.kSurfaceColor,
      appBar: const CommonAppBar(title: 'Reward Wallet', showWalletIcon: false),
      body: Obx(() {
        if (controller.isLoading.value && controller.wallet.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchWallet,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Obx(() {
                  final wallet = controller.wallet.value;
                  return WalletBalanceCard(
                    points: wallet?.points ?? 0,
                    pointsInInr: wallet?.pointsInInr ?? '',
                    unit: wallet?.unit ?? '',
                    totalEarnedPoints: wallet?.totalEarnedPoints ?? '',
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Obx(() {
                  final wallet = controller.wallet.value;
                  if (wallet == null || wallet.referralCode.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return WalletReferCard(
                    referralCode: wallet.referralCode,
                    referralMessage: wallet.referralMessage,
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: WalletEarnInfoCard(
                  onTap: () => showHowToEarnSheet(context),
                ),
              ),
              const HomeSectionHeader(
                title: 'Recent Transactions',
                subtitle: 'Your reward point activity',
                icon: Icons.receipt_long_outlined,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  final transactions =
                      controller.wallet.value?.transactions ?? [];

                  if (transactions.isEmpty) {
                    return const WalletEmptyTransactions();
                  }

                  return Column(
                    children: transactions
                        .map((t) => WalletTransactionTile(transaction: t))
                        .toList(),
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }
}
