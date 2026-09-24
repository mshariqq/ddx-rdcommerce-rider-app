import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ddx_rider/config/app_constants.dart';
import 'package:ddx_rider/utils/api_client.dart';

class RiderAuthService {
  final Ref ref;

  RiderAuthService(this.ref);

  ApiClient get _api => ref.read(apiClientProvider);

  /// POST rider/login — body: phone, password, latitude, longitude,
  /// optional device_key, device_type.
  Future<Response> login({
    required String phone,
    required String password,
    required double latitude,
    required double longitude,
    String? deviceKey,
    String? deviceType,
  }) {
    return _api.post(
      AppConstants.riderLogin,
      data: {
        'phone': phone,
        'password': password,
        'latitude': latitude,
        'longitude': longitude,
        if (deviceKey != null) 'device_key': deviceKey,
        if (deviceType != null) 'device_type': deviceType,
      },
    );
  }

  /// POST rider/register — body (RiderRequest): first_name (required),
  /// last_name?, phone?, email?, password+password_confirmation (required),
  /// profile_photo? (file), gender?, date_of_birth?, driving_lience?,
  /// vehicle_type (required), country?, phone_code?.
  /// Pass a [File] as `profile_photo` value for multipart upload.
  Future<Response> register(Map<String, dynamic> data) {
    final hasFile = data.values.any((e) => e is File);
    return _api.post(
      AppConstants.riderRegister,
      data: hasFile ? FormData.fromMap(data) : data,
    );
  }

  /// POST rider/create-password — body: password, password_confirmation,
  /// token (from verify-otp).
  Future<Response> createPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) {
    return _api.post(
      AppConstants.riderCreatePassword,
      data: {
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  /// POST rider/send-otp — body: phone (phone or email), optional email,
  /// phone_code, forgot_password (bool/int).
  Future<Response> sendOtp({
    String? phone,
    String? email,
    String? phoneCode,
    dynamic forgotPassword,
  }) {
    return _api.post(
      AppConstants.riderSendOtp,
      data: {
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (phoneCode != null) 'phone_code': phoneCode,
        if (forgotPassword != null) 'forgot_password': forgotPassword,
      },
    );
  }

  /// POST rider/verify-otp — body: phone, otp.
  Future<Response> verifyOtp({
    required String phone,
    required String otp,
  }) {
    return _api.post(
      AppConstants.riderVerifyOtp,
      data: {'phone': phone, 'otp': otp},
    );
  }

  /// GET rider/check-user-status — query: phone (phone or email string).
  Future<Response> checkUserStatus({String? phone}) {
    return _api.get(
      AppConstants.riderCheckUserStatus,
      query: {if (phone != null) 'phone': phone},
    );
  }

  /// POST rider/change-password (auth) — body: current_password, password,
  /// password_confirmation.
  Future<Response> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) {
    return _api.post(
      AppConstants.riderChangePassword,
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  /// GET rider/logout — query: device_key?.
  Future<Response> logout({String? deviceKey}) {
    return _api.get(
      AppConstants.riderLogout,
      query: {if (deviceKey != null) 'device_key': deviceKey},
    );
  }

  /// DELETE rider/delete-account (auth).
  Future<Response> deleteAccount() {
    return _api.delete(AppConstants.riderDeleteAccount);
  }
}

final riderAuthServiceProvider =
    Provider((ref) => RiderAuthService(ref));
