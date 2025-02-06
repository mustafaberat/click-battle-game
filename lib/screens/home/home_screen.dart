import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/services/localization_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFF001554),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          child: Column(
            children: [
              const Spacer(),
              // Logo and Title section
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Logo
                  Container(
                    width: size.height * 0.3,
                    height: size.height * 0.3,
                    constraints: BoxConstraints(
                      maxWidth: 300,
                      maxHeight: 300,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'lib/assets/app-icon.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing(context)),
                  // App Title
                  Text(
                    localizationService.getText('clickBattle'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading(context).copyWith(
                      fontSize: AppDimensions.fontSizeLarge * 1.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      height: 1,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing(context) * 0.5),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                      vertical: AppDimensions.paddingSmall * 0.5,
                    ),
                    child: Text(
                      localizationService.getText('welcomeMessage'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subtitle(context).copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: AppDimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Action Buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play Button
                  Container(
                    height: AppDimensions.buttonHeightLarge,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/mode_selection'),
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sports_esports_rounded,
                                color: Colors.white,
                                size: AppDimensions.iconSizeLarge,
                              ),
                              SizedBox(width: AppDimensions.spacing(context)),
                              Text(
                                localizationService.getText('tapToStart').toUpperCase(),
                                style: AppTextStyles.button(context).copyWith(
                                  fontSize: AppDimensions.fontSizeMedium,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing(context) * 1.25),
                  // Settings Button
                  Container(
                    height: AppDimensions.buttonHeightMedium,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/settings'),
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.settings_rounded,
                                color: Colors.white.withOpacity(0.7),
                                size: AppDimensions.iconSizeMedium,
                              ),
                              SizedBox(width: AppDimensions.spacing(context)),
                              Text(
                                localizationService.getText('settings').toUpperCase(),
                                style: AppTextStyles.button(context).copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                  letterSpacing: 2,
                                  fontSize: AppDimensions.fontSizeSmall,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
} 