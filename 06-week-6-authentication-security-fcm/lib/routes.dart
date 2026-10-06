abstract class AppRoutes {
  // Rute Utama
  static const String home = '/';
  static const String login = '/login';

  // Rute Pengumuman (Pattern untuk GoRouter)
  static const String announcementDetailPath = '/pengumuman/:id';

  // Helper untuk membuat rute dinamis dengan ID (misal deep link / push notification)
  static String announcementDetail(String id) => '/pengumuman/$id';
}
