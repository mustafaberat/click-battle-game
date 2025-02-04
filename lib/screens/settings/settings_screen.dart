import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/services/settings_service.dart';
import 'package:clickbattle/services/audio_service.dart';

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
    _isMusicEnabled = false;
    _volume = 0.1; // Set default volume to 10%
    _audioService.setVolume(_volume); // Ensure the audio service reflects this change
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
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
                    'Settings',
                    style: AppTextStyles.heading(context).copyWith(
                      fontSize: AppDimensions.titleFontSize(context),
                    ),
                  ),
                ],
              ),
            ),
            
            // Settings content
            Expanded(
              child: Container(
                padding: EdgeInsets.all(AppDimensions.padding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Audio settings section
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
                            'Audio Settings',
                            style: AppTextStyles.heading(context).copyWith(
                              fontSize: AppDimensions.titleFontSize(context) * 0.8,
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacing(context)),
                          
                          // Music toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Background Music',
                                style: AppTextStyles.body(context).copyWith(
                                  color:  Colors.white,
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
                          
                          // Volume slider
                          if (_isMusicEnabled) ...[
                            SizedBox(height: AppDimensions.spacing(context)),
                            Row(
                              children: [
                                Icon(
                                  Icons.volume_down,
                                  color: Colors.white.withOpacity(0.7),
                                ),
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
                                Icon(
                                  Icons.volume_up,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // About section
                    SizedBox(height: AppDimensions.spacing(context) * 2),
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
                            'About',
                            style: AppTextStyles.heading(context).copyWith(
                              fontSize: AppDimensions.titleFontSize(context) * 0.8,
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacing(context)),
                          Text(
                            'Click Battle',
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
                            'Developed by ARU Soft',
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
} 