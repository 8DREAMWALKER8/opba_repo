import 'package:flutter/material.dart';

class AppColors {
  // Primary gradient colors
  static const Color gradientStart = Color(0xFFE8F4FD);
  static const Color gradientMiddle = Color(0xFFB8DAF5);
  static const Color gradientEnd = Color(0xFF7FBFEE);
  
  // Primary colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color darkBlue = Color(0xFF1565C0);
  
  // Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
  
  // Background colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
  
  // Border colors
  static const Color borderColor = Color(0xFF2196F3);
  static const Color borderLight = Color(0xFFE0E0E0);
  
  // Button colors
  static const Color buttonPrimary = Color(0xFF2196F3);
  static const Color buttonText = Color(0xFFFFFFFF);

  // Gradient decoration
  static BoxDecoration get gradientBackground => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [gradientStart, gradientMiddle, gradientEnd],
      stops: [0.0, 0.5, 1.0],
    ),
  );
}

class AppTextStyles {
  static const TextStyle logo = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBlue,
  );
  
  static const TextStyle title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBlue,
  );
  
  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle label = TextStyle(
    fontSize: 12,
    color: AppColors.primaryBlue,
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle hint = TextStyle(
    fontSize: 14,
    color: AppColors.textHint,
  );
  
  static const TextStyle link = TextStyle(
    fontSize: 14,
    color: AppColors.primaryBlue,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.underline,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonText,
  );
}

class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double borderRadius = 12.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 20.0;
  
  static const double inputHeight = 50.0;
  static const double buttonHeight = 48.0;
  
  static const double iconSizeSmall = 18.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
}
