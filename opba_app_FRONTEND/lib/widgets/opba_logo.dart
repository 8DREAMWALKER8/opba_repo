import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class OpbaLogo extends StatelessWidget {
  final double size;

  const OpbaLogo({
    super.key,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lock icon with shield
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.darkBlue,
            borderRadius: BorderRadius.circular(size * 0.2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shield shape
              Icon(
                Icons.shield,
                size: size * 0.8,
                color: AppColors.darkBlue,
              ),
              // Lock icon
              Icon(
                Icons.lock,
                size: size * 0.5,
                color: AppColors.white,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // OPBA text with icons
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'P',
                  style: TextStyle(
                    fontSize: size * 0.7,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                Text(
                  'B',
                  style: TextStyle(
                    fontSize: size * 0.7,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                Text(
                  'A',
                  style: TextStyle(
                    fontSize: size * 0.7,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Small icons at the end
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              size: size * 0.35,
              color: AppColors.darkBlue,
            ),
            Icon(
              Icons.home_outlined,
              size: size * 0.35,
              color: AppColors.darkBlue,
            ),
          ],
        ),
      ],
    );
  }
}

class OpbaLogoFull extends StatelessWidget {
  final double height;

  const OpbaLogoFull({
    super.key,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lock icon container
          Container(
            width: height * 0.7,
            height: height * 0.7,
            decoration: BoxDecoration(
              color: AppColors.darkBlue,
              borderRadius: BorderRadius.circular(height * 0.15),
            ),
            child: Icon(
              Icons.lock_outline,
              size: height * 0.4,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 4),
          // P B A text
          Text(
            'P',
            style: TextStyle(
              fontSize: height * 0.6,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          Text(
            'B',
            style: TextStyle(
              fontSize: height * 0.6,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          Text(
            'A',
            style: TextStyle(
              fontSize: height * 0.6,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(width: 2),
          // Small icons
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: height * 0.25,
                color: AppColors.darkBlue,
              ),
              Icon(
                Icons.home_outlined,
                size: height * 0.25,
                color: AppColors.darkBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
