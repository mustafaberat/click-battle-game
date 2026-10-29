import 'package:flutter/foundation.dart';

import 'package:clickbattle/analytics/analytics_backend.dart';
import 'package:clickbattle/analytics/analytics_events.dart';
import 'package:clickbattle/analytics/analytics_sanitizer.dart';
import 'package:clickbattle/analytics/firebase_analytics_backend.dart';

typedef AnalyticsConnector = Future<AnalyticsBackend> Function();

/// App-wide analytics facade. Screens call typed methods here, never Firebase.
class AnalyticsService {
  AnalyticsService({
    AnalyticsBackend? backend,
    AnalyticsConnector? connector,
  })  : _backend = backend ?? const NoopAnalyticsBackend(),
        _connector = connector,
        _backendInjected = backend != null;

  static AnalyticsService instance = AnalyticsService();

  AnalyticsBackend _backend;
  final AnalyticsConnector? _connector;
  final bool _backendInjected;
  bool _ready = false;
  bool _initializeAttempted = false;

  bool get isEnabled => _ready && _backend is! NoopAnalyticsBackend;

  /// Tries Firebase; on missing config or any failure, stays a no-op.
  Future<void> initialize({AnalyticsConnector? connector}) async {
    if (_backendInjected) {
      _ready = _backend is! NoopAnalyticsBackend;
      _initializeAttempted = true;
      return;
    }
    if (_initializeAttempted) return;
    _initializeAttempted = true;
    try {
      final connect = connector ?? _connector ?? FirebaseAnalyticsConnector.connect;
      _backend = await connect();
      _ready = _backend is! NoopAnalyticsBackend;
      debugPrint(
        _ready
            ? 'Firebase Analytics initialized.'
            : 'Firebase Analytics using no-op backend.',
      );
    } catch (e) {
      debugPrint(
        'Firebase Analytics unavailable (app continues without tracking): $e',
      );
      _backend = const NoopAnalyticsBackend();
      _ready = false;
    }
  }

  @visibleForTesting
  static void debugSetInstance(AnalyticsService service) {
    instance = service;
  }

  @visibleForTesting
  static void debugResetInstance() {
    instance = AnalyticsService();
  }

  Future<void> logEvent(String name, [Map<String, Object?>? params]) {
    return _backend.logEvent(
      AnalyticsSanitizer.eventName(name),
      params == null ? null : AnalyticsSanitizer.params(params),
    );
  }

  Future<void> logScreenView(String screenName, {String? screenClass}) {
    return _backend.logScreenView(
      AnalyticsSanitizer.eventName(screenName),
      screenClass: screenClass == null
          ? null
          : AnalyticsSanitizer.eventName(screenClass),
    );
  }

  Future<void> setUserProperty(String name, String? value) {
    return _backend.setUserProperty(
      AnalyticsSanitizer.userPropertyName(name),
      AnalyticsSanitizer.userPropertyValue(value),
    );
  }

  Future<void> syncUserProperties({
    String? language,
    bool? soundOn,
    bool? musicOn,
    String? playerMode,
    String? gameType,
    int? difficulty,
  }) async {
    if (language != null) {
      await setUserProperty(AnalyticsUserProps.appLanguage, language);
    }
    if (soundOn != null) {
      await setUserProperty(AnalyticsUserProps.soundOn, soundOn ? 'true' : 'false');
    }
    if (musicOn != null) {
      await setUserProperty(AnalyticsUserProps.musicOn, musicOn ? 'true' : 'false');
    }
    if (playerMode != null) {
      await setUserProperty(AnalyticsUserProps.playerMode, playerMode);
    }
    if (gameType != null) {
      await setUserProperty(AnalyticsUserProps.gameType, gameType);
    }
    if (difficulty != null) {
      await setUserProperty(
        AnalyticsUserProps.lastDifficulty,
        difficulty.toString(),
      );
    }
  }

  Future<void> logHomeReached() => logEvent(AnalyticsEvents.homeReached);

  Future<void> logTapStart() => logEvent(AnalyticsEvents.tapStart);

  Future<void> logTapSettings() => logEvent(AnalyticsEvents.tapSettings);

  Future<void> logTapHowToPlay({String source = AnalyticsValues.sourceHome}) {
    return logEvent(AnalyticsEvents.tapHowToPlay, {
      AnalyticsParams.source: source,
    });
  }

