import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.padding(context),
            vertical: AppDimensions.padding(context) * 0.5,
          ),
          child: Column(
            children: [
              const Spacer(flex: 3),
              // App Logo and Title
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Logo
                  Container(
                    padding: EdgeInsets.all(AppDimensions.padding(context) * 0.75),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.touch_app,
                      size: MediaQuery.of(context).size.width * 0.15,
                      color: AppColors.accent,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing(context)),
                  // App Title
                  Text(
                    'Click Battle',
                    style: AppTextStyles.heading(context).copyWith(
                      fontSize: AppDimensions.titleFontSize(context) * 1.2,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing(context) * 0.5),
                  Text(
                    'Test your clicking speed!',
                    style: AppTextStyles.body(context).copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              // Bottom Buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play Button
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/mode_selection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding(context),
                        vertical: AppDimensions.padding(context),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
                      ),
                      minimumSize: Size(
                        double.infinity,
                        AppDimensions.buttonHeight(context) * 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow, color: AppColors.background, size: 32),
                        SizedBox(width: AppDimensions.spacing(context)),
                        Text(
                          'PLAY',
                          style: AppTextStyles.button(context).copyWith(
                            color: AppColors.background,
                            letterSpacing: 1.5,
                            fontSize: AppDimensions.buttonFontSize(context) * 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing(context)),
                  // Settings Button
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding(context),
                        vertical: AppDimensions.padding(context) * 0.75,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
                      ),
                      minimumSize: Size(
                        double.infinity,
                        AppDimensions.buttonHeight(context),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.settings, color: Colors.white),
                        SizedBox(width: AppDimensions.spacing(context)),
                        Text(
                          'SETTINGS',
                          style: AppTextStyles.button(context).copyWith(
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
} 