import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ddx_rider/models/rider/rider_order.dart';
import 'package:ddx_rider/services/rider/rider_order_service.dart';

@immutable
class RiderOrdersState {
  final bool isLoading;
  final int toDoCount;
  final int completedCount;
  final int total;
  final List<RiderOrder> orders;
  final String? error;

  const RiderOrdersState({
    this.isLoading = false,
    this.toDoCount = 0,
    this.completedCount = 0,
    this.total = 0,
    this.orders = const [],
    this.error,
  });

  RiderOrdersState copyWith({
    bool? isLoading,
    int? toDoCount,
    int? completedCount,
    int? total,
    List<RiderOrder>? orders,
    String? error,
  }) {
    return RiderOrdersState(
      isLoading: isLoading ?? this.isLoading,
      toDoCount: toDoCount ?? this.toDoCount,
      completedCount: completedCount ?? this.completedCount,
      total: total ?? this.total,
      orders: orders ?? this.orders,
      error: error,
    );
  }
}

class RiderOrderController extends StateNotifier<RiderOrdersState> {
  RiderOrderController(this.ref) : super(const RiderOrdersState());

  final Ref ref;

  RiderOrderService get _service => ref.read(riderOrderServiceProvider);

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

  /// GET rider/orders?page,per_page -> data:{to_do_order,completed_order,
  /// total,orders[]}.
  Future<void> orders({int page = 1, int perPage = 20}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final Response res = await _service.orders({
        'page': page,
        'per_page': perPage,
      });
      final data = _dataOf(res.data);
      final list = data['orders'];
      state = state.copyWith(
        isLoading: false,
        toDoCount: _asInt(data['to_do_order']),
        completedCount: _asInt(data['completed_order']),
        total: _asInt(data['total'] ?? (list is List ? list.length : 0)),
        orders: list is List ? RiderOrder.listFromJson(list) : const [],
      );
    } catch (e) {
      debugPrint('RiderOrderController.orders: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// GET rider/my-orders?order_status=to_deliver|delivered,search,page.
  Future<void> myOrders({
    String? status,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final Response res = await _service.myOrders(
        status: status,
        params: {
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          'page': page,
          'per_page': perPage,
        },
      );
      final data = _dataOf(res.data);
      final list = data['orders'];
      state = state.copyWith(
        isLoading: false,
        total: _asInt(data['total'] ?? (list is List ? list.length : 0)),
        orders: list is List ? RiderOrder.listFromJson(list) : const [],
      );
    } catch (e) {
      debugPrint('RiderOrderController.myOrders: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// GET rider/orders/details?order_id=&order_code= (BOTH required).
  Future<RiderOrderDetails?> details({
    required int orderId,
    required String orderCode,
  }) async {
    try {
      final Response res = await _service.details(
        orderId: orderId,
        orderCode: orderCode,
      );
      final data = _dataOf(res.data);
      final payload = data['order'] ?? data['data'] ?? data;
      if (payload is Map && payload.isEmpty) return null;
      return RiderOrderDetails.fromJson(payload);
    } catch (e) {
      debugPrint('RiderOrderController.details: $e');
      return null;
    }
  }

  /// POST rider/orders/status-update {order_id,order_code}.
  /// Server advances the status itself; returns refreshed details (or null).
  Future<RiderOrderDetails?> advanceStage({
    required int orderId,
    required String orderCode,
  }) async {
    try {
      final Response res = await _service.statusUpdate(
        orderId: orderId,
        orderCode: orderCode,
      );
      final data = _dataOf(res.data);
      final payload = data['order'] ?? data['data'] ?? data;
      if (payload is Map && payload.isEmpty) return null;
      return RiderOrderDetails.fromJson(payload);
    } catch (e) {
      debugPrint('RiderOrderController.advanceStage: $e');
      return null;
    }
  }
}

final riderOrderControllerProvider =
    StateNotifierProvider<RiderOrderController, RiderOrdersState>(
        (ref) => RiderOrderController(ref));
