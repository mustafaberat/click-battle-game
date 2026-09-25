import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/services/app_manager.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:clickbattle/constants/app_colors.dart';
import 'package:clickbattle/components/custom_scrollbar.dart';
import 'package:clickbattle/components/arcade_chrome.dart';
import 'package:clickbattle/services/localization_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final InAppReview _inAppReview = InAppReview.instance;
  final ScrollController _scrollController = ScrollController();
  late AppManager _appManager;

  @override
  void initState() {
    super.initState();
    _appManager = Provider.of<AppManager>(context, listen: false);
    Provider.of<LocalizationService>(context, listen: false)
        .addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    Provider.of<LocalizationService>(context, listen: false)
        .removeListener(_onLanguageChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _appManager = Provider.of<AppManager>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            ArcadeBackHeader(
              title: _appManager.getText('settings'),
              onBack: () {
                _appManager.reloadBannerAd();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            Expanded(
              child: CustomScrollbar(
                controller: _scrollController,
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                  ),
                  children: [
                    _panel(
                      accent: ArcadeChrome.yellow,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _appManager.getText('language').toUpperCase(),
                            style: ArcadeChrome.sectionLabel(),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white12, width: 2),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _appManager.currentLanguage,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: ArcadeChrome.yellow,
                                ),
                                isExpanded: true,
                                dropdownColor: const Color(0xFF1A1A1A),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                items: _appManager.supportedLanguages.entries
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e.key,
                                        child: Text(
                                          '${_flag(e.key)}  ${e.value}',
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) async {
                                  if (v != null) {
                                    await _appManager.setLanguage(v);
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _menuRow(
                      icon: Icons.help_outline,
                      color: ArcadeChrome.blue,
                      title: _appManager.getText('howToPlay'),
                      subtitle: _appManager.getText('howToPlaySubtitle'),
                      onTap: () =>
                          Navigator.pushNamed(context, '/how_to_play'),
                    ),
                    _menuRow(
                      icon: Icons.star_rate_rounded,
                      color: AppColors.accentAmber,
                      title: _appManager.getText('rateApp'),
                      subtitle: _appManager.getText('enjoyingTheGame'),
                      onTap: () => _inAppReview.openStoreListing(),
                    ),
                    _panel(
                      accent: ArcadeChrome.red,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _appManager.getText('about').toUpperCase(),
                            style: ArcadeChrome.sectionLabel(
                              color: ArcadeChrome.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _aboutLine(
                            _appManager.getText('game'),
                            _appManager.getText('clickBattle'),
                          ),
                          const Divider(color: Colors.white12),
                          _aboutLine(_appManager.getText('version'), '4.1.0'),
                          const Divider(color: Colors.white12),
                          _aboutLine(
                            _appManager.getText('developedBy'),
                            'ARU SOFT',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
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

  Widget _panel({required Widget child, Color? accent}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: ArcadeChrome.panelBox(accent: accent),
      child: child,
    );
  }

  Widget _menuRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: ArcadeChrome.panel,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: ArcadeChrome.ui(
                          size: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: ArcadeChrome.ui(
                          size: 12,
                          color: Colors.white.withOpacity(0.55),
                          weight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: color, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _aboutLine(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: ArcadeChrome.ui(size: 13, color: Colors.white54)),
          Text(
            right,
            style: ArcadeChrome.ui(size: 13, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  String _flag(String code) {
    switch (code) {
      case 'en':
        return '🇬🇧';
      case 'es':
        return '🇪🇸';
      case 'pt':
        return '🇧🇷';
      case 'zh':
        return '🇨🇳';
      case 'ja':
        return '🇯🇵';
      case 'de':
        return '🇩🇪';
      case 'fr':
        return '🇫🇷';
      case 'ko':
        return '🇰🇷';
      case 'it':
        return '🇮🇹';
      case 'tr':
        return '🇹🇷';
      default:
        return '🏳️';
    }
  }
}
