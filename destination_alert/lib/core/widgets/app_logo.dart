import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../constants/asset_constants.dart';

/// Reusable application logo widget preserving brand identity and proportions.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showContainer;
  final double borderRadius;

  const AppLogo({
    super.key,
    this.size = 80.0,
    this.showContainer = true,
    this.borderRadius = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.asset(
      AppAssets.appLogo,
      width: showContainer ? size * 0.72 : size,
      height: showContainer ? size * 0.72 : size,
      fit: BoxFit.contain,
    );

    if (!showContainer) {
      return imageWidget;
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Center(child: imageWidget),
    );
  }
}
