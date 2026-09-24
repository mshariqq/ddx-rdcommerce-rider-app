import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ddx_rider/config/app_constants.dart';
import 'package:ddx_rider/utils/api_client.dart';

class RiderUserService {
  final Ref ref;

  RiderUserService(this.ref);

  ApiClient get _api => ref.read(apiClientProvider);

  /// GET rider/details (auth) — data: {user, curren_month_deliverd,
  /// current_month_cash_collected} (backend key typo preserved).
  Future<Response> details() {
    return _api.get(AppConstants.riderDetails);
  }

  /// POST rider/profile-update (auth) — RiderRequest fields, all nullable on
  /// update: first_name?, last_name?, phone?, email?, password?+confirmed,
  /// profile_photo? (file), gender?, date_of_birth?, driving_lience?,
  /// vehicle_type?, country?, phone_code?. Pass a [File] for multipart.
  Future<Response> updateProfile(Map<String, dynamic> data) {
    final hasFile = data.values.any((e) => e is File);
    return _api.post(
      AppConstants.riderProfileUpdate,
      data: hasFile ? FormData.fromMap(data) : data,
    );
  }

  /// POST rider/location-update (auth) — body: latitude (numeric, required),
  /// longitude (numeric, required).
  Future<Response> updateLocation({
    required double latitude,
    required double longitude,
  }) {
    return _api.post(
      AppConstants.riderLocationUpdate,
      data: {'latitude': latitude, 'longitude': longitude},
    );
  }
}

final riderUserServiceProvider =
    Provider((ref) => RiderUserService(ref));
