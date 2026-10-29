import 'package:clickbattle/analytics/analytics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'recording_analytics_backend.dart';

void main() {
  late RecordingAnalyticsBackend backend;
  late AnalyticsService analytics;

  setUp(() {
    backend = RecordingAnalyticsBackend();
    analytics = AnalyticsService(backend: backend);
  });

  test('typed button methods emit stable event names', () async {
    await analytics.logTapStart();
    await analytics.logTapSettings();
    await analytics.logTapHowToPlay(source: AnalyticsValues.sourceHome);
    await analytics.logTapBack(AnalyticsScreens.modeSelection);
    await analytics.logTapStartBattle(
      isSinglePlayer: true,
      isTimeMode: true,
      timeLimit: 30,
      scoreLimit: 10,
      difficulty: 7,
    );
    await analytics.logTapRematch();
    await analytics.logTapBackHome();
    await analytics.logTapRateApp();

    expect(backend.eventNames, [
      AnalyticsEvents.tapStart,
      AnalyticsEvents.tapSettings,
      AnalyticsEvents.tapHowToPlay,
      AnalyticsEvents.tapBack,
      AnalyticsEvents.tapStartBattle,
      AnalyticsEvents.tapRematch,
      AnalyticsEvents.tapBackHome,
      AnalyticsEvents.tapRateApp,
    ]);
    expect(
      backend.events[2].params?[AnalyticsParams.source],
      AnalyticsValues.sourceHome,
    );
    expect(
      backend.events[4].params?[AnalyticsParams.playerMode],
      AnalyticsValues.vsAi,
    );
    expect(backend.events[4].params?[AnalyticsParams.difficulty], 7);
  });

  test('game lifecycle includes winner, duration, scores, and mode', () async {
    await analytics.logGameStart(
      isSinglePlayer: false,
      isTimeMode: false,
      timeLimit: 10,
      scoreLimit: 50,
      difficulty: 5,
      rematch: true,
    );
    await analytics.logGameEnd(
      isSinglePlayer: false,
      isTimeMode: false,
      timeLimit: 10,
      scoreLimit: 50,
      difficulty: 5,
      player1Score: 12,
      player2Score: 20,
      durationSec: 18,
    );
    await analytics.logGameQuit(
      isSinglePlayer: true,
      isTimeMode: true,
      timeLimit: 10,
      scoreLimit: 10,
      difficulty: 3,
      player1Score: 2,
      player2Score: 4,
      durationSec: 3,
      duringCountdown: true,
    );

    expect(backend.eventNames, [
      AnalyticsEvents.gameStart,
      AnalyticsEvents.gameEnd,
      AnalyticsEvents.gameQuit,
    ]);
    expect(backend.events[0].params?[AnalyticsParams.rematch], 1);
    expect(
      backend.events[1].params?[AnalyticsParams.winner],
      AnalyticsValues.winnerPlayer2,
    );
    expect(backend.events[1].params?[AnalyticsParams.totalTaps], 32);
    expect(backend.events[1].params?[AnalyticsParams.durationSec], 18);
    expect(backend.events[2].params?[AnalyticsParams.duringCountdown], 1);
  });

  test('vs AI winner mapping uses player/robot/tie', () async {
    await analytics.logGameEnd(
      isSinglePlayer: true,
      isTimeMode: true,
      timeLimit: 10,
      scoreLimit: 10,
      difficulty: 1,
      player1Score: 8,
      player2Score: 3,
      durationSec: 10,
    );
    await analytics.logGameEnd(
      isSinglePlayer: true,
      isTimeMode: true,
      timeLimit: 10,
      scoreLimit: 10,
      difficulty: 1,
      player1Score: 3,
      player2Score: 8,
      durationSec: 10,
    );
    await analytics.logGameEnd(
      isSinglePlayer: true,
      isTimeMode: true,
      timeLimit: 10,
      scoreLimit: 10,
      difficulty: 1,
      player1Score: 5,
      player2Score: 5,
      durationSec: 10,
    );

    expect(
      backend.events.map((e) => e.params?[AnalyticsParams.winner]),
      [
        AnalyticsValues.winnerPlayer,
        AnalyticsValues.winnerRobot,
        AnalyticsValues.winnerTie,
      ],
    );
  });

  test('ad and tutorial events include placement / scores', () async {
    await analytics.logBannerLoaded();
    await analytics.logBannerFailed(errorCode: 3, errorMessage: 'no fill');
    await analytics.logInterstitialShown();
    await analytics.logInterstitialDismissed();
    await analytics.logInterstitialFailed(
      stage: AnalyticsValues.stageNotReady,
    );
    await analytics.logTutorialBegin();
    await analytics.logTutorialComplete(playerScore: 4, robotScore: 1);

    expect(backend.eventNames, [
      AnalyticsEvents.bannerLoaded,
      AnalyticsEvents.bannerFailed,
      AnalyticsEvents.interstitialShown,
      AnalyticsEvents.interstitialDismissed,
      AnalyticsEvents.interstitialFailed,
      AnalyticsEvents.tutorialBegin,
      AnalyticsEvents.tutorialComplete,
    ]);
    expect(
      backend.events[0].params?[AnalyticsParams.adPlacement],
      AnalyticsValues.placementHomeBanner,
    );
    expect(backend.events[1].params?[AnalyticsParams.errorCode], 3);
    expect(
      backend.events[4].params?[AnalyticsParams.stage],
      AnalyticsValues.stageNotReady,
    );
  });

  test('user properties are written for language, sound, and preferred mode',
      () async {
    await analytics.syncUserProperties(
      language: 'tr',
      soundOn: true,
      musicOn: false,
      playerMode: AnalyticsValues.vsAi,
      gameType: AnalyticsValues.time,
      difficulty: 8,
    );

    final names = backend.userProperties.map((p) => p.name).toList();
    expect(names, [
      AnalyticsUserProps.appLanguage,
      AnalyticsUserProps.soundOn,
      AnalyticsUserProps.musicOn,
      AnalyticsUserProps.playerMode,
      AnalyticsUserProps.gameType,
      AnalyticsUserProps.lastDifficulty,
    ]);
    expect(backend.userProperties[1].value, 'true');
    expect(backend.userProperties[2].value, 'false');
    expect(backend.userProperties[5].value, '8');
  });

  test('initialize uses connector backend when it succeeds', () async {
    final connected = RecordingAnalyticsBackend();
    final service = AnalyticsService(connector: () async => connected);
    await service.initialize();
    expect(service.isEnabled, isTrue);
    await service.logHomeReached();
    expect(connected.eventNames, [AnalyticsEvents.homeReached]);
  });

  test('initialize failure leaves a no-op that does not throw', () async {
    final service = AnalyticsService(
      connector: () async => throw StateError('missing google-services.json'),
    );
    await service.initialize();
    expect(service.isEnabled, isFalse);
    await service.logTapStart();
    await service.logScreenView(AnalyticsScreens.home);
    await service.setUserProperty(AnalyticsUserProps.soundOn, 'true');
  });

  test('injected backend skips Firebase connector', () async {
    final service = AnalyticsService(backend: backend);
    await service.initialize(
      connector: () async => throw StateError('should not run'),
    );
    expect(service.isEnabled, isTrue);
    await service.logHomeReached();
    expect(backend.eventNames, [AnalyticsEvents.homeReached]);
  });

  test('raw logEvent sanitizes reserved prefixes', () async {
    await analytics.logEvent('google_custom', {'ga_param': 'x'});
    expect(backend.events.single.name, 'x_google_custom');
    expect(backend.events.single.params!.keys.single, 'x_ga_param');
  });
}
