import 'package:agro_guardian/l10n/app_strings.dart';
import 'package:agro_guardian/l10n/locale_controller.dart';
import 'package:agro_guardian/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key, required this.controller});

  final LocaleController controller;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isUrdu = controller.isUrdu;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Chip(
            label: strings.english,
            selected: !isUrdu,
            onTap: () {
              controller.setEnglish();
            },
          ),
          _Chip(
            label: strings.urdu,
            selected: isUrdu,
            onTap: () {
              controller.setUrdu();
            },
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? const Color(0xFF052E16)
                : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
