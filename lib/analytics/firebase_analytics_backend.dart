import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:clickbattle/analytics/analytics_backend.dart';

/// Connects to Firebase Analytics using Android `google-services.json`.
///
/// `lib/firebase_options.dart` is intentionally not imported: it is produced
/// by `flutterfire configure` and must not be committed with placeholder keys.
class FirebaseAnalyticsConnector {
  FirebaseAnalyticsConnector._();

  static Future<AnalyticsBackend> connect() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    final analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(true);
    return FirebaseAnalyticsBackend(analytics);
  }
}

class FirebaseAnalyticsBackend implements AnalyticsBackend {
  FirebaseAnalyticsBackend(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    try {
      await _analytics.logEvent(name: name, parameters: params);
    } catch (e, st) {
      debugPrint('Analytics logEvent($name) failed: $e\n$st');
    }
  }

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e, st) {
      debugPrint('Analytics logScreenView($screenName) failed: $e\n$st');
    }
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e, st) {
      debugPrint('Analytics setUserProperty($name) failed: $e\n$st');
    }
  }
}
