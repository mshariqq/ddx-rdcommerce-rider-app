import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ddx_rider/controllers/rider/rider_user_controller.dart';

/// Duty toggle: `true` = on duty (tracking), `false` = off duty.
///
/// While on duty a 30s [Timer] pings the current GPS position and posts it
/// to POST rider/location-update (best effort). Timer is cancelled on
/// [stop] and in [dispose].
class RiderTrackingController extends StateNotifier<bool> {
  RiderTrackingController(this.ref) : super(false);

  final Ref ref;

  Timer? _timer;
  double? lastLat;
  double? lastLng;
  DateTime? lastUpdate;

  bool get onDuty => state;

  Future<void> start() async {
    if (state) return;
    state = true;
    await _ping();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _ping());
  }

  Future<void> stop() async {
    state = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> toggle() async {
    if (state) {
      await stop();
    } else {
      await start();
    }
  }

  Future<void> _ping() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('RiderTracking: location permission denied');
        return;
      }
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      lastLat = position.latitude;
      lastLng = position.longitude;
      lastUpdate = DateTime.now();
      await ref
          .read(riderUserControllerProvider.notifier)
          .updateLocation(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('RiderTracking ping (ignored): $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}

final riderTrackingControllerProvider =
    StateNotifierProvider<RiderTrackingController, bool>(
        (ref) => RiderTrackingController(ref));
