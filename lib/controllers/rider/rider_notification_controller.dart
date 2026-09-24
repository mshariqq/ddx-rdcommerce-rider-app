import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ddx_rider/models/rider/rider_notification.dart';
import 'package:ddx_rider/services/rider/rider_notification_service.dart';

@immutable
class RiderNotificationState {
  final bool isLoading;
  final List<RiderNotification> items;
  final int unreadCount;
  final String? error;

  const RiderNotificationState({
    this.isLoading = false,
    this.items = const [],
    this.unreadCount = 0,
    this.error,
  });

  RiderNotificationState copyWith({
    bool? isLoading,
    List<RiderNotification>? items,
    int? unreadCount,
    String? error,
  }) {
    return RiderNotificationState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      error: error,
    );
  }
}

class RiderNotificationController
    extends StateNotifier<RiderNotificationState> {
  RiderNotificationController(this.ref)
      : super(const RiderNotificationState());

  final Ref ref;

  RiderNotificationService get _service =>
      ref.read(riderNotificationServiceProvider);

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static Map<String, dynamic> _dataOf(dynamic body) {
    try {
      final map = body is Map
          ? body.map((k, e) => MapEntry(k.toString(), e))
          : <String, dynamic>{};
      final data = map['data'];
      if (data is Map) return data.map((k, e) => MapEntry(k.toString(), e));
    } catch (_) {}
    return <String, dynamic>{};
  }

  /// GET rider/notifications?is_read -> data:{total_unread,notification[]}.
  Future<void> list({dynamic isRead}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final Response res = await _service.list(isRead: isRead);
      final data = _dataOf(res.data);
      final rawList = data['notification'] ?? data['notifications'];
      final List<RiderNotification> items = rawList is List
          ? RiderNotification.listFromJson(rawList)
          : const <RiderNotification>[];
      state = state.copyWith(
        isLoading: false,
        items: items,
        unreadCount: _asInt(data['total_unread']),
      );
    } catch (e) {
      debugPrint('RiderNotificationController.list: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// POST rider/notifications/{id} (no body) — marks read, updates locally.
  Future<bool> markRead(int id) async {
    try {
      await _service.markRead(id);
      final items = state.items
          .map((n) => n.id == id
              ? RiderNotification(
                  id: n.id,
                  title: n.title,
                  content: n.content,
                  isRead: true,
                  createdAt: n.createdAt,
                  type: n.type,
                  url: n.url,
                  raw: n.raw,
                )
              : n)
          .toList();
      final unread = items.where((n) => n.isRead != true).length;
      state = state.copyWith(items: items, unreadCount: unread);
      return true;
    } catch (e) {
      debugPrint('RiderNotificationController.markRead: $e');
      return false;
    }
  }

  /// DELETE rider/notifications/{id} — removes locally on success.
  Future<bool> delete(int id) async {
    try {
      final Response res = await _service.delete(id);
      final ok = (res.statusCode ?? 500) < 400;
      if (ok) {
        final items = state.items.where((n) => n.id != id).toList();
        state = state.copyWith(
          items: items,
          unreadCount: items.where((n) => n.isRead != true).length,
        );
      }
      return ok;
    } catch (e) {
      debugPrint('RiderNotificationController.delete: $e');
      return false;
    }
  }
}

final riderNotificationControllerProvider =
    StateNotifierProvider<RiderNotificationController, RiderNotificationState>(
        (ref) => RiderNotificationController(ref));

/// Badge count provider (watches the notification list state).
final riderUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(riderNotificationControllerProvider).unreadCount;
});
