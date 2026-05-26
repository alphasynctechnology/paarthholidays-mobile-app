import 'package:url_launcher/url_launcher.dart';

class PhoneLauncher {
  PhoneLauncher._();

  static String cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  static Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> dial(String phone) async {
    final cleaned = cleanPhone(phone);
    if (cleaned.isEmpty) return false;

    return _launch(Uri.parse('tel:$cleaned'));
  }

  static Future<bool> sms(String phone, {String? body}) async {
    final cleaned = cleanPhone(phone);
    if (cleaned.isEmpty) return false;

    final Uri uri;
    if (body != null && body.trim().isNotEmpty) {
      uri = Uri(
        scheme: 'sms',
        path: cleaned,
        queryParameters: {'body': body.trim()},
      );
    } else {
      uri = Uri(scheme: 'sms', path: cleaned);
    }

    return _launch(uri);
  }
}
