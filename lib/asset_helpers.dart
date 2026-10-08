import 'package:agro_guardian/theme/app_theme.dart';
import 'package:flutter/material.dart';

Widget assetImageOrPlaceholder(
  String assetPath, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  IconData placeholderIcon = Icons.image_not_supported_outlined,
}) {
  return Image.asset(
    assetPath,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) {
      return SizedBox(
        width: width,
        height: height,
        child: ColoredBox(
          color: AppColors.surfaceElevated,
          child: Icon(
            placeholderIcon,
            size: (width != null && height != null)
                ? (width < height ? width : height) * 0.5
                : 48,
            color: AppColors.textSecondary,
          ),
        ),
      );
    },
  );
}

Widget authBackground({Color fallbackColor = AppColors.background}) {
  return Image.asset(
    'assets/bgg.jpg',
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
    errorBuilder: (context, error, stackTrace) {
      return ColoredBox(color: fallbackColor);
    },
  );
}
