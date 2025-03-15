import 'package:flutter/material.dart';
import 'package:clickbattle/constants/app_colors.dart';

class CustomScrollbar extends StatelessWidget {
  final ScrollController controller;
  final Widget child;
  final double thickness;
  final double radius;
  final bool isVisible;

  const CustomScrollbar({
    Key? key,
    required this.controller,
    required this.child,
    this.thickness = 8,
    this.radius = 20,
    this.isVisible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: controller,
      thumbColor: AppColors.white38,
      radius: Radius.circular(radius),
      thickness: thickness,
      thumbVisibility: isVisible,
      child: child,
    );
  }
} 