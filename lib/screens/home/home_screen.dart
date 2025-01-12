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
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                ),
              ),
              // Bottom Buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play Button
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/mode_selection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
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
                        const Icon(Icons.play_arrow, color: Colors.white),
                        SizedBox(width: AppDimensions.spacing(context)),
                        Text(
                          'PLAY',
                          style: AppTextStyles.button(context).copyWith(
                            letterSpacing: 1.5,
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
                      side: const BorderSide(color: AppColors.accent),
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
                        const Icon(Icons.settings, color: AppColors.accent),
                        SizedBox(width: AppDimensions.spacing(context)),
                        Text(
                          'SETTINGS',
                          style: AppTextStyles.button(context).copyWith(
                            color: AppColors.accent,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 