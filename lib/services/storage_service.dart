import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String tokenKey = 'auth_token';
  static const String firstTimeKey = 'is_first_time';
  static const String isProfileCompletedKey = 'is_profile_completed';
  static const String mobileKey = 'user_mobile';
  static const String loginMethodKey = 'login_method';
  static const String deviceIdKey = 'device_id';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<void> saveToken(String token) async {
    await _prefs.setString(tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(tokenKey);
  }

  bool? getIsFirstTime() {
    return _prefs.getBool(firstTimeKey);
  }

  Future<void> setIsFirstTime(bool value) async {
    await _prefs.setBool(firstTimeKey, value);
  }

  Future<void> saveIsProfileCompleted(bool value) async {
    await _prefs.setBool(isProfileCompletedKey, value);
  }

  bool getIsProfileCompleted() {
    return _prefs.getBool(isProfileCompletedKey) ?? false;
  }

  Future<void> saveMobile(String mobile) async {
    await _prefs.setString(mobileKey, mobile);
  }

  String? getMobile() {
    return _prefs.getString(mobileKey);
  }

  Future<void> saveLoginMethod(String method) async {
    await _prefs.setString(loginMethodKey, method);
  }

  String getLoginMethod() {
    return _prefs.getString(loginMethodKey) ?? 'otp';
  }

  bool get isOtpLogin => getLoginMethod() == 'otp';

  Future<void> saveDeviceId(String deviceId) async {
    await _prefs.setString(deviceIdKey, deviceId);
  }

  String? getDeviceId() {
    return _prefs.getString(deviceIdKey);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
} 