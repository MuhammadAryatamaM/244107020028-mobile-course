/// Dio HTTP client builder with auth interceptor & auto-refresh on 401.
/// Moved from lib/data/api_client.dart → features/auth/data/datasources/
import 'package:dio/dio.dart';

import 'package:campus_notify/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:campus_notify/features/auth/domain/repositories/i_token_store.dart';

/// Build configured Dio instance.
/// [tokenStore] for reading access token.
/// [refreshAuthRepo] dedicated repo instance WITHOUT interceptor (to avoid circular dep & infinite loop on 401 during refresh).
Dio buildApiClient({
  required ITokenStore tokenStore,
  required AuthRepositoryImpl refreshAuthRepo,
  String baseUrl = 'https://example-campus-api.test',
}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final accessResult = await tokenStore.readAccessToken();
      if (accessResult.failure != null) {
        // Log failure but continue without token
        // In production, you might want to handle this differently
      } else if (accessResult.token != null) {
        options.headers['Authorization'] = 'Bearer ${accessResult.token}';
      }
      handler.next(options);
    },
    onError: (e, handler) async {
      if (e.response?.statusCode == 401) {
        final readResult = await tokenStore.readRefreshToken();
        if (readResult.failure != null || readResult.token == null) {
          return handler.next(e);
        }

        try {
          // Use dedicated repo (no interceptor) to refresh
          final refreshResult = await refreshAuthRepo.refreshToken(readResult.token!);
          if (refreshResult.failure != null) {
            await tokenStore.clear();
            return handler.next(e);
          }

          final newAccess = refreshResult.accessToken!;
          final saveResult = await tokenStore.save(accessToken: newAccess, refreshToken: readResult.token!);
          if (saveResult != null) {
            // Save failed, clear and continue
            await tokenStore.clear();
            return handler.next(e);
          }

          // Retry original request with new token
          final retry = await dio.fetch(
            e.requestOptions..headers['Authorization'] = 'Bearer $newAccess',
          );
          return handler.resolve(retry);
        } catch (_) {
          await tokenStore.clear();
          return handler.next(e);
        }
      }
      handler.next(e);
    },
  ));

  return dio;
}