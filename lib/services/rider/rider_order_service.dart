import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ddx_rider/config/app_constants.dart';
import 'package:ddx_rider/utils/api_client.dart';

class RiderOrderService {
  final Ref ref;

  RiderOrderService(this.ref);

  ApiClient get _api => ref.read(apiClientProvider);

  /// GET rider/orders — query: page?, per_page?.
  /// Response data: {to_do_order, completed_order, total, orders[]}.
  Future<Response> orders([Map<String, dynamic>? params]) {
    return _api.get(AppConstants.riderOrders, query: params);
  }

  /// GET rider/orders/details — query (BOTH required, validated):
  /// order_id (int), order_code (string, leading '#' stripped server-side).
  Future<Response> details({
    required int orderId,
    required String orderCode,
  }) {
    return _api.get(
      AppConstants.riderOrderDetails,
      query: {'order_id': orderId, 'order_code': orderCode},
    );
  }

  /// POST rider/orders/status-update — body: order_id (int, required),
  /// order_code (string, required), order_status (nullable string — accepted
  /// by validation but IGNORED server-side: the next status is derived from
  /// the current status via getNextStatus()).
  ///
  /// Normal-order chain: Confirm -> Processing -> Pickup -> On The Way ->
  /// Delivered -> deliveredAndPaid. Pre-order chain (PreOrder module):
  /// In Shipping -> Pickup -> On The Way -> Delivered.
  Future<Response> statusUpdate({
    required int orderId,
    required String orderCode,
    String? status,
  }) {
    return _api.post(
      AppConstants.riderOrderStatusUpdate,
      data: {
        'order_id': orderId,
        'order_code': orderCode,
        if (status != null) 'order_status': status,
      },
    );
  }

  /// GET rider/my-orders — query: page?, per_page?, search?, start_date?,
  /// end_date?, filter_type?, order_status? ('to_deliver' | 'delivered').
  /// Response data: {total, all_orders, to_deliver, delivered, orders[]}.
  Future<Response> myOrders({
    String? status,
    Map<String, dynamic>? params,
  }) {
    return _api.get(
      AppConstants.riderMyOrders,
      query: {
        if (status != null) 'order_status': status,
        ...?params,
      },
    );
  }
}

final riderOrderServiceProvider =
    Provider((ref) => RiderOrderService(ref));
