import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ddx_rider/firebase_options.dart';

// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await setupFlutterNotifications();
//   showFlutterNotification(message);
//   debugPrint('Handling a background message ${message.messageId}');
// }


Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await setupFlutterNotifications();
  showFlutterNotification(message);

  debugPrint('Background message: ${message.messageId}');
}

Future<void> firebaseMessagingForgroundHandler() async {
  FirebaseMessaging.onMessage.listen((message) {
    debugPrint(message.data.toString());
    debugPrint(message.data.toString());
    debugPrint(message.toString());
    debugPrint('Handling a ForeGround message ${message.messageId}');
    debugPrint('Handling a ForeGround message ${message.notification}');
    showFlutterNotification(message);
  });
}

/// Set to true only when Firebase initialized with valid keys.
/// The app ships with placeholder Firebase config until the real
/// google-services.json / firebase_options.dart are added — push stays
/// disabled but everything else must keep working.
bool firebaseMessagingReady = false;

/// Never-throwing FCM token lookup. Returns null when Firebase is disabled.
Future<String?> safeFcmToken() async {
  if (!firebaseMessagingReady) return null;
  try {
    return await FirebaseMessaging.instance.getToken();
  } catch (e) {
    debugPrint('FCM token unavailable: $e');
    return null;
  }
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true);

  const InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@drawable/notification_icon'),
    iOS: DarwinInitializationSettings(),
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveBackgroundNotificationResponse: onDidReceiveLocalNotification,
    onDidReceiveNotificationResponse: onSelectNotification,
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  final AppleNotification? iOS = message.notification?.apple;
  if (notification != null && (android != null || iOS != null) && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@drawable/notification_icon',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}

// handle notification navigation
void handleMessage(RemoteMessage? message) {
  if (message == null) return;
  if (message.data['type'] == 'Conversetion') {
    // call the context less route here
  }
}

// Background notification selection
Future<void> onDidReceiveLocalNotification(
  NotificationResponse notificationResponse,
) async {
  // ContextLess.navigatorkey.currentState!.pushNamedAndRemoveUntil(
  //   Routes.messageScreen,
  //   arguments: MessageScreenArgument(
  //     orderId: orderId,
  //     senderId: receiverId,
  //     receiverId: senderId,
  //   ),
  //   (route) => true,
  // );
}

// Foreground notification selection
Future<void> onSelectNotification(
  NotificationResponse notificationResponse,
) async {
  // ContextLess.navigatorkey.currentState!.pushNamedAndRemoveUntil(
  //   Routes.messageScreen,
  //   arguments: MessageScreenArgument(
  //     orderId: orderId,
  //     senderId: receiverId,
  //     receiverId: senderId,
  //   ),
  //   (route) => true,
  // );
}

// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
