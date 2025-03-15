import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/services/settings_service.dart';
import 'package:clickbattle/services/audio_service.dart';
import 'package:clickbattle/services/localization_service.dart';
import 'package:clickbattle/constants/app_strings.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:clickbattle/constants/app_colors.dart';
import 'package:clickbattle/components/custom_scrollbar.dart';
import 'package:clickbattle/components/screen_head.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audioService = AudioService();
  final InAppReview _inAppReview = InAppReview.instance;
  final ScrollController _scrollController = ScrollController();
  late bool _isMusicEnabled;
  late double _volume;

  @override
  void initState() {
    super.initState();
    _isMusicEnabled = _audioService.isMusicEnabled;
    _volume = _audioService.volume;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildLanguageOption(BuildContext context, String languageCode,
      String languageName, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: MediaQuery.of(context).size.width * 0.25,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getFlagEmoji(languageCode),
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              languageName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.white70,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            ScreenHead(
              title: localizationService.getText('settings'),
              onBackPressed: () => Navigator.pop(context),
            ),

            // Scrollable content
            Expanded(
              child: CustomScrollbar(
                controller: _scrollController,
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(AppDimensions.padding(context)),
                  children: [
                    // Language Settings
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppDimensions.padding(context)),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.white10,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowDark,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.white10,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.language,
                                  color: AppColors.accent,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  localizationService.getText('language'),
                                  style:
                                      AppTextStyles.heading(context).copyWith(
                                    fontSize:
                                        AppDimensions.titleFontSize(context) *
                                            0.8,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height: AppDimensions.spacing(context) * 1.2),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white05,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.white10,
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: localizationService.currentLanguage,
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: AppColors.accent),
                                isExpanded: true,
                                dropdownColor: AppColors.cardBackground,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: LocalizationService
                                    .supportedLanguages.entries
                                    .map((language) {
                                  return DropdownMenuItem<String>(
                                    value: language.key,
                                    child: Row(
                                      children: [
                                        Text(
                                          _getFlagEmoji(language.key),
                                          style: TextStyle(fontSize: 22),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          language.value,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    localizationService.setLanguage(newValue);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.spacing(context) * 1.5),

                    // Audio Settings
                    Container(
                      padding: EdgeInsets.all(AppDimensions.padding(context)),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.white10,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowDark,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.white10,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.music_note_rounded,
                                  color: AppColors.accent,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  localizationService.getText('audioSettings'),
                                  style:
                                      AppTextStyles.heading(context).copyWith(
                                    fontSize:
                                        AppDimensions.titleFontSize(context) *
                                            0.8,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height: AppDimensions.spacing(context) * 1.2),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white05,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.white10,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          localizationService
                                              .getText('backgroundMusic'),
                                          style: AppTextStyles.body(context)
                                              .copyWith(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: _isMusicEnabled,
                                      onChanged: (value) {
                                        setState(() {
                                          _isMusicEnabled = value;
                                        });
                                        _audioService.toggleMusic(value);
                                      },
                                      activeColor: AppColors.primaryBlue,
                                      inactiveTrackColor: AppColors.white10,
                                      inactiveThumbColor: AppColors.white38,
                                    ),
                                  ],
                                ),
                                if (_isMusicEnabled) ...[
                                  SizedBox(
                                      height: AppDimensions.spacing(context)),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.volume_down,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 20,
                                      ),
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            trackHeight: 4,
                                            thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: 8,
                                            ),
                                            overlayShape:
                                                RoundSliderOverlayShape(
                                              overlayRadius: 16,
                                            ),
                                            activeTrackColor: AppColors.primaryBlue,
                                            inactiveTrackColor: AppColors.white10,
                                            thumbColor: AppColors.primaryBlue,
                                            overlayColor: AppColors.primaryBlue.withOpacity(0.2),
                                          ),
                                          child: Slider(
                                            value: _volume,
                                            onChanged: (value) {
                                              setState(() {
                                                _volume = value;
                                              });
                                              _audioService.setVolume(value);
                                            },
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.volume_up,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.spacing(context) * 1.5),

                    // Rate App section
                    Container(
                      padding: EdgeInsets.all(AppDimensions.padding(context)),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.white10,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowDark,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.white10,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star_rate_rounded,
                                  color: Colors.amber,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  localizationService.getText('rateApp'),
                                  style:
                                      AppTextStyles.heading(context).copyWith(
                                    fontSize:
                                        AppDimensions.titleFontSize(context) *
                                            0.8,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacing(context)),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white05,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.amberShadow,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        localizationService
                                            .getText('enjoyingTheGame'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  height: 46,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (await _inAppReview.isAvailable()) {
                                        _inAppReview.openStoreListing();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentAmber,
                                      foregroundColor: Colors.black87,
                                      elevation: 2,
                                      shadowColor: AppColors.amberOverlay,
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.star_rate_rounded, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          localizationService
                                              .getText('rateNow'),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.spacing(context) * 1.5),

                    // About section
                    Container(
                      padding: EdgeInsets.all(AppDimensions.padding(context)),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.white10,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowDark,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.white10,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  localizationService.getText('about'),
                                  style:
                                      AppTextStyles.heading(context).copyWith(
                                    fontSize:
                                        AppDimensions.titleFontSize(context) *
                                            0.8,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacing(context)),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white05,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.white10,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    localizationService.getText('game'),
                                    style: TextStyle(
                                      color: AppColors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Text(
                                    localizationService.getText('clickBattle'),
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Divider(color: AppColors.white10),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    localizationService.getText('version'),
                                    style: TextStyle(
                                      color: AppColors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Text(
                                    '1.0.0',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Divider(color: AppColors.white10),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    localizationService.getText('developedBy'),
                                    style: TextStyle(
                                      color: AppColors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Text(
                                    'ARU SOFT',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.spacing(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFlagEmoji(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇬🇧';
      case 'tr':
        return '🇹🇷';
      case 'zh':
        return '🇨🇳';
      case 'de':
        return '🇩🇪';
      case 'es':
        return '🇪🇸';
      default:
        return '🏳️';
    }
  }
}
