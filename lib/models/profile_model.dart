class ProfileModel {
  final String name;
  final String email;
  final String mobile;
  final String gender;
  final String referralCode;
  final bool hasPassword;

  ProfileModel({
    required this.name,
    required this.email,
    required this.mobile,
    this.gender = '',
    this.referralCode = '',
    this.hasPassword = false,
  });

  String displayName(String fallback) =>
      name.trim().isNotEmpty ? name.trim() : fallback;

  String displayEmail() =>
      email.trim().isNotEmpty ? email.trim() : 'Not set';

  String displayMobile(String fallback) {
    final value = mobile.trim();
    if (value.isNotEmpty) return value;
    return fallback.trim().isNotEmpty ? fallback.trim() : 'Not set';
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: _pick(json, ['name', 'guestname', 'full_name']),
      email: _pick(json, ['email', 'guestemail1', 'guest_email']),
      mobile: _pick(json, [
        'mobile',
        'guestmob1',
        'guestmob',
        'mobile_number',
        'phone',
      ]),
      gender: _pick(json, ['gender', 'guestgender']),
      referralCode: _pick(json, ['referral_code', 'referralCode']),
      hasPassword: json['has_password'] == true ||
          json['has_password'] == 1 ||
          json['has_password'] == '1',
    );
  }

  static String _pick(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return '';
  }
} 