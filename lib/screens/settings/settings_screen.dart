import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Settings',
              style: AppTextStyles.title(context),
            ),
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            color: AppColors.background,
            child: ListView(
              padding: EdgeInsets.all(AppDimensions.padding(context)),
              children: [
                // Sound Settings Section
                _buildSectionHeader(context, 'Sound'),
                SwitchListTile(
                  title: Text(
                    'Sound Effects',
                    style: AppTextStyles.body(context),
                  ),
                  value: settings.soundEnabled,
                  onChanged: (value) => settings.setSoundEnabled(value),
                  activeColor: AppColors.accent,
                ),
                if (settings.soundEnabled)
                  ListTile(
                    title: Text(
                      'Volume',
                      style: AppTextStyles.body(context),
                    ),
                    subtitle: Slider(
                      value: settings.soundVolume,
                      onChanged: (value) => settings.setSoundVolume(value),
                      activeColor: AppColors.accent,
                    ),
                  ),

                // About Section
                _buildSectionHeader(context, 'About'),
                ListTile(
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
                ListTile(
                  title: Text(
                    'Developer',
                    style: AppTextStyles.body(context),
                  ),
                  trailing: Text(
                    'Mustafa Berat ARU',
                    style: AppTextStyles.body(context).copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),
                
                // Reset Settings Button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.padding(context),
                    vertical: AppDimensions.padding(context),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.padding(context),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Reset Settings?'),
                          content: Text('This will restore all settings to their default values.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                settings.resetToDefaults();
                                Navigator.pop(context);
                              },
                              child: Text('Reset'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'Reset Settings',
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
        style: AppTextStyles.heading(context).copyWith(
          color: AppColors.accent,
          fontSize: AppDimensions.bodyFontSize(context),
        ),
      ),
    );
  }
} 