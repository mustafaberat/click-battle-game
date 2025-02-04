import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/services/settings_service.dart';
import 'package:clickbattle/services/audio_service.dart';
import 'package:clickbattle/services/localization_service.dart';
import 'package:clickbattle/constants/app_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audioService = AudioService();
  late bool _isMusicEnabled;
  late double _volume;

  @override
  void initState() {
    super.initState();
    _isMusicEnabled = _audioService.isMusicEnabled;
    _volume = _audioService.volume;
  }

  Widget _buildLanguageOption(BuildContext context, String languageCode, String languageName, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: MediaQuery.of(context).size.width * 0.25,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.white24,
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
                color: isSelected ? Colors.white : Colors.white70,
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
            Padding(
              padding: EdgeInsets.all(AppDimensions.padding(context)),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: AppDimensions.spacing(context)),
                  Text(
                    localizationService.getText('settings'),
                    style: AppTextStyles.heading(context).copyWith(
                      fontSize: AppDimensions.titleFontSize(context),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Container(
                padding: EdgeInsets.all(AppDimensions.padding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Language Settings
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppDimensions.padding(context)),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.language,
                                color: AppColors.accent,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                localizationService.getText('language'),
                                style: AppTextStyles.heading(context).copyWith(
                                  fontSize: AppDimensions.titleFontSize(context) * 0.8,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppDimensions.spacing(context) * 1.5),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (var language in LocalizationService.supportedLanguages.entries)
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: _buildLanguageOption(
                                      context,
                                      language.key,
                                      language.value,
                                      localizationService.currentLanguage == language.key,
                                      () => localizationService.setLanguage(language.key),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.spacing(context)),

                    // Audio Settings
                    Container(
                      padding: EdgeInsets.all(AppDimensions.padding(context)),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizationService.getText('audioSettings'),
                            style: AppTextStyles.heading(context).copyWith(
                              fontSize: AppDimensions.titleFontSize(context) * 0.8,
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacing(context)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localizationService.getText('backgroundMusic'),
                                style: AppTextStyles.body(context).copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Switch(
                                value: _isMusicEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _isMusicEnabled = value;
                                  });
                                  _audioService.toggleMusic(value);
                                },
                                activeColor: AppColors.accent,
                                inactiveTrackColor: Colors.white.withOpacity(0.3),
                                inactiveThumbColor: Colors.grey[400],
                              ),
                            ],
                          ),
                          if (_isMusicEnabled) ...[
                            SizedBox(height: AppDimensions.spacing(context)),
                            Row(
                              children: [
                                Icon(Icons.volume_down, color: Colors.white.withOpacity(0.7)),
                                Expanded(
                                  child: Slider(
                                    value: _volume,
                                    onChanged: (value) {
                                      setState(() {
                                        _volume = value;
                                      });
                                      _audioService.setVolume(value);
                                    },
                                    activeColor: AppColors.accent,
                                    inactiveColor: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                Icon(Icons.volume_up, color: Colors.white.withOpacity(0.7)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.spacing(context) * 2),
                    
                    // About section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppDimensions.padding(context)),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizationService.getText('about'),
                            style: AppTextStyles.heading(context).copyWith(
                              fontSize: AppDimensions.titleFontSize(context) * 0.8,
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacing(context)),
                          Text(
                            localizationService.getText('clickBattle'),
                            style: AppTextStyles.body(context).copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacing(context) * 0.5),
                          Text(
                            'Version 2.0.0',
                            style: AppTextStyles.body(context).copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacing(context) * 0.5),
                          Text(
                            localizationService.getText('developedBy'),
                            style: AppTextStyles.body(context).copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
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