import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/services/settings_service.dart';
import 'package:clickbattle/screens/about/about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.padding(context),
        AppDimensions.padding(context) * 1.5,
        AppDimensions.padding(context),
        AppDimensions.padding(context) * 0.5,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.subtitle(context).copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Settings',
              style: AppTextStyles.title(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            color: AppColors.background,
            child: ListView(
              children: [
                // Audio Settings Section
                _buildSectionHeader(context, 'Audio'),
                Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: AppDimensions.padding(context),
                    vertical: AppDimensions.padding(context) * 0.5,
                  ),
                  color: AppColors.cardBackground,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          'Background Music',
                          style: AppTextStyles.body(context),
                        ),
                        secondary: const Icon(Icons.music_note, color: AppColors.accent),
                        value: settings.backgroundMusicEnabled,
                        onChanged: (value) => settings.setBackgroundMusicEnabled(value),
                        activeColor: AppColors.accent,
                      ),
                      const Divider(height: 1, color: Colors.white12),
                      SwitchListTile(
                        title: Text(
                          'Touch Sounds',
                          style: AppTextStyles.body(context),
                        ),
                        secondary: const Icon(Icons.touch_app, color: AppColors.accent),
                        value: settings.touchSoundEnabled,
                        onChanged: (value) => settings.setTouchSoundEnabled(value),
                        activeColor: AppColors.accent,
                      ),
                      const Divider(height: 1, color: Colors.white12),
                      ListTile(
                        title: Text(
                          'Volume',
                          style: AppTextStyles.body(context),
                        ),
                        leading: const Icon(Icons.volume_up, color: AppColors.accent),
                        subtitle: Slider(
                          value: settings.volume,
                          onChanged: (value) => settings.setVolume(value),
                          activeColor: AppColors.accent,
                          inactiveColor: AppColors.accent.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),

                // General Section
                _buildSectionHeader(context, 'General'),
                Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: AppDimensions.padding(context),
                    vertical: AppDimensions.padding(context) * 0.5,
                  ),
                  color: AppColors.cardBackground,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline, color: AppColors.accent),
                        title: Text(
                          'About',
                          style: AppTextStyles.body(context),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AboutScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1, color: Colors.white12),
                      ListTile(
                        leading: const Icon(Icons.refresh, color: AppColors.accent),
                        title: Text(
                          'Reset Settings',
                          style: AppTextStyles.body(context),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.cardBackground,
                              title: Text(
                                'Reset Settings?',
                                style: AppTextStyles.subtitle(context),
                              ),
                              content: Text(
                                'This will restore all settings to their default values.',
                                style: AppTextStyles.body(context),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancel',
                                    style: AppTextStyles.body(context).copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    settings.resetToDefaults();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Settings reset to defaults'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Reset',
                                    style: AppTextStyles.body(context).copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 