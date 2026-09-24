import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ddx_rider/config/app_color.dart';
import 'package:ddx_rider/config/app_constants.dart';
import 'package:ddx_rider/config/theme.dart';
import 'package:ddx_rider/firebase_options.dart';
import 'package:ddx_rider/generated/l10n.dart';
import 'package:ddx_rider/routes.dart';
import 'package:ddx_rider/utils/global_function.dart';
import 'package:ddx_rider/utils/notification_handler.dart';
import 'package:ddx_rider/views/rider/splash/rider_splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase ships with placeholder keys until the real project config is
  // added — push stays disabled but the app must still launch.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await setupFlutterNotifications();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    firebaseMessagingForgroundHandler();
    firebaseMessagingReady = true;
  } catch (e) {
    debugPrint('Firebase disabled (add real google-services.json): $e');
  }

  final String? fcmToken = await safeFcmToken();
  debugPrint("FCM Token: $fcmToken");

  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: false,
  );

  await Hive.initFlutter();
  await Hive.openBox(AppConstants.appSettingsBox);
  await Hive.openBox(AppConstants.authBox);
  await Hive.openBox(AppConstants.userBox);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Locale resolveLocal({required String langCode}) {
    return Locale(langCode);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // XD Design Sizes
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: false,
      builder: (context, child) {
        return ValueListenableBuilder(
            valueListenable: Hive.box(AppConstants.appSettingsBox).listenable(),
            builder: (context, box, _) {
              final isDark = box.get(AppConstants.isDarkTheme,
                  defaultValue: false) as bool;
              GlobalFunction.changeStatusBarTheme(isDark: isDark);
              final appLocal = box.get(AppConstants.appLocal);
              return ConnectivityAppWrapper(
                app: MaterialApp(
                  showPerformanceOverlay: false,
                  debugShowCheckedModeBanner: false,
                  title: 'DDX Rider',
                  navigatorKey: GlobalFunction.navigatorKey,
                  locale: resolveLocal(langCode: appLocal ?? 'en'),
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  theme: getAppTheme(context: context, isDarkTheme: isDark),
                  onGenerateRoute: generatedRoutes,
                  initialRoute: Routes.splash,
                  builder: (context, child) {
                    // add safety wrapper
                    return Column(
                      children: [
                        Expanded(
                          child: child ?? const RiderSplashView(),
                        ),
                        Container(
                          color: isDark
                              ? EcommerceAppColor.black
                              : EcommerceAppColor.white,
                          height: MediaQuery.of(context).padding.bottom,
                        )
                      ],
                    );
                  },
                ),
              );
            });
      },
    );
  }
}
