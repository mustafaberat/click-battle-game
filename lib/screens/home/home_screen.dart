import 'package:flutter/material.dart';
import 'package:clickbattle/screens/home/home_styles.dart';
import 'package:clickbattle/styles/app_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonSpacing = AppDimensions.spacing(context);
    final iconSize = screenSize.width * 0.06;

    return Scaffold(
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Container(
                padding: HomeStyles.titlePadding(context),
                decoration: HomeStyles.titleContainer(context),
                child: Text(
                  'CLICK BATTLE',
                  style: HomeStyles.titleText(context),
                ),
              ),
              SizedBox(height: screenSize.height * 0.08),
              // Play Button
              _buildButton(
                context,
                'Play',
                Icons.play_arrow_rounded,
                AppColors.accent,
                () => Navigator.pushNamed(context, '/mode_selection'),
                iconSize,
              ),
              SizedBox(height: buttonSpacing),
              // Settings Button
              _buildButton(
                context,
                'Settings',
                Icons.settings_rounded,
                AppColors.secondary,
                () => Navigator.pushNamed(context, '/settings'),
                iconSize,
              ),
              SizedBox(height: buttonSpacing),
              // About Button
              _buildButton(
                context,
                'About',
                Icons.info_outline_rounded,
                AppColors.primary,
                () {}, // TODO: Implement about screen
                iconSize,
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
    double iconSize,
  ) {
    return Container(
      width: AppDimensions.buttonWidth(context),
      height: AppDimensions.buttonHeight(context),
      decoration: HomeStyles.buttonDecoration(context, color),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: iconSize),
              SizedBox(width: AppDimensions.padding(context) * 0.625),
              Text(text, style: AppTextStyles.button(context)),
            ],
          ),
        ),
      ),
    );
  }
} 