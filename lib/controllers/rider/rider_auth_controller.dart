import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ddx_rider/config/app_constants.dart';
import 'package:ddx_rider/models/rider/rider_user.dart';
import 'package:ddx_rider/services/common/hive_service_provider.dart';
import 'package:ddx_rider/services/rider/rider_auth_service.dart';
import 'package:ddx_rider/utils/api_client.dart';
import 'package:ddx_rider/utils/global_function.dart';
import 'package:ddx_rider/utils/notification_handler.dart';

/// Loading flag for all rider auth operations.
///
/// Token persistence: Hive [HiveService.saveUserAuthToken] +
/// [ApiClient.updateToken]. Cached user: Hive Map via
/// [HiveService.saveUserInfo]/[getUserInfo] -> [RiderUser].
class RiderAuthController extends StateNotifier<bool> {
  RiderAuthController(this.ref) : super(false);

  final Ref ref;

  RiderAuthService get _service => ref.read(riderAuthServiceProvider);
  HiveService get _hive => ref.read(hiveServiceProvider);
  ApiClient get _api => ref.read(apiClientProvider);

  /// Cached user from Hive (null when logged out / never cached).
  Future<RiderUser?> getCachedUser() async {
    try {
      final map = await _hive.getUserInfo();
      if (map == null) return null;
      return RiderUser.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  bool get isLoggedIn {
    try {
      if (!Hive.isBoxOpen(AppConstants.authBox)) return false;
      final token =
          Hive.box(AppConstants.authBox).get(AppConstants.authToken);
      return token != null && token.toString().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _persistSession(RiderAuthResponse auth) async {
    if (auth.accessToken.isNotEmpty) {
      await _hive.saveUserAuthToken(authToken: auth.accessToken);
      _api.updateToken(token: auth.accessToken);
    }
    final user = auth.user;
    if (user != null) {
      final raw = user.raw.isNotEmpty ? user.raw : user.toJson();
      await _hive.saveUserInfo(userInfo: raw);
    }
    ref.invalidate(riderCurrentUserProvider);
  }

  Future<void> _clearSession() async {
    try {
      await _hive.removeUserAuthToken();
    } catch (_) {}
    try {
      await _hive.removeUserData();
    } catch (_) {}
    ref.invalidate(riderCurrentUserProvider);
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

  /// POST rider/login {phone,password,latitude,longitude,device_key}.
  /// Returns true on success (token persisted).
  Future<bool> login({
    required String phone,
    required String password,
    double latitude = 0,
    double longitude = 0,
  }) async {
    state = true;
    try {
      final deviceKey = await safeFcmToken();
      final Response res = await _service.login(
        phone: phone.trim(),
        password: password,
        latitude: latitude,
        longitude: longitude,
        deviceKey: deviceKey,
      );
      final auth = RiderAuthResponse.fromResponse(res.data);
      if (auth.accessToken.isEmpty) {
        GlobalFunction.showCustomSnackbar(
          message: _message(res.data, 'Login failed'),
          isSuccess: false,
        );
        return false;
      }
      await _persistSession(auth);
      GlobalFunction.showCustomSnackbar(
        message: auth.message.isEmpty ? 'Login successful' : auth.message,
        isSuccess: true,
      );
      return true;
    } catch (e) {
      debugPrint('RiderAuthController.login: $e');
      return false;
    } finally {
      state = false;
    }
  }

  /// POST rider/register (RiderRequest fields). Returns true on success.
  Future<bool> register(Map<String, dynamic> data) async {
    state = true;
    try {
      final Response res = await _service.register(data);
      final ok = (res.statusCode ?? 500) < 400;
      GlobalFunction.showCustomSnackbar(
        message: _message(
            res.data, ok ? 'Registration successful' : 'Registration failed'),
        isSuccess: ok,
      );
      return ok;
    } catch (e) {
      debugPrint('RiderAuthController.register: $e');
      return false;
    } finally {
      state = false;
    }
  }

  /// POST rider/send-otp {phone,email?,forgot_password?}.
  Future<bool> sendOtp({
    String? phone,
    String? email,
    dynamic forgotPassword,
  }) async {
    state = true;
    try {
      final Response res = await _service.sendOtp(
        phone: phone,
        email: email,
        forgotPassword: forgotPassword,
      );
      final ok = (res.statusCode ?? 500) < 400;
      GlobalFunction.showCustomSnackbar(
        message: _message(res.data, ok ? 'OTP sent' : 'Failed to send OTP'),
        isSuccess: ok,
      );
      return ok;
    } catch (e) {
      debugPrint('RiderAuthController.sendOtp: $e');
      return false;
    } finally {
      state = false;
    }
  }

  /// POST rider/verify-otp {phone,otp} -> data:{token}.
  /// Returns the reset token on success, null otherwise.
  Future<String?> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    state = true;
    try {
      final Response res =
          await _service.verifyOtp(phone: phone.trim(), otp: otp.trim());
      Map<String, dynamic> data = {};
      try {
        final map = res.data is Map
            ? (res.data as Map).map((k, e) => MapEntry(k.toString(), e))
            : <String, dynamic>{};
        final inner = map['data'];
        data = inner is Map
            ? inner.map((k, e) => MapEntry(k.toString(), e))
            : <String, dynamic>{};
      } catch (_) {}
      final token = data['token']?.toString() ?? '';
      if (token.isEmpty) {
        GlobalFunction.showCustomSnackbar(
          message: _message(res.data, 'OTP verification failed'),
          isSuccess: false,
        );
        return null;
      }
      GlobalFunction.showCustomSnackbar(
        message: _message(res.data, 'OTP verified'),
        isSuccess: true,
      );
      return token;
    } catch (e) {
      debugPrint('RiderAuthController.verifyOtp: $e');
      return null;
    } finally {
      state = false;
    }
  }

  /// GET rider/check-user-status?phone= -> data:{user_status}.
  Future<String?> checkUserStatus({String? phone}) async {
    try {
      final Response res = await _service.checkUserStatus(phone: phone);
      try {
        final map = res.data is Map
            ? (res.data as Map).map((k, e) => MapEntry(k.toString(), e))
            : <String, dynamic>{};
        final data = map['data'];
        if (data is Map) {
          final status = data['user_status'] ?? data['status'];
          return status?.toString();
        }
        if (data != null) return data.toString();
      } catch (_) {}
      return null;
    } catch (e) {
      debugPrint('RiderAuthController.checkUserStatus: $e');
      return null;
    }
  }

  /// POST rider/create-password {password,password_confirmation,token}.
  Future<bool> createPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = true;
    try {
      final Response res = await _service.createPassword(
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      final ok = (res.statusCode ?? 500) < 400;
      GlobalFunction.showCustomSnackbar(
        message: _message(
            res.data, ok ? 'Password created' : 'Failed to create password'),
        isSuccess: ok,
      );
      return ok;
    } catch (e) {
      debugPrint('RiderAuthController.createPassword: $e');
      return false;
    } finally {
      state = false;
    }
  }

  /// POST rider/change-password (auth).
  Future<bool> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = true;
    try {
      final Response res = await _service.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      final ok = (res.statusCode ?? 500) < 400;
      GlobalFunction.showCustomSnackbar(
        message: _message(
            res.data, ok ? 'Password changed' : 'Failed to change password'),
        isSuccess: ok,
      );
      return ok;
    } catch (e) {
      debugPrint('RiderAuthController.changePassword: $e');
      return false;
    } finally {
      state = false;
    }
  }

  /// GET rider/logout — always clears the local session (best effort).
  Future<void> logout() async {
    state = true;
    try {
      try {
        final deviceKey = await safeFcmToken();
        await _service.logout(deviceKey: deviceKey);
      } catch (e) {
        debugPrint('RiderAuthController.logout api (ignored): $e');
      }
      await _clearSession();
    } finally {
      state = false;
    }
  }

  /// DELETE rider/delete-account — clears the local session (best effort).
  Future<bool> deleteAccount() async {
    state = true;
    try {
      try {
        await _service.deleteAccount();
      } catch (e) {
        debugPrint('RiderAuthController.deleteAccount api (ignored): $e');
      }
      await _clearSession();
      return true;
    } finally {
      state = false;
    }
  }
}

final riderAuthControllerProvider =
    StateNotifierProvider<RiderAuthController, bool>(
        (ref) => RiderAuthController(ref));

/// Reactive cached rider user (refreshes after login/logout via invalidate).
final riderCurrentUserProvider = FutureProvider<RiderUser?>((ref) async {
  try {
    final map = await ref.watch(hiveServiceProvider).getUserInfo();
    if (map == null) return null;
    return RiderUser.fromJson(map);
  } catch (_) {
    return null;
  }
});