  Future<void> logTapBack(String screen) {
    return logEvent(AnalyticsEvents.tapBack, {
      AnalyticsParams.screen: screen,
    });
  }

  Future<void> logTapStartBattle({
    required bool isSinglePlayer,
    required bool isTimeMode,
    required int timeLimit,
    required int scoreLimit,
    required int difficulty,
  }) async {
    final playerMode = _playerMode(isSinglePlayer);
    final gameType = _gameType(isTimeMode);
    await syncUserProperties(
      playerMode: playerMode,
      gameType: gameType,
      difficulty: isSinglePlayer ? difficulty : null,
    );
    await logEvent(AnalyticsEvents.tapStartBattle, {
      AnalyticsParams.playerMode: playerMode,
      AnalyticsParams.gameType: gameType,
      AnalyticsParams.timeLimit: timeLimit,
      AnalyticsParams.scoreLimit: scoreLimit,
      if (isSinglePlayer) AnalyticsParams.difficulty: difficulty,
    });
  }

  Future<void> logTapRematch() => logEvent(AnalyticsEvents.tapRematch);

  Future<void> logTapBackHome() => logEvent(AnalyticsEvents.tapBackHome);

  Future<void> logTapRateApp() => logEvent(AnalyticsEvents.tapRateApp);

  Future<void> logSelectPlayerMode({required bool isSinglePlayer}) async {
    final playerMode = _playerMode(isSinglePlayer);
    await setUserProperty(AnalyticsUserProps.playerMode, playerMode);
    await logEvent(AnalyticsEvents.selectPlayerMode, {
      AnalyticsParams.playerMode: playerMode,
    });
  }

  Future<void> logSelectGameType({required bool isTimeMode}) async {
    final gameType = _gameType(isTimeMode);
    await setUserProperty(AnalyticsUserProps.gameType, gameType);
    await logEvent(AnalyticsEvents.selectGameType, {
      AnalyticsParams.gameType: gameType,
    });
  }

  Future<void> logSelectLimit({
    required bool isTimeMode,
    required int value,
  }) {
    return logEvent(AnalyticsEvents.selectLimit, {
      AnalyticsParams.gameType: _gameType(isTimeMode),
      AnalyticsParams.value: value,
    });
  }

  Future<void> logChangeLanguage(String language) async {
    await setUserProperty(AnalyticsUserProps.appLanguage, language);
    await logEvent(AnalyticsEvents.changeLanguage, {
      AnalyticsParams.language: language,
    });
  }

  Future<void> logToggleSound(bool enabled) async {
    await setUserProperty(AnalyticsUserProps.soundOn, enabled ? 'true' : 'false');
    await logEvent(AnalyticsEvents.toggleSound, {
      AnalyticsParams.enabled: enabled,
    });
  }

  Future<void> logToggleMusic(bool enabled) async {
    await setUserProperty(AnalyticsUserProps.musicOn, enabled ? 'true' : 'false');
    await logEvent(AnalyticsEvents.toggleMusic, {
      AnalyticsParams.enabled: enabled,
    });
  }

  Future<void> logGameStart({
    required bool isSinglePlayer,
    required bool isTimeMode,
    required int timeLimit,
    required int scoreLimit,
    required int difficulty,
    bool rematch = false,
  }) {
    return logEvent(AnalyticsEvents.gameStart, {
      AnalyticsParams.playerMode: _playerMode(isSinglePlayer),
      AnalyticsParams.gameType: _gameType(isTimeMode),
      AnalyticsParams.timeLimit: timeLimit,
      AnalyticsParams.scoreLimit: scoreLimit,
      if (isSinglePlayer) AnalyticsParams.difficulty: difficulty,
      AnalyticsParams.rematch: rematch,
    });
  }

  Future<void> logGameEnd({
    required bool isSinglePlayer,
    required bool isTimeMode,
    required int timeLimit,
    required int scoreLimit,
    required int difficulty,
    required int player1Score,
    required int player2Score,
    required int durationSec,
  }) {
    return logEvent(AnalyticsEvents.gameEnd, {
      AnalyticsParams.playerMode: _playerMode(isSinglePlayer),
      AnalyticsParams.gameType: _gameType(isTimeMode),
      AnalyticsParams.timeLimit: timeLimit,
      AnalyticsParams.scoreLimit: scoreLimit,
      if (isSinglePlayer) AnalyticsParams.difficulty: difficulty,
      AnalyticsParams.winner: _winner(
        isSinglePlayer: isSinglePlayer,
        player1Score: player1Score,
        player2Score: player2Score,
      ),
      AnalyticsParams.durationSec: durationSec,
      AnalyticsParams.player1Score: player1Score,
      AnalyticsParams.player2Score: player2Score,
      AnalyticsParams.totalTaps: player1Score + player2Score,
    });
  }

