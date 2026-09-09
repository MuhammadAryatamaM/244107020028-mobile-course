import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

// StatsPage adalah ConsumerWidget agar bisa memantau perubahan state dari Riverpod
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau (watch) state dari statsProvider secara real-time
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: statsAsync.when(
        // skipLoadingOnRefresh diset false agar setiap ref.invalidate dipanggil,
        // UI akan kembali menampilkan efek loading selama 2 detik.
        skipLoadingOnRefresh: false, 

        // 1. Kondisi saat sedang memuat data (Loading)
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        // 2. Kondisi saat terjadi throw Exception (Error 30%)
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              // Menampilkan pesan error dari provider
              Text(error.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              // Tombol untuk memuat ulang data (Retry)
              FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                // Memusnahkan state lama dan memicu ulang proses build()
                onPressed: () => ref.invalidate(statsProvider),
              ),
            ],
          ),
        ),

        // 3. Kondisi saat data sukses dimuat
        data: (stats) => ListView.builder(
          itemCount: stats.length, // Berjumlah 3 item
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.teal),
              title: Text(stats[index]),
            );
          },
        ),
      ),
    );
  }
}
