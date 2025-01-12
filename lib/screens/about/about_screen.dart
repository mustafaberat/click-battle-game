import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
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
        child: Column(
          children: [
            // Logo and App Name
            Container(
              padding: EdgeInsets.all(AppDimensions.padding(context) * 2),
              child: Column(
                children: [
                  Icon(
                    Icons.touch_app,
                    size: MediaQuery.of(context).size.width * 0.2,
                    color: AppColors.accent,
                  ),
                  SizedBox(height: AppDimensions.spacing(context)),
                  Text(
                    'Click Battle',
                    style: AppTextStyles.heading(context).copyWith(
                      fontSize: AppDimensions.titleFontSize(context) * 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing(context) * 0.5),
                  Text(
                    'Version 1.0.0',
                    style: AppTextStyles.body(context).copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Developer Info
            Card(
              margin: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding(context),
                vertical: AppDimensions.padding(context) * 0.5,
              ),
              color: AppColors.cardBackground,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.business, color: AppColors.accent),
                    title: Text(
                      'Developed by',
                      style: AppTextStyles.body(context),
                    ),
                    subtitle: Text(
                      'ARU Soft',
                      style: AppTextStyles.subtitle(context).copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Colors.white12),
                  ListTile(
                    leading: const Icon(Icons.code, color: AppColors.accent),
                    title: Text(
                      'Technology',
                      style: AppTextStyles.body(context),
                    ),
                    subtitle: Text(
                      'Built with Flutter',
                      style: AppTextStyles.body(context).copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Copyright
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.all(AppDimensions.padding(context)),
                child: Text(
                  '© 2024 ARU Soft. All rights reserved.',
                  style: AppTextStyles.body(context).copyWith(
                    color: Colors.white54,
                    fontSize: AppDimensions.bodyFontSize(context) * 0.9,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 