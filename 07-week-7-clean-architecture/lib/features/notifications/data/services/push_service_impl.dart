/// Push notification service implementation — wraps Firebase Messaging & Local Notifications.
/// Implements [IPushService] domain interface.
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../core/failures.dart';
import '../../../../auth/domain/repositories/i_auth_repository.dart';
import '../../../domain/services/i_push_service.dart';
import '../../../../routes.dart';

final _localNotifications = FlutterLocalNotificationsPlugin();

/// Extract route from FCM message data payload.
String _routeFromMessage(Map<String, dynamic> data) {
  final route = data['route'];
  if (route is String && route.trim().isNotEmpty) {
    return route;
  }
  return AppRoutes.home;
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Background handling: data-only messages, no UI interaction needed here
  // Notification tap handled by onMessageOpenedApp / getInitialMessage
}

class PushServiceImpl implements IPushService {
  PushServiceImpl({IAuthRepository? authRepository}) : _authRepository = authRepository;

  final IAuthRepository? _authRepository;
  bool _initialized = false;

  @override
  Future<void> initialize({
    required Future<void> Function(String token) onToken,
    required Future<void> Function(String route) onMessage,
  }) async {
    if (_initialized) return;
    _initialized = true;

    // Register background handler (platform specific)
    if (!Platform.isLinux && !Platform.isWindows) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }

    // Request permission
    await _requestPermission();

    // Initialize local notifications
    await _initLocalNotifications(onMessage);

    // Listen to foreground messages
    _listenForeground(onMessage);

    // Handle terminated state notification tap
    await _handleTerminated(onMessage);

    // Get initial token & listen for refresh
    await _setupTokenListener(onToken);
  }

  Future<void> _requestPermission() async {
    if (Platform.isLinux || Platform.isWindows) return;

    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (_) {
      // Ignore permission errors
    }
  }

  Future<void> _initLocalNotifications(Future<void> Function(String route) onTap) async {
    if (Platform.isLinux || Platform.isWindows) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const channel = AndroidNotificationChannel(
      'pengumuman_channel',
      'Pengumuman Kampus',
      description: 'Channel untuk notifikasi pengumuman kampus',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) async {
        if (response.payload != null && response.payload!.isNotEmpty) {
          await onTap(response.payload!);
        }
      },
    );
  }

  void _listenForeground(Future<void> Function(String route) onMessage) {
    if (Platform.isLinux || Platform.isWindows) return;

    FirebaseMessaging.onMessage.listen((message) async {
      final route = _routeFromMessage(message.data);

      const androidDetails = AndroidNotificationDetails(
        'pengumuman_channel',
        'Pengumuman Kampus',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      await _localNotifications.show(
        message.hashCode,
        title: message.notification?.title ?? message.data['title'] ?? 'Pengumuman',
        body: message.notification?.body ?? message.data['body'] ?? '',
        notificationDetails: const NotificationDetails(android: androidDetails),
        payload: route,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final route = _routeFromMessage(message.data);
      onMessage(route);
    });
  }

  Future<void> _handleTerminated(Future<void> Function(String route) onMessage) async {
    if (Platform.isLinux || Platform.isWindows) return;

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      final route = _routeFromMessage(initial.data);
      // Small delay to ensure router is ready
      Future.delayed(const Duration(milliseconds: 500), () => onMessage(route));
    }
  }

  Future<void> _setupTokenListener(Future<void> Function(String token) onToken) async {
    if (Platform.isLinux || Platform.isWindows) {
      await onToken('fcm-not-supported-on-desktop');
      return;
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await onToken(token);
      }

      FirebaseMessaging.instance.onTokenRefresh.listen(onToken);
      await subscribeToCampusTopic();
    } catch (_) {
      // Ignore token errors
    }
  }

  @override
  Future<String?> getToken() async {
    if (Platform.isLinux || Platform.isWindows) {
      return 'fcm-not-supported-on-desktop';
    }
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<({bool success, Failure? failure})> postDeviceToken(String token) async {
    if (_authRepository == null) {
      return (success: false, failure: const LocalFailure('AuthRepository tidak tersedia'));
    }
    try {
      await _authRepository!.postDeviceToken(token);
      return (success: true, failure: null);
    } catch (e) {
      return (success: false, failure: LocalFailure('Gagal kirim FCM token: $e'));
    }
  }

  @override
  Future<void> subscribeToCampusTopic() async {
    if (Platform.isLinux || Platform.isWindows) return;
    try {
      await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
    } catch (_) {}
  }

  @override
  Future<void> unsubscribeFromCampusTopic() async {
    if (Platform.isLinux || Platform.isWindows) return;
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
    } catch (_) {}
  }
}