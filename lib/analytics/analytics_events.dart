/// GA4 / Firebase Analytics event names, params and user properties.
///
/// Scope (owner decision): only meaningful, aggregate events. One event per
/// game start / end, per settings open, per setting change, per game-over
/// choice. Never per tap, no dwell/screen-time, no scroll or navigation noise.
///
/// Rules enforced here and in [AnalyticsSanitizer]:
/// - snake_case, start with a letter, max 40 chars
/// - no reserved names / prefixes (firebase_, google_, ga_)
class AnalyticsEvents {
  AnalyticsEvents._();

  static const gameStart = 'game_start';
  static const gameEnd = 'game_end';
  static const gameQuit = 'game_quit';
  static const gameOverChoice = 'game_over_choice';
  static const settingsOpen = 'settings_open';
  static const settingsChange = 'settings_change';
  static const howToPlayOpen = 'how_to_play_open';
}

class AnalyticsParams {
  AnalyticsParams._();

  static const source = 'source';
  static const playerMode = 'player_mode';
  static const gameType = 'game_type';
  static const timeLimit = 'time_limit';
  static const scoreLimit = 'score_limit';
  static const difficulty = 'difficulty';
  static const rematch = 'rematch';
  static const winner = 'winner';
  static const finalScore = 'final_score';
  static const durationSec = 'duration_sec';
  static const player1Score = 'player1_score';
  static const player2Score = 'player2_score';
  static const totalTaps = 'total_taps';
  static const duringCountdown = 'during_countdown';
  static const choice = 'choice';
  static const setting = 'setting';
  static const value = 'value';
}

class AnalyticsUserProps {
  AnalyticsUserProps._();

  static const appLanguage = 'app_language';
  static const soundOn = 'sound_on';
  static const musicOn = 'music_on';
}

class AnalyticsValues {
  AnalyticsValues._();

  static const vsAi = 'vs_ai';
  static const vsFriend = 'vs_friend';
  static const time = 'time';
  static const score = 'score';
  static const winnerPlayer = 'player';
  static const winnerRobot = 'robot';
  static const winnerPlayer1 = 'player1';
  static const winnerPlayer2 = 'player2';
  static const winnerTie = 'tie';
  static const sourceHome = 'home';
  static const sourceSettings = 'settings';
  static const choiceReplay = 'replay';
  static const choiceHome = 'home';
  static const settingLanguage = 'language';
  static const settingSound = 'sound';
  static const settingMusic = 'music';
}

class AnalyticsLimits {
  AnalyticsLimits._();

  static const maxEventName = 40;
  static const maxParamName = 40;
  static const maxParamValue = 100;
  static const maxUserPropertyName = 24;
  static const maxUserPropertyValue = 36;
  static const maxParams = 25;
}
