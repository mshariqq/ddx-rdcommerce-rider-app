import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ddx_rider/config/app_constants.dart';
import 'package:ddx_rider/utils/api_client.dart';

class RiderNotificationService {
  final Ref ref;

  RiderNotificationService(this.ref);

  ApiClient get _api => ref.read(apiClientProvider);

  /// GET rider/notifications — query: is_read?.
  /// Response data: {total_unread, notification[]}.
  Future<Response> list({dynamic isRead}) {
    return _api.get(
      AppConstants.riderNotifications,
      query: {if (isRead != null) 'is_read': isRead},
    );
  }

  /// POST rider/notifications — body (NotificationRepository::storeByRequest):
  /// title, content, optional user_id, shop_id, url, icon, type, withdraw_id.
  /// NOTE: the rider NotificationController currently exposes only
  /// index/update/delete — this route has no `store` action server-side yet.
  Future<Response> store(Map<String, dynamic> data) {
    return _api.post(AppConstants.riderNotificationStore, data: data);
  }

  /// POST rider/notifications/{id} — marks the notification read
  /// (readUpdateByRequest sets is_read=1). Path param, no body needed.
  Future<Response> markRead(int id) {
    return _api.post(AppConstants.riderNotificationUpdate(id), data: {});
  }

  /// DELETE rider/notifications/{id} — path param.
  Future<Response> delete(int id) {
    return _api.delete(AppConstants.riderNotificationDelete(id));
  }
}

final riderNotificationServiceProvider =
    Provider((ref) => RiderNotificationService(ref));
