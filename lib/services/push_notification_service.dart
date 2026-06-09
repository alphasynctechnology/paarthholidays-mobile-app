import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';
import '../screens/home/bookings/booking_details_screen.dart';
import 'api_service.dart';
import 'storage_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class PushNotificationService with WidgetsBindingObserver {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();

  bool _initialized = false;
  bool _lifecycleObserverAttached = false;
  bool _deferredSyncScheduled = false;
  bool _loggedFcmUnavailable = false;
  String? _deviceId;
  String? _lastRegisteredToken;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await _setupLocalNotifications();
      await _requestPermissions();

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);

      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _attachLifecycleObserver();
      _initialized = true;
    } catch (e) {
      debugPrint('Push notifications unavailable: $e');
      return;
    }

    await syncTokenIfLoggedIn();
  }

  void _attachLifecycleObserver() {
    if (_lifecycleObserverAttached) {
      return;
    }
    WidgetsBinding.instance.addObserver(this);
    _lifecycleObserverAttached = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      syncTokenIfLoggedIn();
    }
  }

  void scheduleDeferredTokenSync() {
    if (!_initialized || _deferredSyncScheduled) {
      return;
    }

    _deferredSyncScheduled = true;
    for (final delay in [const Duration(seconds: 5), const Duration(seconds: 20)]) {
      Future<void>.delayed(delay, () async {
        await syncTokenIfLoggedIn();
      });
    }
    Future<void>.delayed(const Duration(seconds: 45), () {
      _deferredSyncScheduled = false;
    });
  }

  Future<void> syncTokenIfLoggedIn() async {
    if (!_initialized) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);
      final authToken = storage.getToken();

      if (authToken == null || authToken.isEmpty) {
        return;
      }

      final fcmToken = await _getFcmToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        return;
      }

      if (fcmToken == _lastRegisteredToken) {
        return;
      }

      await _registerToken(fcmToken);
      _lastRegisteredToken = fcmToken;
      if (kDebugMode) {
        final preview = fcmToken.length > 12 ? '${fcmToken.substring(0, 12)}...' : fcmToken;
        debugPrint('FCM token registered with server ($preview)');
      }
    } catch (e) {
      debugPrint('FCM token sync failed: $e');
    }
  }

  Future<bool> _canUseFcmOnDevice() async {
    if (kIsWeb) {
      return false;
    }

    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    try {
      final status = await GoogleApiAvailability.instance
          .checkGooglePlayServicesAvailability();
      if (status == GooglePlayServicesAvailability.success) {
        return true;
      }

      _logFcmUnavailableOnce(
        'Google Play Services unavailable ($status). Update Play services on this device.',
      );
      return false;
    } catch (e) {
      debugPrint('Google Play Services check failed: $e');
      return true;
    }
  }

  Future<String?> _getFcmToken() async {
    if (!await _canUseFcmOnDevice()) {
      return null;
    }

    const maxAttempts = 5;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(seconds: 3 * attempt));
      }

      final token = await _tryGetTokenOnce();
      if (token != null && token.isNotEmpty) {
        return token;
      }
    }

    return null;
  }

  Future<String?> _tryGetTokenOnce() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } on FirebaseException catch (e) {
      if (_isServiceNotAvailable(e)) {
        _logFcmUnavailableOnce(
          'FCM SERVICE_NOT_AVAILABLE — add your app SHA-1 and SHA-256 in Firebase Console '
          '(project paarth-hcm → Android app → Add fingerprint). Use the same keystore as '
          'this build (debug vs release). Then reinstall the app.',
        );
      } else {
        debugPrint('FCM getToken failed: ${e.code} ${e.message}');
      }
      return null;
    } catch (e) {
      debugPrint('FCM getToken failed: $e');
      return null;
    }
  }

  bool _isServiceNotAvailable(FirebaseException e) {
    final message = e.message?.toLowerCase() ?? '';
    return message.contains('service_not_available') ||
        message.contains('ioexception');
  }

  void _logFcmUnavailableOnce(String message) {
    if (_loggedFcmUnavailable) {
      return;
    }
    _loggedFcmUnavailable = true;
    debugPrint('Push notifications: $message');
  }

  Future<void> unregisterToken() async {
    if (!_initialized) {
      return;
    }

    try {
      final deviceId = await _getDeviceId();
      await _apiService.removeFcmToken(deviceId: deviceId);
      _lastRegisteredToken = null;
      try {
        await FirebaseMessaging.instance.deleteToken();
      } on FirebaseException catch (e) {
        debugPrint('FCM deleteToken skipped: ${e.code}');
      }
    } catch (e) {
      debugPrint('Failed to unregister FCM token: $e');
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      final deviceId = await _getDeviceId();
      final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
      await _apiService.saveFcmToken(
        deviceId: deviceId,
        token: token,
        platform: platform,
      );
      _lastRegisteredToken = token;
    } catch (e) {
      debugPrint('Failed to register FCM token with API: $e');
    }
  }

  Future<String> _getDeviceId() async {
    if (_deviceId != null) {
      return _deviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);
    final existing = storage.getDeviceId();

    if (existing != null && existing.isNotEmpty) {
      _deviceId = existing;
      return existing;
    }

    final random = Random();
    final generated =
        'ph-${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(999999)}';
    await storage.saveDeviceId(generated);
    _deviceId = generated;
    return generated;
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          Get.to(() => BookingDetailsScreen(enquiryId: payload));
        }
      },
    );

    const channel = AndroidNotificationChannel(
      'paarth_holidays',
      'Paarth Holidays',
      description: 'Booking reminders and tour updates',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _onForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      _showForegroundNotification(message);
      return;
    }

    final title = message.data['title']?.toString();
    final body = message.data['body']?.toString() ?? message.data['description']?.toString();
    if (title != null && title.isNotEmpty && body != null && body.isNotEmpty) {
      _showLocalNotification(
        title: title,
        body: body,
        enquiryId: message.data['enquiry_id']?.toString() ?? '',
      );
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    await _showLocalNotification(
      title: notification.title ?? 'Paarth Holidays',
      body: notification.body ?? '',
      enquiryId: message.data['enquiry_id']?.toString() ?? '',
    );
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String enquiryId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'paarth_holidays',
      'Paarth Holidays',
      channelDescription: 'Booking reminders and tour updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      title.hashCode,
      title,
      body,
      details,
      payload: enquiryId,
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final enquiryId = message.data['enquiry_id'];
    if (enquiryId != null && enquiryId.toString().isNotEmpty) {
      Get.to(() => BookingDetailsScreen(enquiryId: enquiryId.toString()));
    }
  }
}
