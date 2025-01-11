import 'package:flutter/material.dart';
import 'package:clickbattle/screens/home/home_styles.dart';
import 'package:clickbattle/styles/app_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Container(
                padding: HomeStyles.titlePadding,
                decoration: HomeStyles.titleContainer,
                child: Text(
                  'CLICK BATTLE',
                  style: HomeStyles.titleText,
                ),
              ),
              const SizedBox(height: 60),
              // Play Button
              _buildButton(
                context,
                'Play',
                Icons.play_arrow_rounded,
                AppColors.accent,
                () => Navigator.pushNamed(context, '/mode_selection'),
              ),
              const SizedBox(height: AppDimensions.spacing),
              // Settings Button
              _buildButton(
                context,
                'Settings',
                Icons.settings_rounded,
                AppColors.secondary,
                () => Navigator.pushNamed(context, '/settings'),
              ),
              const SizedBox(height: AppDimensions.spacing),
              // About Button
              _buildButton(
                context,
                'About',
                Icons.info_outline_rounded,
                AppColors.primary,
                () {}, // TODO: Implement about screen
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: AppDimensions.buttonWidth,
      height: AppDimensions.buttonHeight,
      decoration: HomeStyles.buttonDecoration(color),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(text, style: AppTextStyles.button),
            ],
          ),
        ),
      ),
    );
  }
} 