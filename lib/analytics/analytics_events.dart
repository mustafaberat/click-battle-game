/// GA4 / Firebase Analytics event names, params, screens, and user properties.
///
/// Rules enforced here and in [AnalyticsSanitizer]:
/// - snake_case, start with a letter, max 40 chars
/// - no reserved names (`screen_view` is logged via the dedicated API)
/// - no reserved prefixes: firebase_, google_, ga_
class AnalyticsEvents {
  AnalyticsEvents._();

  static const homeReached = 'home_reached';
  static const tapStart = 'tap_start';
  static const tapSettings = 'tap_settings';
  static const tapHowToPlay = 'tap_how_to_play';
  static const tapBack = 'tap_back';
  static const tapStartBattle = 'tap_start_battle';
  static const tapRematch = 'tap_rematch';
  static const tapBackHome = 'tap_back_home';
  static const tapRateApp = 'tap_rate_app';
  static const selectPlayerMode = 'select_player_mode';
  static const selectGameType = 'select_game_type';
  static const selectLimit = 'select_limit';
  static const changeLanguage = 'change_language';
  static const toggleSound = 'toggle_sound';
  static const toggleMusic = 'toggle_music';
  static const gameStart = 'game_start';
  static const gameEnd = 'game_end';
  static const gameQuit = 'game_quit';
  static const tutorialBegin = 'tutorial_begin';
  static const tutorialComplete = 'tutorial_complete';
  static const tutorialSkip = 'tutorial_skip';
  static const tutorialReplay = 'tutorial_replay';
  static const tutorialGotIt = 'tutorial_got_it';
  static const bannerLoaded = 'banner_loaded';
  static const bannerFailed = 'banner_failed';
  static const interstitialShown = 'interstitial_shown';
  static const interstitialDismissed = 'interstitial_dismissed';
  static const interstitialFailed = 'interstitial_failed';
}

class AnalyticsParams {
  AnalyticsParams._();

  static const screen = 'screen';
  static const source = 'source';
  static const playerMode = 'player_mode';
  static const gameType = 'game_type';
  static const timeLimit = 'time_limit';
  static const scoreLimit = 'score_limit';
  static const difficulty = 'difficulty';
  static const rematch = 'rematch';
  static const winner = 'winner';
  static const durationSec = 'duration_sec';
  static const player1Score = 'player1_score';
  static const player2Score = 'player2_score';
  static const totalTaps = 'total_taps';
  static const duringCountdown = 'during_countdown';
  static const language = 'language';
  static const value = 'value';
  static const enabled = 'enabled';
  static const errorCode = 'error_code';
  static const errorMessage = 'error_message';
  static const stage = 'stage';
  static const adPlacement = 'ad_placement';
}

class AnalyticsScreens {
  AnalyticsScreens._();

  static const home = 'home';
  static const settings = 'settings';
  static const modeSelection = 'mode_selection';
  static const howToPlay = 'how_to_play';
  static const game = 'game';
  static const gameOver = 'game_over';

  static const Map<String, String> routeToScreen = {
    '/': home,
    '/settings': settings,
    '/mode_selection': modeSelection,
    '/how_to_play': howToPlay,
    '/game': game,
  };

  static String? fromRoute(String? routeName) {
    if (routeName == null || routeName.isEmpty) return null;
    return routeToScreen[routeName];
  }
}

class AnalyticsUserProps {
  AnalyticsUserProps._();

  static const playerMode = 'player_mode';
  static const gameType = 'game_type';
  static const appLanguage = 'app_language';
  static const lastDifficulty = 'last_difficulty';
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
  static const stageLoad = 'load';
  static const stageShow = 'show';
  static const stageNotReady = 'not_ready';
  static const placementHomeBanner = 'home_banner';
  static const placementGameoverHome = 'gameover_home';
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
