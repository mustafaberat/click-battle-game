import 'package:clickbattle/analytics/analytics_events.dart';

/// Enforces GA4 naming and value limits before events leave the wrapper.
class AnalyticsSanitizer {
  AnalyticsSanitizer._();

  static const _reservedPrefixes = ['firebase_', 'google_', 'ga_'];

  static String eventName(String name) {
    return _sanitizeName(
      name,
      maxLength: AnalyticsLimits.maxEventName,
      protectReservedPrefix: true,
    );
  }

  static String paramName(String name) {
    return _sanitizeName(
      name,
      maxLength: AnalyticsLimits.maxParamName,
      protectReservedPrefix: true,
    );
  }

  static String userPropertyName(String name) {
    return _sanitizeName(
      name,
      maxLength: AnalyticsLimits.maxUserPropertyName,
      protectReservedPrefix: true,
    );
  }

  static String? userPropertyValue(String? value) {
    if (value == null) return null;
    return _truncate(value, AnalyticsLimits.maxUserPropertyValue);
  }

  static Object paramValue(Object value) {
    if (value is bool) return value ? 1 : 0;
    if (value is String) {
      return _truncate(value, AnalyticsLimits.maxParamValue);
    }
    if (value is num) return value;
    return _truncate(value.toString(), AnalyticsLimits.maxParamValue);
  }

  static Map<String, Object> params(Map<String, Object?> raw) {
    final out = <String, Object>{};
    for (final entry in raw.entries) {
      if (out.length >= AnalyticsLimits.maxParams) break;
      final value = entry.value;
      if (value == null) continue;
      final key = paramName(entry.key);
      if (key.isEmpty) continue;
      out[key] = paramValue(value);
    }
    return out;
  }

  static String _sanitizeName(
    String name, {
    required int maxLength,
    required bool protectReservedPrefix,
  }) {
    var n = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    n = n.replaceAll(RegExp(r'_+'), '_');
    n = n.replaceAll(RegExp(r'^_+|_+$'), '');
    if (n.isEmpty || !RegExp(r'^[a-z]').hasMatch(n)) {
      n = 'e_$n';
    }
    if (protectReservedPrefix) {
      for (final prefix in _reservedPrefixes) {
        if (n.startsWith(prefix)) {
          n = 'x_$n';
          break;
        }
      }
    }
    if (n.length > maxLength) {
      n = n.substring(0, maxLength);
    }
    return n;
  }

  static String _truncate(String value, int max) {
    if (value.length <= max) return value;
    return value.substring(0, max);
  }
}
