import 'package:clickbattle/analytics/analytics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'recording_analytics_backend.dart';

class _ThrowingBackend implements AnalyticsBackend {
  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) =>
      throw StateError('sync boom');
  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) =>
      Future.error(StateError('async boom'));
  @override
  Future<void> setUserProperty(String name, String? value) =>
      Future.error(StateError('async boom'));
}

void main() {
  late RecordingAnalyticsBackend backend;
  late AnalyticsService analytics;

  setUp(() {
    backend = RecordingAnalyticsBackend();
    analytics = AnalyticsService(backend: backend);
  });

  test('only the agreed aggregate events exist', () {
    analytics.logSettingsOpen();
    analytics.logHowToPlayOpen(source: AnalyticsValues.sourceSettings);
    analytics.logGameOverChoice(AnalyticsValues.choiceReplay);
    analytics.logGameOverChoice(AnalyticsValues.choiceHome);
    analytics.logToggleSound(false);
    analytics.logToggleMusic(true);
    analytics.logChangeLanguage('tr');

    expect(backend.eventNames, [
      AnalyticsEvents.settingsOpen,
      AnalyticsEvents.howToPlayOpen,
      AnalyticsEvents.gameOverChoice,
      AnalyticsEvents.gameOverChoice,
      AnalyticsEvents.settingsChange,
      AnalyticsEvents.settingsChange,
      AnalyticsEvents.settingsChange,
    ]);
    expect(backend.events[1].params?[AnalyticsParams.source], 'settings');
    expect(backend.events[2].params?[AnalyticsParams.choice], 'replay');
    expect(backend.events[3].params?[AnalyticsParams.choice], 'home');
    expect(backend.events[4].params,
        {AnalyticsParams.setting: 'sound', AnalyticsParams.value: 'off'});
    expect(backend.events[5].params,
        {AnalyticsParams.setting: 'music', AnalyticsParams.value: 'on'});
    expect(backend.events[6].params,
        {AnalyticsParams.setting: 'language', AnalyticsParams.value: 'tr'});
    expect(backend.screens, isEmpty);
  });

  test('game_start / game_end carry mode, limits, winner and final score', () {
    analytics.logGameStart(
      isSinglePlayer: true,
      isTimeMode: true,
      timeLimit: 30,
      scoreLimit: 100,
      difficulty: 7,
    );
    analytics.logGameEnd(
      isSinglePlayer: false,
      isTimeMode: false,
      timeLimit: 30,
      scoreLimit: 50,
      difficulty: 5,
      player1Score: 45,
      player2Score: 38,
      durationSec: 21,
    );
    final start = backend.events[0].params!;
    expect(start[AnalyticsParams.playerMode], AnalyticsValues.vsAi);
    expect(start[AnalyticsParams.gameType], AnalyticsValues.time);
    expect(start[AnalyticsParams.timeLimit], 30);
    expect(start.containsKey(AnalyticsParams.scoreLimit), isFalse);
    expect(start[AnalyticsParams.difficulty], 7);
    expect(start[AnalyticsParams.rematch], 0);

    final end = backend.events[1].params!;
    expect(backend.events[1].name, AnalyticsEvents.gameEnd);
    expect(end[AnalyticsParams.playerMode], AnalyticsValues.vsFriend);
    expect(end[AnalyticsParams.scoreLimit], 50);
    expect(end.containsKey(AnalyticsParams.difficulty), isFalse);
    expect(end[AnalyticsParams.winner], AnalyticsValues.winnerPlayer1);
    expect(end[AnalyticsParams.finalScore], '45-38');
    expect(end[AnalyticsParams.totalTaps], 83);
    expect(end[AnalyticsParams.durationSec], 21);
  });

  test('winner covers robot, player and tie', () {
    String w(bool sp, int a, int b) => AnalyticsService.winnerFor(
        isSinglePlayer: sp, player1Score: a, player2Score: b);
    expect(w(true, 10, 3), AnalyticsValues.winnerPlayer);
    expect(w(true, 3, 10), AnalyticsValues.winnerRobot);
    expect(w(false, 3, 10), AnalyticsValues.winnerPlayer2);
    expect(w(false, 7, 7), AnalyticsValues.winnerTie);
  });

  test('not configured (connector throws): stays no-op and never throws',
      () async {
    final service = AnalyticsService(
      connector: () async => throw Exception('No Firebase App [DEFAULT]'),
    );
    service.logSettingsOpen(); // before init: buffered, no throw
    expect(service.debugBufferedCount, 1);
    await service.initialize();
    expect(service.isEnabled, isFalse);
    expect(service.debugBufferedCount, 0);
    expect(
      () => service.logGameEnd(
        isSinglePlayer: true,
        isTimeMode: false,
        timeLimit: 30,
        scoreLimit: 50,
        difficulty: 5,
        player1Score: 50,
        player2Score: 12,
        durationSec: 9,
      ),
      returnsNormally,
    );
  });

  test('default Firebase connector without google-services.json does not throw',
      () async {
    final service = AnalyticsService();
    await service.initialize();
    expect(service.isEnabled, isFalse);
    expect(() => service.logSettingsOpen(), returnsNormally);
  });

  test('backend errors (sync or async) never reach the caller', () async {
    final service = AnalyticsService(backend: _ThrowingBackend());
    expect(() => service.logSettingsOpen(), returnsNormally);
    expect(() => service.logToggleSound(true), returnsNormally);
    await Future<void>.delayed(Duration.zero);
  });

  test('events logged before init are flushed once backend is ready',
      () async {
    final rec = RecordingAnalyticsBackend();
    final service = AnalyticsService(connector: () async => rec);
    service.logSettingsOpen();
    expect(rec.events, isEmpty);
    await service.initialize();
    expect(rec.eventNames, [AnalyticsEvents.settingsOpen]);
  });
}
