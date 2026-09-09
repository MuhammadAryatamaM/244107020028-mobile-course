import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Gunakan package import untuk file di dalam folder lib
import 'package:week3_todo/providers/stats_provider.dart';

// --- MOCK OBJECTS ---
// Kita membuat versi palsu dari Random() untuk mengontrol peluang di Unit Test

// 1. Mock ini selalu memunculkan angka 0.5 (di atas 0.3) agar selalu Sukses
class MockRandomSuccess implements Random {
  @override
  double nextDouble() => 0.5;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => true;
}

// 2. Mock ini selalu memunculkan angka 0.1 (di bawah 0.3) agar selalu Gagal
class MockRandomFail implements Random {
  @override
  double nextDouble() => 0.1;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
}

void main() {
  group('StatsNotifier Tests', () {
    // KITA MENGGUNAKAN testWidgets AGAR MENDAPATKAN FITUR "FakeAsync".
    // Dengan FakeAsync, Future.delayed(2 detik) bisa kita "percepat"
    // menjadi seketika (instan) tanpa benar-benar menunggu.
    testWidgets('Berhasil memuat 3 data statistik (Skenario Sukses)', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [randomProvider.overrideWithValue(MockRandomSuccess())],
      );
      addTearDown(container.dispose);

      // Pastikan status awalnya adalah loading
      expect(container.read(statsProvider).isLoading, true);

      // Memajukan waktu virtual sebanyak 2 detik secara instan
      await tester.pump(const Duration(seconds: 2));

      // Verifikasi status akhirnya
      final state = container.read(statsProvider);
      expect(state.isLoading, false);
      expect(state.hasError, false);
      expect(state.value?.length, 3);
    });

    testWidgets(
      'Memunculkan exception saat server sibuk (Skenario Gagal 30%)',
      (tester) async {
        final container = ProviderContainer(
          overrides: [randomProvider.overrideWithValue(MockRandomFail())],
        );
        addTearDown(container.dispose);

        // Memastikan Riverpod tidak mematikan provider ini
        final subscription = container.listen(statsProvider, (_, _) {});

        // Pastikan status awalnya adalah loading
        expect(subscription.read().isLoading, true);

        // Memajukan waktu virtual sebanyak 2 detik secara instan.
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();

        // Verifikasi bahwa statusnya memiliki error
        final state = subscription.read();
        expect(state.hasError, true);

        // SANGAT PENTING: Matikan container secara eksplisit sebelum testWidgets selesai
        // agar tidak ada timer internal Riverpod (seperti timer retry) yang tertinggal
        // dan memicu assertion 'timersPending'.
        container.dispose();
      },
    );
  });
}
