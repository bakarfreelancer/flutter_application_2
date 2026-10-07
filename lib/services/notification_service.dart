import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  NotificationService — Lecture 20
//
//  A singleton that wraps flutter_local_notifications.
//  Responsibilities:
//    1. Initialize the plugin once on app start (init)
//    2. Request Android 13+ notification permission (init)
//    3. Show an immediate notification when an order is placed (showOrderPlaced)
//
//  Singleton pattern: same as CartDatabase (Lecture 19).
//  Only one instance ever exists, shared across the whole app.
// ─────────────────────────────────────────────────────────────────────────────
class NotificationService {
  // ── Singleton setup ──────────────────────────────────────────────────────
  NotificationService._internal(); // private constructor
  static final NotificationService instance = NotificationService._internal();

  // The plugin object that talks to the OS notification system
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ── Notification channel constants ───────────────────────────────────────
  // Android 8+ requires a "channel" for every notification.
  // The channel id must match exactly between plugin setup and show().
  static const String _channelId = 'orders_channel';
  static const String _channelName = 'Order Updates';
  static const String _channelDesc = 'Notifications for order confirmations';

  // ── init() — call ONCE in main() before runApp() ─────────────────────────
  Future<void> init() async {
    // Android: uses the app launcher icon as the notification icon
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS: ask the user for permission on first launch
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(settings);

    // Android 13+ (API 33+) requires explicit runtime permission for notifications.
    // On older Android versions this call is a no-op (safely ignored).
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ── showOrderPlaced() — fires an immediate notification ──────────────────
  Future<void> showOrderPlaced(int itemCount, double total) async {
    // AndroidNotificationDetails describes how the notification looks on Android.
    const androidDetails = AndroidNotificationDetails(
      _channelId,   // must match the channel we registered in init()
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high, // shows as a heads-up banner
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    // NotificationDetails bundles platform-specific settings together.
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(), // uses iOS defaults
    );

    // show() fires the notification immediately.
    // id: 1 — every call with the same id replaces the previous notification.
    await _plugin.show(
      1, // notification id
      'Order Placed! 🛍️',
      '$itemCount item(s) ordered · \$${total.toStringAsFixed(2)} total',
      details,
    );
  }
}
