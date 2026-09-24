import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:ddx_rider/config/app_constants.dart';
import 'package:ddx_rider/views/common/language/language_view.dart';
import 'package:ddx_rider/views/common/onboarding/onboarding_view.dart';
import 'package:ddx_rider/views/rider/auth/rider_login_view.dart';
import 'package:ddx_rider/views/rider/auth/rider_otp_view.dart';
import 'package:ddx_rider/views/rider/auth/rider_register_view.dart';
import 'package:ddx_rider/views/rider/home/rider_home_view.dart';
import 'package:ddx_rider/views/rider/notifications/rider_notifications_view.dart';
import 'package:ddx_rider/views/rider/orders/rider_order_details_view.dart';
import 'package:ddx_rider/views/rider/orders/rider_orders_view.dart';
import 'package:ddx_rider/views/rider/profile/rider_profile_view.dart';
import 'package:ddx_rider/views/rider/splash/rider_splash_view.dart';

class Routes {
  Routes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String riderHome = '/riderHome';
  static const String deliveries = '/deliveries';
  static const String deliveryDetails = '/deliveryDetails';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String languageView = '/languageView';

  static const Set<String> publicRoutes = {
    splash,
    onboarding,
    login,
    register,
    otp,
  };

  static bool _hasToken() {
    try {
      if (!Hive.isBoxOpen(AppConstants.authBox)) return false;
      final token =
          Hive.box(AppConstants.authBox).get(AppConstants.authToken);
      return token != null && token.toString().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Route<dynamic> _guarded(Widget view, RouteSettings settings) {
    if (!publicRoutes.contains(settings.name) && !_hasToken()) {
      log('Route guard: no token, redirect to login from ${settings.name}');
      return go(const RiderLoginView(), settings);
    }
    return go(view, settings);
  }
}

Route<dynamic> generatedRoutes(RouteSettings settings) {
  switch (settings.name) {
    case Routes.splash:
      return Routes._guarded(const RiderSplashView(), settings);
    case Routes.onboarding:
      return Routes._guarded(const OnboardingView(), settings);
    case Routes.login:
      return go(const RiderLoginView(), settings);
    case Routes.register:
      return go(const RiderRegisterView(), settings);
    case Routes.otp:
      final args =
          settings.arguments is Map ? settings.arguments as Map : const {};
      final contact = (args['contact'] ?? args['phone'] ?? args['email'])
              ?.toString() ??
          (settings.arguments is String ? settings.arguments as String : '');
      final isForgot = args['forgot_password'] == true ||
          args['forgotPassword'] == true ||
          args['isForgot'] == true;
      return go(
        RiderOtpView(contact: contact, isForgot: isForgot),
        settings,
      );
    case Routes.riderHome:
      return Routes._guarded(const RiderHomeView(), settings);
    case Routes.deliveries:
      return Routes._guarded(const RiderOrdersView(), settings);
    case Routes.deliveryDetails:
      final args =
          settings.arguments is Map ? settings.arguments as Map : const {};
      int orderId;
      final rawId = args['orderId'] ?? args['order_id'];
      if (rawId is int) {
        orderId = rawId;
      } else {
        orderId = int.tryParse(rawId?.toString() ?? '') ?? 0;
      }
      final orderCode =
          (args['orderCode'] ?? args['order_code'])?.toString() ?? '';
      return Routes._guarded(
        RiderOrderDetailsView(orderId: orderId, orderCode: orderCode),
        settings,
      );
    case Routes.notifications:
      return Routes._guarded(const RiderNotificationsView(), settings);
    case Routes.profile:
      return Routes._guarded(const RiderProfileView(), settings);
    case Routes.languageView:
      return Routes._guarded(const LanguageView(), settings);
    default:
      log('Unknown route: ${settings.name}');
      return Routes._guarded(const RiderHomeView(), settings);
  }
}

PageTransition<dynamic> go(Widget view, RouteSettings settings) {
  log('Route Name:  ${settings.name}');
  return PageTransition(
    child: view,
    type: PageTransitionType.theme,
    settings: settings,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 300),
  );
}
