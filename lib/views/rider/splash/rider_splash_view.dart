import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ddx_rider/config/app_constants.dart';
import 'package:ddx_rider/config/app_text_style.dart';
import 'package:ddx_rider/routes.dart';
import 'package:ddx_rider/services/common/hive_service_provider.dart';
import 'package:ddx_rider/utils/api_client.dart';
import 'package:ddx_rider/utils/context_less_navigation.dart';

class RiderSplashView extends ConsumerStatefulWidget {
  const RiderSplashView({super.key});

  @override
  ConsumerState<RiderSplashView> createState() => _RiderSplashViewState();
}

class _RiderSplashViewState extends ConsumerState<RiderSplashView> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Restore the saved token into the API client (cold start).
    try {
      final token = await ref.read(hiveServiceProvider).getAuthToken();
      if (token != null && token.isNotEmpty) {
        ref.read(apiClientProvider).updateToken(token: token);
      }
    } catch (_) {}

    bool hasToken = false;
    try {
      if (Hive.isBoxOpen(AppConstants.authBox)) {
        final token =
            Hive.box(AppConstants.authBox).get(AppConstants.authToken);
        hasToken = token != null && token.toString().isNotEmpty;
      }
    } catch (_) {}

    if (!mounted) return;
    context.nav.pushNamedAndRemoveUntil(
      hasToken ? Routes.riderHome : Routes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/ddx-icon.png',
              width: 180.w,
              height: 70.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.delivery_dining,
                size: 72.sp,
              ),
            ),
            Gap(16.h),
            Text(
              'DDX Rider',
              style: AppTextStyle(context)
                  .title
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            Gap(24.h),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