  Future<void> logGameQuit({
    required bool isSinglePlayer,
    required bool isTimeMode,
    required int timeLimit,
    required int scoreLimit,
    required int difficulty,
    required int player1Score,
    required int player2Score,
    required int durationSec,
    required bool duringCountdown,
  }) {
    return logEvent(AnalyticsEvents.gameQuit, {
      AnalyticsParams.playerMode: _playerMode(isSinglePlayer),
      AnalyticsParams.gameType: _gameType(isTimeMode),
      AnalyticsParams.timeLimit: timeLimit,
      AnalyticsParams.scoreLimit: scoreLimit,
      if (isSinglePlayer) AnalyticsParams.difficulty: difficulty,
      AnalyticsParams.durationSec: durationSec,
      AnalyticsParams.player1Score: player1Score,
      AnalyticsParams.player2Score: player2Score,
      AnalyticsParams.totalTaps: player1Score + player2Score,
      AnalyticsParams.duringCountdown: duringCountdown,
    });
  }

  Future<void> logTutorialBegin() => logEvent(AnalyticsEvents.tutorialBegin);

  Future<void> logTutorialComplete({
    required int playerScore,
    required int robotScore,
  }) {
    return logEvent(AnalyticsEvents.tutorialComplete, {
      AnalyticsParams.player1Score: playerScore,
      AnalyticsParams.player2Score: robotScore,
    });
  }

  Future<void> logTutorialSkip() => logEvent(AnalyticsEvents.tutorialSkip);

  Future<void> logTutorialReplay() => logEvent(AnalyticsEvents.tutorialReplay);

  Future<void> logTutorialGotIt() => logEvent(AnalyticsEvents.tutorialGotIt);

  Future<void> logBannerLoaded() {
    return logEvent(AnalyticsEvents.bannerLoaded, {
      AnalyticsParams.adPlacement: AnalyticsValues.placementHomeBanner,
    });
  }

  Future<void> logBannerFailed({int? errorCode, String? errorMessage}) {
    return logEvent(AnalyticsEvents.bannerFailed, {
      AnalyticsParams.adPlacement: AnalyticsValues.placementHomeBanner,
      AnalyticsParams.errorCode: errorCode,
      AnalyticsParams.errorMessage: errorMessage,
    });
  }

  Future<void> logInterstitialShown() {
    return logEvent(AnalyticsEvents.interstitialShown, {
      AnalyticsParams.adPlacement: AnalyticsValues.placementGameoverHome,
    });
  }

  Future<void> logInterstitialDismissed() {
    return logEvent(AnalyticsEvents.interstitialDismissed, {
      AnalyticsParams.adPlacement: AnalyticsValues.placementGameoverHome,
    });
  }

  Future<void> logInterstitialFailed({
    required String stage,
    int? errorCode,
    String? errorMessage,
  }) {
    return logEvent(AnalyticsEvents.interstitialFailed, {
      AnalyticsParams.adPlacement: AnalyticsValues.placementGameoverHome,
      AnalyticsParams.stage: stage,
      AnalyticsParams.errorCode: errorCode,
      AnalyticsParams.errorMessage: errorMessage,
    });
  }

  String _playerMode(bool isSinglePlayer) =>
      isSinglePlayer ? AnalyticsValues.vsAi : AnalyticsValues.vsFriend;

  String _gameType(bool isTimeMode) =>
      isTimeMode ? AnalyticsValues.time : AnalyticsValues.score;

  String _winner({
    required bool isSinglePlayer,
    required int player1Score,
    required int player2Score,
  }) {
    if (player1Score == player2Score) return AnalyticsValues.winnerTie;
    if (isSinglePlayer) {
      return player1Score > player2Score
          ? AnalyticsValues.winnerPlayer
          : AnalyticsValues.winnerRobot;
    }
    return player1Score > player2Score
        ? AnalyticsValues.winnerPlayer1
        : AnalyticsValues.winnerPlayer2;
  }
}
