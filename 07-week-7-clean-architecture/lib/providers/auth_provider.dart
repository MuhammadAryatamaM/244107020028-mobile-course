import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../data/api_client.dart';
import '../data/auth_repository.dart';
import '../data/token_store.dart';

// 1. Data Layer Providers

/// Provider untuk penyimpanan token aman (Secure Storage)
final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

/// Provider HTTP Client (Dio) yang sudah dilengkapi interceptor
/// untuk auto-inject Bearer Token & auto-refresh token saat 401
final apiClientProvider = Provider<Dio>((ref) {
  final store = ref.watch(tokenStoreProvider);

  // Gunakan AuthRepository khusus (tanpa interceptor) untuk proses refresh.
  // Ini penting untuk mencegah circular dependency antara apiClientProvider & authRepositoryProvider,
  // sekaligus menghindari infinite loop jika endpoint /refresh mengembalikan error 401.
  final rawAuthRepo = AuthRepository();
  return buildApiClient(store, rawAuthRepo);
});

/// Provider Repository Autentikasi yang menggunakan Dio dari apiClientProvider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return AuthRepository(dio);
});

// 2. Auth State Notifier

final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    // Cek ketersediaan access token saat aplikasi pertama kali dimuat
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    // AsyncValue.guard otomatis menangkap String pesan error
    // hasil konversi ApiErrorMapper dari AuthRepository
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);

      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);

      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    ref.invalidateSelf();
  }
}
