import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../screens/home_page.dart';
import 'device_service.dart';

class FcmService {
  FcmService._internal();
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;

  Future<void> initFCM() async {
    if (_initialized) {
      debugPrint('FCM already initialized — skip');
      return;
    }
    _initialized = true;

    debugPrint('Initializing FCM');

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('Notification permission NOT granted');
        return;
      }

      await _registerTokenSafe();

      _messaging.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM token refreshed');
        await DeviceService().registerOrUpdate(newToken);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground message received');
        debugPrint('title: ${message.notification?.title}');
        debugPrint('body : ${message.notification?.body}');
      });

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App opened from terminated via notification');
        _handleMessage(initialMessage);
      }

      debugPrint('FCM initialized successfully');
    } catch (e, s) {
      debugPrint('FCM init error: $e');
      debugPrint('$s');
    }
  }

  /// Ambil token dengan retry ringan
  Future<void> _registerTokenSafe() async {
    debugPrint('Retrieving FCM token...');

    String? token;

    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        token = await _messaging.getToken();
        debugPrint('Attempt $attempt → token ${token != null ? "OK" : "NULL"}');

        if (token != null) break;
      } catch (e) {
        debugPrint('⚠️ getToken failed (attempt $attempt): $e');
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (token == null) {
      debugPrint('FCM token unavailable after retry');
      return;
    }

    debugPrint('FCM token acquired (length=${token.length})');
    await DeviceService().registerOrUpdate(token);
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint('Notification tapped');

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (_) => false,
    );
  }
}
