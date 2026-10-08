import 'package:agro_guardian/asset_helpers.dart';
import 'package:agro_guardian/l10n/app_strings.dart';
import 'package:agro_guardian/l10n/locale_controller.dart';
import 'package:agro_guardian/theme/app_theme.dart';
import 'package:agro_guardian/widgets/language_toggle.dart';
import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.controller,
    required this.title,
    required this.child,
  });

  final LocaleController controller;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1C16),
              AppColors.background,
              Color(0xFF07100C),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: LanguageToggle(controller: controller),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceElevated,
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: assetImageOrPlaceholder(
                    'assets/logop.png',
                    width: 108,
                    height: 108,
                    fit: BoxFit.cover,
                    placeholderIcon: Icons.eco,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  strings.appName,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
