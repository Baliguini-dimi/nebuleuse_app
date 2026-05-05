import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:workmanager/workmanager.dart';
import '../data/local_quotes.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await NotificationService.showBackgroundNotification();
    } catch (e) {
      return Future.value(false);
    }
    return Future.value(true);
  });
}

class NotificationService {

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const String _notifHourKey = 'notif_hour';
  static const String _notifMinuteKey = 'notif_minute';
  static const String _notifModeKey = 'notif_mode';
  static const String _notifIntervalKey = 'notif_interval';
  static const String _dailyTaskName = 'nebuleuse_daily';
  static const String _intervalTaskName = 'nebuleuse_interval';

  // ════════════════════════════════════
  // 🚀 INITIALISATION
  // ════════════════════════════════════

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Abidjan'));

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      const channel = AndroidNotificationChannel(
        'nebuleuse_channel',
        'Nébuleuse',
        description: 'Citations africaines inspirantes',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      await androidImpl.createNotificationChannel(channel);
      await androidImpl.requestNotificationsPermission();
      await androidImpl.requestExactAlarmsPermission();
    }

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  // ════════════════════════════════════
  // 🔔 MODE 1 : HEURE FIXE QUOTIDIENNE
  // ════════════════════════════════════

  static Future<void> scheduleDailyAtTime({
    required int hour,
    required int minute,
  }) async {
    await cancelAllNotifications();

    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }
    final delay = target.difference(now);

    await Workmanager().registerPeriodicTask(
      _dailyTaskName,
      _dailyTaskName,
      frequency: const Duration(hours: 24),
      initialDelay: delay,
      constraints: Constraints(
        networkType: NetworkType.notRequired,           // ✅ corrigé
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace, // ✅ corrigé
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 10),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notifHourKey, hour);
    await prefs.setInt(_notifMinuteKey, minute);
    await prefs.setString(_notifModeKey, 'daily');
  }

  // ════════════════════════════════════
  // ⏱️ MODE 2 : INTERVALLE RÉPÉTÉ
  // ════════════════════════════════════

  static Future<void> scheduleInterval({required int hours}) async {
    await cancelAllNotifications();

    await Workmanager().registerPeriodicTask(
      _intervalTaskName,
      _intervalTaskName,
      frequency: Duration(hours: hours),
      initialDelay: Duration(hours: hours),
      constraints: Constraints(
        networkType: NetworkType.notRequired,           // ✅ corrigé
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace, // ✅ corrigé
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 5),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notifIntervalKey, hours);
    await prefs.setString(_notifModeKey, 'interval');
  }

  // ════════════════════════════════════
  // 📢 NOTIFICATION BACKGROUND
  // ════════════════════════════════════

  static Future<void> showBackgroundNotification() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(initSettings);

    final quote = _randomQuote();

    const androidDetails = AndroidNotificationDetails(
      'nebuleuse_channel',
      'Nébuleuse',
      channelDescription: 'Citations africaines inspirantes',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFD4A843),
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
    );

    await _plugin.show(
      Random().nextInt(1000),
      '✨ Nébuleuse — Sagesse du jour',
      '"${quote["text"]}"\n\n— ${quote["author"]}',
      const NotificationDetails(android: androidDetails),
    );
  }

  // ════════════════════════════════════
  // 🧪 TEST IMMÉDIAT
  // ════════════════════════════════════

  static Future<void> showTestNotification() async {
    final quote = _randomQuote();

    const androidDetails = AndroidNotificationDetails(
      'nebuleuse_channel',
      'Nébuleuse',
      channelDescription: 'Citations africaines inspirantes',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFD4A843),
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
    );

    await _plugin.show(
      99,
      '✨ Nébuleuse — Test',
      '"${quote["text"]}"\n\n— ${quote["author"]}',
      const NotificationDetails(android: androidDetails),
    );
  }

  // ════════════════════════════════════
  // 🛑 ANNULER TOUT
  // ════════════════════════════════════

  static Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    await Workmanager().cancelAll();
  }

  // ════════════════════════════════════
  // 📖 LIRE LES PRÉFÉRENCES
  // ════════════════════════════════════

  static Future<Map<String, dynamic>> getSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt(_notifHourKey) ?? 8,
      'minute': prefs.getInt(_notifMinuteKey) ?? 0,
      'mode': prefs.getString(_notifModeKey) ?? 'daily',
      'interval': prefs.getInt(_notifIntervalKey) ?? 1,
    };
  }

  // ════════════════════════════════════
  // 🎲 CITATION ALÉATOIRE
  // ════════════════════════════════════

  static Map<String, String> _randomQuote() {
    return localQuotes[Random().nextInt(localQuotes.length)];
  }
}