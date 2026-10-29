import 'package:flutter/material.dart';

import 'package:clickbattle/analytics/analytics_events.dart';
import 'package:clickbattle/analytics/analytics_service.dart';

/// Logs a `screen_view` for every named route push / replace / pop-to.
class AnalyticsNavigatorObserver extends NavigatorObserver {
  AnalyticsNavigatorObserver({AnalyticsService? analytics})
      : _analytics = analytics ?? AnalyticsService.instance;

  final AnalyticsService _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _log(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _log(previousRoute);
  }

  void _log(Route<dynamic> route) {
    final screen = AnalyticsScreens.fromRoute(route.settings.name);
    if (screen == null) return;
    _analytics.logScreenView(screen);
  }
}
