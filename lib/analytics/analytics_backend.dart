/// Destination for sanitized analytics calls. Screens never talk to Firebase.
abstract class AnalyticsBackend {
  Future<void> logEvent(String name, [Map<String, Object>? params]);

  Future<void> logScreenView(String screenName, {String? screenClass});

  Future<void> setUserProperty(String name, String? value);
}

/// Used when Firebase is missing or init fails so the app still runs.
class NoopAnalyticsBackend implements AnalyticsBackend {
  const NoopAnalyticsBackend();

  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {}

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async {}
}
