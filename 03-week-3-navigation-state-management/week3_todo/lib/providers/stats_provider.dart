import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider ini menyediakan instance Random().
// Tujuan pemisahan ini adalah agar kita bisa melakukan Override saat Unit Testing.
final randomProvider = Provider<Random>((ref) => Random());

// Notifier yang menangani state (memuat data statistik).
class StatsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    // 1. Membaca instance Random dari provider (Selalu gunakan watch sebelum await).
    final random = ref.watch(randomProvider);

    // 2. Simulasi proses pengambilan data ke server (delay 2 detik).
    await Future.delayed(const Duration(seconds: 2));

    // 3. Menghasilkan angka acak antara 0.0 - 1.0.
    // Jika angkanya di bawah 0.3, kita asumsikan sebagai gagal (probabilitas gagal 30%).
    if (random.nextDouble() < 0.9) {
      throw Exception('Gagal memuat statistik. Server sedang sibuk.');
    }

    // 4. Jika sukses (angka >= 0.3), kembalikan List berisi 3 data.
    return [
      'Total Pengunjung: 1.542',
      'Pengguna Aktif: 430',
      'Tingkat Retensi: 85%',
    ];
  }
}

// Provider global untuk mengakses State dari StatsNotifier.
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
);
