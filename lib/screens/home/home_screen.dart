import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppDimensions.padding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'CLICK BATTLE',
                  style: AppTextStyles.title(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.spacing(context) * 3),
                _buildButton(
                  context: context,
                  text: 'Play',
                  icon: Icons.play_arrow_rounded,
                  color: AppColors.accent,
                  onPressed: () => Navigator.pushNamed(context, '/mode_selection'),
                ),
                SizedBox(height: AppDimensions.spacing(context)),
                _buildButton(
                  context: context,
                  text: 'Settings',
                  icon: Icons.settings_rounded,
                  color: AppColors.surface,
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                ),
                SizedBox(height: AppDimensions.spacing(context)),
                _buildButton(
                  context: context,
                  text: 'About',
                  icon: Icons.info_outline_rounded,
                  color: AppColors.primary,
                  onPressed: () {}, // TODO: Implement about screen
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: AppDimensions.buttonHeight(context),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: MediaQuery.of(context).size.width * 0.06),
            SizedBox(width: AppDimensions.spacing(context) * 0.5),
            Text(text, style: AppTextStyles.button(context)),
          ],
        ),
      ),
    );
  }
} 