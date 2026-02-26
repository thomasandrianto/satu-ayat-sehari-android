import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  static const _deviceIdKey = 'device_id';
  final _supabase = Supabase.instance.client;

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, deviceId);
      debugPrint('New device_id: $deviceId');
    } else {
      debugPrint('Existing device_id: $deviceId');
    }

    return deviceId;
  }

  Future<void> registerOrUpdate(String pushToken) async {
    try {
      final deviceId = await _getOrCreateDeviceId();

      debugPrint('Register device');
      debugPrint('device_id: $deviceId');
      debugPrint('push_token: ${pushToken.substring(0, 10)}...');

      final res = await _supabase.from('devices').upsert({
        'device_id': deviceId,
        'push_token': pushToken,
        'platform': Platform.isAndroid ? 'android' : 'unknown',
      }, onConflict: 'device_id');

      debugPrint('Supabase upsert OK: $res');
    } catch (e, s) {
      debugPrint('Device register failed: $e');
      debugPrint('$s');
    }
  }
}
