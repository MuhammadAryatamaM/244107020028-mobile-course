/// Dio HTTP client builder with auth interceptor & auto-refresh on 401.
/// Moved from lib/data/api_client.dart → features/auth/data/datasources/
import 'package:dio/dio.dart';

import '../repositories/auth_repository_impl.dart';
import '../../domain/repositories/i_token_store.dart';

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
      final access = await tokenStore.readAccessToken();
      if (access != null) {
        options.headers['Authorization'] = 'Bearer $access';
      }
      handler.next(options);
    },
    onError: (e, handler) async {
      if (e.response?.statusCode == 401) {
        final refresh = await tokenStore.readRefreshToken();
        if (refresh == null) return handler.next(e);

        try {
          // Use dedicated repo (no interceptor) to refresh
          final refreshResult = await refreshAuthRepo.refreshToken(refresh);
          if (refreshResult.failure != null) {
            await tokenStore.clear();
            return handler.next(e);
          }

          final newAccess = refreshResult.accessToken!;
          await tokenStore.save(accessToken: newAccess, refreshToken: refresh);

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