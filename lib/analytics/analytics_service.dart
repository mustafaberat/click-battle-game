import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'package:clickbattle/analytics/analytics_backend.dart';
import 'package:clickbattle/analytics/analytics_events.dart';
import 'package:clickbattle/analytics/analytics_sanitizer.dart';
import 'package:clickbattle/analytics/firebase_analytics_backend.dart';

typedef AnalyticsConnector = Future<AnalyticsBackend> Function();

/// App-wide analytics facade. Screens call typed methods here, never Firebase.
///
/// Every public `log*` method is fire-and-forget: it returns `void`, never
/// throws, and never makes the caller wait on Firebase. Calls made before
/// [initialize] finishes are buffered (bounded) and flushed once the backend
/// is ready, or dropped if Firebase is not configured.
class AnalyticsService {
  AnalyticsService({
    AnalyticsBackend? backend,
    AnalyticsConnector? connector,
  })  : _backend = backend ?? const NoopAnalyticsBackend(),
        _connector = connector,
        _backendInjected = backend != null,
        _ready = backend != null;

  static AnalyticsService instance = AnalyticsService();

  static const int _maxBuffered = 50;

  AnalyticsBackend _backend;
  final AnalyticsConnector? _connector;
  final bool _backendInjected;
  bool _ready;
  bool _initializeAttempted = false;
  final Queue<Future<void> Function(AnalyticsBackend)> _buffer = Queue();

  bool get isEnabled => _ready && _backend is! NoopAnalyticsBackend;

