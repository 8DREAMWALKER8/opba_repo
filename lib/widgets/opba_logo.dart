import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OpbaLogo extends StatelessWidget {
  final double size;
  final bool showBackground;

  const OpbaLogo({
    super.key,
    this.size = 1.0,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(16 * size),
      decoration: showBackground
          ? BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16 * size),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lock icon
          Icon(
            Icons.lock,
            color: AppColors.primaryBlue,
            size: 28 * size,
          ),
          SizedBox(width: 6 * size),
          // P
          Text(
            'P',
            style: TextStyle(
              fontSize: 32 * size,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          // B
          Text(
            'B',
            style: TextStyle(
              fontSize: 32 * size,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          // A
          Text(
            'A',
            style: TextStyle(
              fontSize: 32 * size,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(width: 6 * size),
          // Bank icon
          Icon(
            Icons.account_balance,
            color: AppColors.primaryBlue,
            size: 28 * size,
          ),
        ],
      ),
    );
  }
}

class OpbaLogoWithText extends StatelessWidget {
  const OpbaLogoWithText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const OpbaLogo(),
        const SizedBox(height: 12),
        Text(
          'Open Personal Banking',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}