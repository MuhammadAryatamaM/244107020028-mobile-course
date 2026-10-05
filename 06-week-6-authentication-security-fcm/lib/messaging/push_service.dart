import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _local = FlutterLocalNotificationsPlugin();

// TOP-LEVEL BACKGROUND HANDLER
// WAJIB ditandai dengan anotasi ini agar tidak di-strip oleh compiler saat mode Release
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // BISA: Inisialisasi Firebase
  await Firebase.initializeApp();

  // BISA: Menyimpan data ke SQLite / flutter_secure_storage
  // BISA: Melakukan request HTTP ke backend (dio/http)

  // DILARANG KERAS (Akan menyebabkan Crash/Exception):
  // Navigator.push(context, ...);
  // Provider.of<T>(context);
  // setState(() {});
}

void registerBackgroundHandler() {
  if (Platform.isLinux || Platform.isWindows) return;
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

// PERMISSION & LOCAL NOTIFICATION INITIALIZATION
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

  // KHUSUS ANDROID: Wajib mendefinisikan icon bawaan (biasanya di res/mipmap)
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');

  // KHUSUS IOS: Menggunakan DarwinInitializationSettings (Apple/iOS/macOS)
  const ios = DarwinInitializationSettings();

  // KHUSUS ANDROID 8.0+ (termasuk 13+): Wajib membuat "Channel" untuk menentukan
  // prioritas (Importance.max) agar banner muncul dari atas layar.
  // iOS tidak menggunakan sistem Channel seperti ini.
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'pengumuman_channel',
    'Pengumuman Kampus',
    description: 'Channel untuk notifikasi pengumuman kampus',
    importance:
        Importance.max, // Wajib MAX untuk heads-up notification di Android
  );

  final FlutterLocalNotificationsPlugin localPlugin =
      FlutterLocalNotificationsPlugin();

  // KHUSUS ANDROID: Mendaftarkan channel ke OS secara spesifik
  await localPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  await _local.initialize(
    // Menggabungkan pengaturan spesifik kedua OS
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      if (response.payload != null && response.payload!.isNotEmpty) {
        go(response.payload!);
      }
    },
  );
}

// HANDLER MESSAGING
void listenForeground(void Function(String route) go) {
  if (Platform.isLinux || Platform.isWindows) return;

  // 1. Tampilkan Banner saat Foreground
  FirebaseMessaging.onMessage.listen((message) async {
    final route = message.data['route'] ?? '/';

    const androidDetails = AndroidNotificationDetails(
      'pengumuman_channel', // Harus sama dengan Channel ID Android di atas
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
      // Saat ini hanya mengirimkan detail spesifik Android.
      // Untuk iOS, detailnya bisa ditambahkan via parameter 'iOS: DarwinNotificationDetails()' jika butuh custom suara/badge.
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: route,
    );
  });

  // 2. Tangani Klik Notifikasi saat Background
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final route = message.data['route'] ?? '/';
    go(route);
  });
}

Future<void> handleTerminated(void Function(String route) go) async {
  if (Platform.isLinux || Platform.isWindows) return;

  // Tangani Klik Notifikasi saat Terminated (Aplikasi Mati Total)
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    final route = initial.data['route'] ?? '/';
    // Beri sedikit jeda agar GoRouter dan AuthState siap
    Future.delayed(const Duration(milliseconds: 500), () {
      go(route);
    });
  }
}

// TOPIC MANAGEMENT & TOKEN INITIALIZATION
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
