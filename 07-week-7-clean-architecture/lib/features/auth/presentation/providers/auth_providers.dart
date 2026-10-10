/// Auth feature presentation providers — wiring DI + state holder (Notifier).
/// Single source of truth for all auth-related Riverpod providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../core/failures.dart';
import '../../../data/datasources/api_client.dart';
import '../../../data/datasources/token_store_impl.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/repositories/i_token_store.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/refresh_token_usecase.dart';
import '../../../domain/usecases/post_device_token_usecase.dart';
import '../../../../notifications/domain/services/i_push_service.dart';

// ==========================================
// DATA LAYER PROVIDERS
// ==========================================

/// Token storage implementation (wraps FlutterSecureStorage)
final tokenStoreProvider = Provider<ITokenStore>((ref) {
  return TokenStoreImpl();
});

/// HTTP Client (Dio) with auth interceptor & auto-refresh on 401.
/// Uses a dedicated AuthRepositoryImpl WITHOUT interceptor for token refresh
/// to avoid circular dependency and infinite loop on 401 during refresh.
final apiClientProvider = Provider<Dio>((ref) {
  final tokenStore = ref.watch(tokenStoreProvider);
  final refreshAuthRepo = AuthRepositoryImpl(
    dio: Dio(BaseOptions(baseUrl: 'https://example-campus-api.test')),
    tokenStore: tokenStore,
  );
  return buildApiClient(
    tokenStore: tokenStore,
    refreshAuthRepo: refreshAuthRepo,
  );
});

/// Repository implementation (implements IAuthRepository)
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    dio: ref.watch(apiClientProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
});

// ==========================================
// DOMAIN LAYER PROVIDERS (Use Cases)
// ==========================================

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    tokenStore: ref.watch(tokenStoreProvider),
    pushService: ref.watch(pushServiceProvider), // from notifications feature
  );
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  return RefreshTokenUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
});

final postDeviceTokenUseCaseProvider = Provider<PostDeviceTokenUseCase>((ref) {
  return PostDeviceTokenUseCase(ref.watch(authRepositoryProvider));
});

// ==========================================
// PRESENTATION LAYER (State Holder)
// ==========================================

/// Auth state: true = logged in, false = logged out.
/// AsyncValue for loading/error handling.
final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

/// Auth notifier — orchestrates use cases, exposes state to UI.
class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    // Check if access token exists on app start
    final hasToken = await ref.watch(tokenStoreProvider).hasToken();
    return hasToken;
  }

  /// Login with email & password.
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    final result = await ref.watch(loginUseCaseProvider)(
      email: email,
      password: password,
    );

    if (result.failure != null) {
      state = AsyncError(result.failure!.message, StackTrace.current);
    } else {
      state = const AsyncData(true);
    }
  }

  /// Logout — clear tokens and invalidate state.
  Future<void> logout() async {
    await ref.watch(tokenStoreProvider).clear();
    ref.invalidateSelf(); // Triggers rebuild of authStateProvider
  }
}