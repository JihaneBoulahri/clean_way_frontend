import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {}
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _notificationPrefKey = 'settings:notifications';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _lastNotificationPayloadKey = 'last_notification_payload';

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'clean_way_high_importance',
    'Clean Way Notifications',
    description: 'Notifications importantes de Clean Way',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final GetStorage _box = GetStorage();

  bool _initialized = false;
  bool _firebaseReady = false;

  bool get notificationsEnabled => (_box.read(_notificationPrefKey) as bool?) ?? true;
  String? get fcmToken => _box.read(_fcmTokenKey) as String?;

  bool get _isMobile {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();

    _initialized = true;
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    await _box.write(_notificationPrefKey, enabled);

    if (enabled) {
      final localPermissionGranted = await _requestLocalPermission();
      if (!localPermissionGranted) {
        await _box.write(_notificationPrefKey, false);
        return false;
      }

      if (_firebaseReady) {
        final settings = await _requestPermission();
        if (!_isPermissionGranted(settings)) {
          await _box.write(_notificationPrefKey, false);
          return false;
        }
        await refreshToken();
      }

      return true;
    }

    await _localNotifications.cancelAll();
    await clearToken();
    return true;
  }

  Future<void> showNotification(
    String title,
    String body, {
    String? payload,
    int? id,
  }) async {
    if (!notificationsEnabled) return;

    final notificationId = id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const iosDetails = DarwinNotificationDetails();
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notificationId,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> showLocalTestNotification() async {
    await showNotification(
      'Notifications activées',
      'Les notifications locales sont maintenant actives.',
    );
  }

  Future<void> refreshToken() async {
    if (!_firebaseReady) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _box.write(_fcmTokenKey, token);
      }
    } catch (e) {
      debugPrint('NotificationService: token refresh failed: $e');
    }
  }

  Future<void> clearToken() async {
    await _box.remove(_fcmTokenKey);
    if (!_firebaseReady) return;

    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('NotificationService: token delete failed: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initializationSettings);

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
  }

  Future<void> _initializeFirebaseMessaging() async {
    if (!_isMobile) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _firebaseReady = true;
    } catch (e) {
      debugPrint('NotificationService: Firebase not configured yet: $e');
      return;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    try {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
    } catch (_) {}

    if (notificationsEnabled) {
      final settings = await _requestPermission();
      if (_isPermissionGranted(settings)) {
        await refreshToken();
      }
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      if (token.isNotEmpty) {
        await _box.write(_fcmTokenKey, token);
      }
    });

    FirebaseMessaging.onMessage.listen((message) async {
      if (!notificationsEnabled) return;
      await _showForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_saveNotificationPayload);
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _saveNotificationPayload(initialMessage);
    }
  }

  Future<NotificationSettings> _requestPermission() {
    return FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<bool> _requestLocalPermission() async {
    if (kIsWeb) return true;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? true;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final macPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
      final granted = await macPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  bool _isPermissionGranted(NotificationSettings settings) {
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Nouvelle notification';
    final body = message.notification?.body ?? '';
    final payload = message.data.isEmpty ? null : jsonEncode(message.data);

    const iosDetails = DarwinNotificationDetails();
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> _saveNotificationPayload(RemoteMessage message) async {
    if (message.data.isEmpty) return;
    await _box.write(_lastNotificationPayloadKey, message.data);
  }
}