  /// Tries Firebase; on missing config or any failure, stays a no-op.
  /// main() runs this unawaited so it never delays the first frame.
  Future<void> initialize({AnalyticsConnector? connector}) async {
    if (_backendInjected || _initializeAttempted) return;
    _initializeAttempted = true;
    try {
      final connect =
          connector ?? _connector ?? FirebaseAnalyticsConnector.connect;
      _backend = await connect().timeout(const Duration(seconds: 10));
      debugPrint(
        _backend is NoopAnalyticsBackend
            ? 'Firebase Analytics using no-op backend.'
            : 'Firebase Analytics initialized.',
      );
    } catch (e) {
      debugPrint(
        'Firebase Analytics unavailable (app continues without tracking): $e',
      );
      _backend = const NoopAnalyticsBackend();
    }
    _ready = true;
    final pending = List.of(_buffer);
    _buffer.clear();
    if (_backend is NoopAnalyticsBackend) return;
    for (final call in pending) {
      _run(call);
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

  @visibleForTesting
  int get debugBufferedCount => _buffer.length;

  /// Never throws (sync or async) and never blocks the caller.
  void _dispatch(Future<void> Function(AnalyticsBackend b) call) {
    if (!_ready) {
      if (_buffer.length >= _maxBuffered) _buffer.removeFirst();
      _buffer.addLast(call);
      return;
    }
    if (_backend is NoopAnalyticsBackend) return;
    _run(call);
  }

  void _run(Future<void> Function(AnalyticsBackend b) call) {
    try {
      unawaited(call(_backend).catchError((Object e) {
        debugPrint('Analytics call failed: $e');
      }));
    } catch (e) {
      debugPrint('Analytics call failed: $e');
    }
  }

  void logEvent(String name, [Map<String, Object?>? params]) {
    _dispatch((b) => b.logEvent(
          AnalyticsSanitizer.eventName(name),
          params == null ? null : AnalyticsSanitizer.params(params),
        ));
  }

  void setUserProperty(String name, String? value) {
    _dispatch((b) => b.setUserProperty(
          AnalyticsSanitizer.userPropertyName(name),
          AnalyticsSanitizer.userPropertyValue(value),
        ));
  }

  void syncUserProperties({String? language, bool? soundOn, bool? musicOn}) {
    if (language != null) {
      setUserProperty(AnalyticsUserProps.appLanguage, language);
    }
    if (soundOn != null) {
      setUserProperty(AnalyticsUserProps.soundOn, soundOn ? 'true' : 'false');
    }
    if (musicOn != null) {
      setUserProperty(AnalyticsUserProps.musicOn, musicOn ? 'true' : 'false');
    }
  }

  // ---- Navigation the owner cares about ----

  void logSettingsOpen({String source = AnalyticsValues.sourceHome}) {
    logEvent(AnalyticsEvents.settingsOpen, {AnalyticsParams.source: source});
  }

  void logHowToPlayOpen({String source = AnalyticsValues.sourceHome}) {
    logEvent(AnalyticsEvents.howToPlayOpen, {AnalyticsParams.source: source});
  }

  // ---- Settings changes ----

  void logSettingsChange(String setting, Object value) {
    logEvent(AnalyticsEvents.settingsChange, {
      AnalyticsParams.setting: setting,
      AnalyticsParams.value: value is bool ? (value ? 'on' : 'off') : value,
    });
  }

  void logChangeLanguage(String language) {
    setUserProperty(AnalyticsUserProps.appLanguage, language);
    logSettingsChange(AnalyticsValues.settingLanguage, language);
  }

  void logToggleSound(bool enabled) {
    setUserProperty(AnalyticsUserProps.soundOn, enabled ? 'true' : 'false');
    logSettingsChange(AnalyticsValues.settingSound, enabled);
  }

  void logToggleMusic(bool enabled) {
    setUserProperty(AnalyticsUserProps.musicOn, enabled ? 'true' : 'false');
    logSettingsChange(AnalyticsValues.settingMusic, enabled);
  }

  // ---- Game (one event per match, never per tap) ----

  void logGameStart({
    required bool isSinglePlayer,
    required bool isTimeMode,
    required int timeLimit,
    required int scoreLimit,
    required int difficulty,
    bool rematch = false,
  }) {
    logEvent(AnalyticsEvents.gameStart, {
      ..._matchParams(
        isSinglePlayer: isSinglePlayer,
        isTimeMode: isTimeMode,
        timeLimit: timeLimit,
        scoreLimit: scoreLimit,
        difficulty: difficulty,
      ),
      AnalyticsParams.rematch: rematch,
    });
  }

  void logGameEnd({
    required bool isSinglePlayer,
    required bool isTimeMode,
    required int timeLimit,
    required int scoreLimit,
    required int difficulty,
    required int player1Score,
    required int player2Score,
    required int durationSec,
  }) {
    logEvent(AnalyticsEvents.gameEnd, {
      ..._matchParams(
        isSinglePlayer: isSinglePlayer,
        isTimeMode: isTimeMode,
        timeLimit: timeLimit,
        scoreLimit: scoreLimit,
        difficulty: difficulty,
      ),
      AnalyticsParams.winner: winnerFor(
        isSinglePlayer: isSinglePlayer,
        player1Score: player1Score,
        player2Score: player2Score,
      ),
      AnalyticsParams.finalScore: '$player1Score-$player2Score',
      AnalyticsParams.player1Score: player1Score,
      AnalyticsParams.player2Score: player2Score,
      AnalyticsParams.totalTaps: player1Score + player2Score,
      AnalyticsParams.durationSec: durationSec,
    });
  }

  void logGameQuit({
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
    logEvent(AnalyticsEvents.gameQuit, {
      ..._matchParams(
        isSinglePlayer: isSinglePlayer,
        isTimeMode: isTimeMode,
        timeLimit: timeLimit,
        scoreLimit: scoreLimit,
        difficulty: difficulty,
      ),
      AnalyticsParams.finalScore: '$player1Score-$player2Score',
      AnalyticsParams.player1Score: player1Score,
      AnalyticsParams.player2Score: player2Score,
      AnalyticsParams.durationSec: durationSec,
      AnalyticsParams.duringCountdown: duringCountdown,
    });
  }

  /// Result popup: did the player pick "play again" or "home"?
  void logGameOverChoice(String choice) {
    logEvent(AnalyticsEvents.gameOverChoice, {AnalyticsParams.choice: choice});
  }

  Map<String, Object> _matchParams({
    required bool isSinglePlayer,
    required bool isTimeMode,
    required int timeLimit,
    required int scoreLimit,
    required int difficulty,
  }) {
    return {
      AnalyticsParams.playerMode:
          isSinglePlayer ? AnalyticsValues.vsAi : AnalyticsValues.vsFriend,
      AnalyticsParams.gameType:
          isTimeMode ? AnalyticsValues.time : AnalyticsValues.score,
      if (isTimeMode) AnalyticsParams.timeLimit: timeLimit,
      if (!isTimeMode) AnalyticsParams.scoreLimit: scoreLimit,
      if (isSinglePlayer) AnalyticsParams.difficulty: difficulty,
    };
  }

  /// Player 1 = bottom (the human in vs-robot mode), player 2 = top / robot.
  static String winnerFor({
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
