import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();
  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.deepPurple.withValues(alpha: 0.06),
      blurRadius: 16, offset: const Offset(0, 4),
    ),
  ];
  static List<BoxShadow> elevatedAdd = [
    BoxShadow(
      color: AppColors.primaryPurple.withValues(alpha: 0.32),
      blurRadius: 18, offset: const Offset(0, 6),
    ),
  ];
}
