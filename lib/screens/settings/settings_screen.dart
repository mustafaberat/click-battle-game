import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/services/app_manager.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:clickbattle/constants/app_colors.dart';
import 'package:clickbattle/components/custom_scrollbar.dart';
import 'package:clickbattle/components/screen_head.dart';
import 'package:clickbattle/services/localization_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final InAppReview _inAppReview = InAppReview.instance;
  final ScrollController _scrollController = ScrollController();
  late bool _isMusicEnabled;
  late double _volume;
  late AppManager _appManager;

  @override
  void initState() {
    super.initState();
    _appManager = Provider.of<AppManager>(context, listen: false);
    _isMusicEnabled = _appManager.isMusicEnabled;
    _volume = _appManager.volume;
    
    // Listen to changes in the localization service to force a rebuild
    Provider.of<LocalizationService>(context, listen: false).addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    Provider.of<LocalizationService>(context, listen: false).removeListener(_onLanguageChanged);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onLanguageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildLanguageOption(BuildContext context, String languageCode,
      String languageName, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: _appManager.primaryBlue.withOpacity(0.1),
      highlightColor: _appManager.primaryBlue.withOpacity(0.2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: MediaQuery.of(context).size.width * 0.26,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _appManager.primaryBlue.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _appManager.primaryBlue : _appManager.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getFlagEmoji(languageCode),
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 8),
            Text(
              languageName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? _appManager.white : _appManager.white70,
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
    _appManager = Provider.of<AppManager>(context);

    return Scaffold(
      backgroundColor: _appManager.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            ScreenHead(
              title: _appManager.getText('settings'),
              onBackPressed: () {
                // Reload banner ad before navigating to avoid 'already in widget tree' error
                _appManager.reloadBannerAd();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),

            // Scrollable content
            Expanded(
              child: CustomScrollbar(
                controller: _scrollController,
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium),
                  children: [
                    // Language Settings
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppDimensions.padding(context)),
                      decoration: BoxDecoration(
                        color: _appManager.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _appManager.white10,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _appManager.shadowDark,
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
                                  color: _appManager.white10,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.language,
                                  color: _appManager.primaryBlue,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  _appManager.getText('language'),
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
                              color: _appManager.white05,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _appManager.white10,
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _appManager.currentLanguage,
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: _appManager.primaryBlue),
                                isExpanded: true,
                                dropdownColor: _appManager.cardBackgroundColor,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: _appManager.supportedLanguages.entries
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
                                onChanged: (String? newValue) async {
                                  if (newValue != null) {
                                    await _appManager.setLanguage(newValue);
                                    setState(() {});
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
                        color: _appManager.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _appManager.white10,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _appManager.shadowDark,
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
                                  color: _appManager.white10,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.music_note_rounded,
                                  color: _appManager.primaryBlue,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  _appManager.getText('audioSettings'),
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
                              color: _appManager.white05,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _appManager.white10,
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
                                          _appManager
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
                                        _appManager.toggleMusic(value);
                                      },
                                      activeColor: _appManager.primaryBlue,
                                      inactiveTrackColor: _appManager.white10,
                                      inactiveThumbColor: _appManager.white38,
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
                                            activeTrackColor:
                                                _appManager.primaryBlue,
                                            inactiveTrackColor:
                                                _appManager.white10,
                                            thumbColor: _appManager.primaryBlue,
                                            overlayColor: _appManager.primaryBlue
                                                .withOpacity(0.2),
                                          ),
                                          child: Slider(
                                            value: _volume,
                                            onChanged: (value) {
                                              setState(() {
                                                _volume = value;
                                              });
                                              _appManager.setVolume(value);
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
                        color: _appManager.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _appManager.white10,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _appManager.shadowDark,
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
                                  color: _appManager.white10,
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
                                  _appManager.getText('rateApp'),
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
                              color: _appManager.white05,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _appManager.white10,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _appManager
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
                                      _inAppReview.openStoreListing(); // Store review
                                      // _inAppReview.requestReview(); // Pop-up review
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentAmber,
                                      foregroundColor: Colors.black87,
                                      elevation: 2,
                                      shadowColor: AppColors.amberOverlay,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
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
                                          _appManager
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
                        color: _appManager.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _appManager.white10,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _appManager.shadowDark,
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
                                  color: _appManager.white10,
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
                                  _appManager.getText('about'),
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
                              color: _appManager.white05,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _appManager.white10,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    _appManager.getText('game'),
                                    style: TextStyle(
                                      color: _appManager.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Text(
                                    _appManager.getText('clickBattle'),
                                    style: TextStyle(
                                      color: _appManager.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Divider(color: _appManager.white10),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    _appManager.getText('version'),
                                    style: TextStyle(
                                      color: _appManager.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Text(
                                    '4.0.0',
                                    style: TextStyle(
                                      color: _appManager.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Divider(color: _appManager.white10),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    _appManager.getText('developedBy'),
                                    style: TextStyle(
                                      color: _appManager.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Text(
                                    'ARU SOFT',
                                    style: TextStyle(
                                      color: _appManager.white,
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
