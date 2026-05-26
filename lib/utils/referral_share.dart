import 'package:share_plus/share_plus.dart';

class ReferralShare {
  static const String appLink = 'https://macha.tours';

  static String buildMessage({
    required String referralCode,
    String? customMessage,
  }) {
    if (customMessage != null && customMessage.trim().isNotEmpty) {
      return customMessage.trim();
    }

    return 'Join Paarth Holidays using my referral code $referralCode '
        'and explore amazing holiday packages! Download the app or visit $appLink';
  }

  static Future<void> share({
    required String referralCode,
    String? customMessage,
  }) async {
    await Share.share(
      buildMessage(
        referralCode: referralCode,
        customMessage: customMessage,
      ),
      subject: 'Paarth Holidays Referral',
    );
  }
}
