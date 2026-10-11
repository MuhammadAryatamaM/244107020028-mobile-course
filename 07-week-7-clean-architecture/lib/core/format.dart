/// Pure formatting & parsing utilities — no Flutter, no framework.
/// Fully testable without widget testing.

import 'package:campus_notify/routes.dart';

/// Format DateTime as 'dd/MM/yyyy HH:mm'
String formatDateTime(DateTime dt) {
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
         '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

/// Format DateTime as 'dd/MM/yyyy'
String formatDate(DateTime dt) {
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

/// Extract route from FCM message data payload.
/// Returns [AppRoutes.home] if route missing/empty.
String routeFromMessage(Map<String, dynamic> data) {
  final route = data['route'];
  if (route is String && route.trim().isNotEmpty) {
    return route;
  }
  return AppRoutes.home;
}