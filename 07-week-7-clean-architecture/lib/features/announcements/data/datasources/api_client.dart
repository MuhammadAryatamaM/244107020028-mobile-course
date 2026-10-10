/// Announcement API data source — uses shared Dio from auth feature.
/// This is a thin wrapper; the actual Dio instance comes from auth's apiClientProvider.
import 'package:dio/dio.dart';

/// Get Dio instance configured with auth interceptor.
/// In providers, we'll use ref.watch(apiClientProvider) from auth feature.
Dio getAnnouncementApiClient(Dio dio) => dio;