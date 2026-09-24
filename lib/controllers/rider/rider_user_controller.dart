import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ddx_rider/models/rider/rider_user.dart';
import 'package:ddx_rider/services/common/hive_service_provider.dart';
import 'package:ddx_rider/services/rider/rider_user_service.dart';
import 'package:ddx_rider/utils/global_function.dart';

@immutable
class RiderProfileState {
  final bool isLoading;
  final RiderUser? user;
  final int monthDelivered;
  final double monthCash;
  final String? error;

  const RiderProfileState({
    this.isLoading = false,
    this.user,
    this.monthDelivered = 0,
    this.monthCash = 0,
    this.error,
  });

  RiderProfileState copyWith({
    bool? isLoading,
    RiderUser? user,
    int? monthDelivered,
    double? monthCash,
    String? error,
  }) {
    return RiderProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      monthDelivered: monthDelivered ?? this.monthDelivered,
      monthCash: monthCash ?? this.monthCash,
      error: error,
    );
  }
}

class RiderUserController extends StateNotifier<RiderProfileState> {
  RiderUserController(this.ref) : super(const RiderProfileState());

  final Ref ref;

  RiderUserService get _service => ref.read(riderUserServiceProvider);

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
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

  static String _message(dynamic body, [String fallback = '']) {
    try {
      final map = body is Map
          ? body.map((k, e) => MapEntry(k.toString(), e))
          : <String, dynamic>{};
      return map['message']?.toString() ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  /// GET rider/details -> data:{user, curren_month_deliverd (typo kept),
  /// current_month_cash_collected}.
  Future<void> details() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final Response res = await _service.details();
      final data = _dataOf(res.data);
      final userMap = data['user'];
      final user = userMap == null ? null : RiderUser.fromJson(userMap);
      if (user != null) {
        final raw = user.raw.isNotEmpty ? user.raw : user.toJson();
        try {
          await ref.read(hiveServiceProvider).saveUserInfo(userInfo: raw);
        } catch (_) {}
      }
      state = state.copyWith(
        isLoading: false,
        user: user ?? state.user,
        monthDelivered: _asInt(
            data['curren_month_deliverd'] ?? data['current_month_delivered']),
        monthCash: _asDouble(data['current_month_cash_collected']),
      );
    } catch (e) {
      debugPrint('RiderUserController.details: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// POST rider/profile-update (nullable RiderRequest fields).
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final Response res = await _service.updateProfile(data);
      final ok = (res.statusCode ?? 500) < 400;
      GlobalFunction.showCustomSnackbar(
        message: _message(
            res.data, ok ? 'Profile updated' : 'Failed to update profile'),
        isSuccess: ok,
      );
      if (ok) await details();
      return ok;
    } catch (e) {
      debugPrint('RiderUserController.updateProfile: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    } finally {
      if (mounted) state = state.copyWith(isLoading: false);
    }
  }

  /// POST rider/location-update {latitude,longitude}.
  /// Silent on success (called on a 30s timer) unless [notify] is true.
  Future<bool> updateLocation(
    double latitude,
    double longitude, {
    bool notify = false,
  }) async {
    try {
      final Response res = await _service.updateLocation(
        latitude: latitude,
        longitude: longitude,
      );
      final ok = (res.statusCode ?? 500) < 400;
      if (notify) {
        GlobalFunction.showCustomSnackbar(
          message: _message(
              res.data,
              ok ? 'Location updated' : 'Failed to update location'),
          isSuccess: ok,
        );
      }
      return ok;
    } catch (e) {
      debugPrint('RiderUserController.updateLocation: $e');
      if (notify) {
        GlobalFunction.showCustomSnackbar(
          message: 'Failed to update location',
          isSuccess: false,
        );
      }
      return false;
    }
  }
}

final riderUserControllerProvider =
    StateNotifierProvider<RiderUserController, RiderProfileState>(
        (ref) => RiderUserController(ref));
