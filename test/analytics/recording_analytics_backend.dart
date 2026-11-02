import 'package:clickbattle/analytics/analytics_backend.dart';

class RecordedEvent {
  RecordedEvent(this.name, this.params);

  final String name;
  final Map<String, Object>? params;
}

class RecordedScreenView {
  RecordedScreenView(this.screenName, this.screenClass);

  final String screenName;
  final String? screenClass;
}

class RecordedUserProperty {
  RecordedUserProperty(this.name, this.value);

  final String name;
  final String? value;
}

class RecordingAnalyticsBackend implements AnalyticsBackend {
  final List<RecordedEvent> events = [];
  final List<RecordedScreenView> screens = [];
  final List<RecordedUserProperty> userProperties = [];

  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    events.add(RecordedEvent(name, params));
  }

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    screens.add(RecordedScreenView(screenName, screenClass));
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    userProperties.add(RecordedUserProperty(name, value));
  }

  List<String> get eventNames => events.map((e) => e.name).toList();
}
