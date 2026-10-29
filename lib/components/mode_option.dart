import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/services/app_manager.dart';
import 'package:clickbattle/styles/app_styles.dart';

class ModeOption extends StatelessWidget {
  final String text;
  final IconData? icon;
  final IconData? secondaryIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final String? topText;
  final int? stars;

  const ModeOption({
    Key? key,
    required this.text,
    this.icon,
    this.secondaryIcon,
    required this.isSelected,
    required this.onTap,
    required this.color,
    this.topText,
    this.stars,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appManager = Provider.of<AppManager>(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppDimensions.paddingXSmall),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.15)
              : appManager.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          border: Border.all(
            color: isSelected 
                ? color
                : appManager.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? color : appManager.white70,
                    size: AppDimensions.iconSizeMedium * 0.9,
                  ),
                  if (secondaryIcon != null) ...[
                    SizedBox(width: AppDimensions.spacing(context) * 0.3),
                    Container(
                      height: 14,
                      width: 1,
                      color: isSelected ? color : appManager.white70,
                    ),
                    SizedBox(width: AppDimensions.spacing(context) * 0.3),
                    Icon(
                      secondaryIcon,
                      color: isSelected ? color : appManager.white70,
                      size: AppDimensions.iconSizeMedium * 0.9,
                    ),
                  ],
                ],
              ),
              SizedBox(height: AppDimensions.spacing(context) * 0.3),
            ],
            Text(
              topText ?? text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? appManager.white : appManager.white70,
                fontSize: AppDimensions.fontSizeXSmall,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (stars != null) ...[
              SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(stars!, (index) {
                  return Icon(
                    Icons.star,
                    size: 14,
                    color: isSelected ? color : appManager.white70,
                  );
                }),
              ),
            ],
            if (topText != null) ...[
              SizedBox(height: 2),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? appManager.white : appManager.white70,
                  fontSize: AppDimensions.fontSizeSmall * 0.7,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 