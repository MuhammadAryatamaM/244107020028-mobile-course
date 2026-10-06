import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../routes.dart';

final _local = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void registerBackgroundHandler() {
  if (Platform.isLinux || Platform.isWindows) return;
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

Future<bool> requestNotificationPermission() async {
  if (Platform.isLinux || Platform.isWindows) return false;

  try {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  } catch (_) {
    return false;
  }
}

Future<void> initLocalNotifications(void Function(String route) go) async {
  if (Platform.isLinux || Platform.isWindows) return;

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'pengumuman_channel',
    'Pengumuman Kampus',
    description: 'Channel untuk notifikasi pengumuman kampus',
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin localPlugin =
      FlutterLocalNotificationsPlugin();

  await localPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      if (response.payload != null && response.payload!.isNotEmpty) {
        go(response.payload!);
      }
    },
  );
}

void listenForeground(void Function(String route) go) {
  if (Platform.isLinux || Platform.isWindows) return;

  FirebaseMessaging.onMessage.listen((message) async {
    final route = message.data['route'] ?? AppRoutes.home;

    const androidDetails = AndroidNotificationDetails(
      'pengumuman_channel',
      'Pengumuman Kampus',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    await _local.show(
      id: message.hashCode,
      title:
          message.notification?.title ?? message.data['title'] ?? 'Pengumuman',
      body: message.notification?.body ?? message.data['body'] ?? '',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: route,
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final route = message.data['route'] ?? AppRoutes.home;
    go(route);
  });
}

Future<void> handleTerminated(void Function(String route) go) async {
  if (Platform.isLinux || Platform.isWindows) return;

  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    final route = initial.data['route'] ?? AppRoutes.home;
    Future.delayed(const Duration(milliseconds: 500), () {
      go(route);
    });
  }
}

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  if (Platform.isLinux || Platform.isWindows) {
    await onToken('fcm-not-supported-on-desktop');
    return;
  }

  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await onToken(token);

    FirebaseMessaging.instance.onTokenRefresh.listen(onToken);
    await subscribeToCampusTopic();
  } catch (_) {}
}

Future<void> subscribeToCampusTopic() async {
  if (Platform.isLinux || Platform.isWindows) return;
  await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
}

Future<void> unsubscribeFromCampusTopic() async {
  if (Platform.isLinux || Platform.isWindows) return;
  await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
}
