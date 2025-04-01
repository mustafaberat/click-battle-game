import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/services/app_manager.dart';
import 'package:clickbattle/styles/app_styles.dart';

class ScreenHead extends StatelessWidget {
  final String title;
  final VoidCallback onBackPressed;

  const ScreenHead({
    Key? key,
    required this.title,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appManager = Provider.of<AppManager>(context);
    
    return Padding(
      padding: EdgeInsets.all(AppDimensions.paddingMedium),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered title
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: AppTextStyles.heading(context),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Back button aligned to the left
          Positioned(
            left: 0,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: appManager.white),
              onPressed: onBackPressed,
            ),
          ),
        ],
      ),
    );
  }
}
