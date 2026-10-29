import 'package:clickbattle/constants/app_strings.dart';
import 'package:clickbattle/services/localization_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every supported language has the English key set', () {
    final en = AppStrings.translations['en']!;
    expect(LocalizationService.supportedLanguages.keys.toSet(),
        AppStrings.translations.keys.toSet());
    for (final lang in LocalizationService.languageOrder) {
      final map = AppStrings.translations[lang]!;
      expect(
        map.keys.toSet(),
        en.keys.toSet(),
        reason: 'language $lang is missing or has extra keys',
      );
    }
  });

  test('new comic restyle strings exist in English', () {
    final en = AppStrings.translations['en']!;
    for (final key in [
      'youWin',
      'robotWins',
      'player1Wins',
      'player2Wins',
      'tieHeadline',
      'vs',
      'insane',
      'backToHome',
      'playAgain',
      'gameOver',
      'tapToStart',
      'startBattle',
    ]) {
      expect(en[key], isNotNull);
      expect(en[key], isNotEmpty);
    }
  });
}
