import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/services/settings_service.dart';

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

                // About Section
                _buildSectionHeader(context, 'About'),
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
                          'Version',
                          style: AppTextStyles.body(context),
                        ),
                        trailing: Text(
                          '1.0.0',
                          style: AppTextStyles.body(context).copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: Colors.white12),
                      ListTile(
                        leading: const Icon(Icons.business, color: AppColors.accent),
                        title: Text(
                          'Developer',
                          style: AppTextStyles.body(context),
                        ),
                        trailing: Text(
                          'ARU Soft',
                          style: AppTextStyles.body(context).copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Reset Settings Button
                Padding(
                  padding: EdgeInsets.all(AppDimensions.padding(context)),
                  child: ElevatedButton(
                    onPressed: () {
                      settings.resetToDefaults();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings reset to defaults'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.padding(context),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Reset to Defaults',
                      style: AppTextStyles.button(context),
                    ),
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