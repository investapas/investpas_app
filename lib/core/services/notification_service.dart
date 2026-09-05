import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../network/api_endpoints.dart';
import '../network/api_service.dart';

/// Android notification channel used for all push notifications.
const _androidChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'Important Notifications',
  description: 'Used for trading alerts and account updates.',
  importance: Importance.high,
);

/// Called by the OS when a notification arrives while the app is terminated
/// or in the background. Must be a top-level function.
/// FCM natively shows the notification (with image via HTTPS imageUrl).
/// We do NOT show our own here — that would cause duplicates.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background: ${message.notification?.title ?? message.data['title'] ?? 'no-title'}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  /// Call once from main() after Firebase.initializeApp().
  Future<void> init({
    /// Called when user taps a notification (foreground or from tray).
    void Function(RemoteMessage message)? onNotificationTap,
  }) async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    await _initLocalNotifications();

    // Request permission (Android 13+, iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // Get & upload initial token
    final token = await _messaging.getToken();
    if (token != null) {
      debugPrint('[FCM] Token: ${token.substring(0, 20)}...');
      await _uploadToken(token);
    }

    // Re-upload whenever token rotates
    _messaging.onTokenRefresh.listen(_uploadToken);

    // ── Foreground notification handler ──────────────────────────────────
    // Android does NOT auto-display FCM notifications when the app is open,
    // so we post a real system notification (instead of an in-app popup) —
    // each one gets its own ID so repeated alerts (e.g. trading paused
    // reminders) stack in the tray rather than replacing each other.
    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? message.data['title'] ?? '';
      final body  = message.notification?.body  ?? message.data['body']  ?? '';
      final image = message.data['image']?.toString() ?? '';
      debugPrint('[FCM] Foreground: $title image: ${image.isNotEmpty ? "yes" : "no"}');
      if (title.isEmpty && body.isEmpty) return;
      _showLocalNotification(title: title, body: body, imageUrl: image);
    });

    // ── Notification tap (app in background/foreground) ──────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] Notification tapped (background): ${message.data}');
      onNotificationTap?.call(message);
    });

    // ── App opened from terminated state via notification ─────────────────
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('[FCM] App launched from notification: ${initial.data}');
      onNotificationTap?.call(initial);
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    // If a previous app version (or FCM itself, before this channel existed)
    // already created a channel with this ID at a lower importance, Android
    // locks that importance forever — createNotificationChannel() below would
    // silently no-op. Delete it first so it's recreated at Importance.high,
    // which is what makes foreground notifications appear as a heads-up banner.
    await androidPlugin?.deleteNotificationChannel(channelId: _androidChannel.id);
    await androidPlugin?.createNotificationChannel(_androidChannel);

    // Explicitly request the local-notifications permission too (separate
    // from FirebaseMessaging.requestPermission below) — required on some
    // OEM/Android versions before show() will actually display anything.
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<Uint8List?> _downloadImage(String url) async {
    try {
      if (url.isEmpty) return null;
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
    } catch (e) {
      debugPrint('[FCM] Image download failed: $e');
    }
    return null;
  }

  Future<void> _showLocalNotification({required String title, required String body, String imageUrl = ''}) async {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    StyleInformation styleInfo = const DefaultStyleInformation(false, false);

    // App icon as largeIcon (small circular icon on right side of collapsed notification)
    const appIcon = DrawableResourceAndroidBitmap('@mipmap/launcher_icon');

    if (imageUrl.isNotEmpty) {
      final bytes = await _downloadImage(imageUrl);
      if (bytes != null) {
        final bannerBitmap = ByteArrayAndroidBitmap(bytes);
        styleInfo = BigPictureStyleInformation(
          bannerBitmap,
          largeIcon: appIcon,
          contentTitle: '<b>$title</b>',
          htmlFormatContentTitle: true,
          summaryText: body,
          htmlFormatSummaryText: false,
          hideExpandedLargeIcon: false,
        );
      }
    }

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          largeIcon: appIcon,
          styleInformation: styleInfo,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> _uploadToken(String token) async {
    try {
      await ApiHelper.put(ApiEndpoints.profileUpdateFcmTokenApi, {
        'fcmToken': token,
      });
      debugPrint('[FCM] Token uploaded to backend');
    } catch (e) {
      debugPrint('[FCM] Token upload failed: $e');
    }
  }

  /// Send a test notification to a specific FCM token from the backend.
  /// Only for debug builds — production uses the backend directly.
  Future<String?> getToken() => _messaging.getToken();
}
