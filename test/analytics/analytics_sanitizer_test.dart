import 'package:clickbattle/analytics/analytics_sanitizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsSanitizer', () {
    test('keeps valid snake_case event names', () {
      expect(AnalyticsSanitizer.eventName('game_start'), 'game_start');
    });

    test('rewrites reserved prefixes', () {
      expect(AnalyticsSanitizer.eventName('firebase_foo'), 'x_firebase_foo');
      expect(AnalyticsSanitizer.eventName('google_bar'), 'x_google_bar');
      expect(AnalyticsSanitizer.eventName('ga_baz'), 'x_ga_baz');
    });

    test('truncates names to 40 characters', () {
      final name = AnalyticsSanitizer.eventName('a' * 50);
      expect(name.length, 40);
    });

    test('prefixes names that do not start with a letter', () {
      expect(AnalyticsSanitizer.eventName('1start'), 'e_1start');
    });

    test('converts bool params to 0/1 and drops nulls', () {
      final params = AnalyticsSanitizer.params({
        'enabled': true,
        'missing': null,
        'label': 'ok',
      });
      expect(params['enabled'], 1);
      expect(params.containsKey('missing'), isFalse);
      expect(params['label'], 'ok');
    });

    test('truncates param string values to 100 characters', () {
      final params = AnalyticsSanitizer.params({
        'error_message': 'x' * 150,
      });
      expect((params['error_message'] as String).length, 100);
    });

    test('caps params at 25 entries', () {
      final raw = <String, Object?>{
        for (var i = 0; i < 30; i++) 'p_$i': i,
      };
      expect(AnalyticsSanitizer.params(raw).length, 25);
    });

    test('truncates user property names and values', () {
      expect(
        AnalyticsSanitizer.userPropertyName('preferred_mode_name_too_long'),
        hasLength(lessThanOrEqualTo(24)),
      );
      expect(
        AnalyticsSanitizer.userPropertyValue('v' * 40)!.length,
        36,
      );
    });
  });
}
