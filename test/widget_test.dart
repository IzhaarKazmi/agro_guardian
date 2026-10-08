import 'package:agro_guardian/l10n/app_strings.dart';
import 'package:agro_guardian/l10n/locale_controller.dart';
import 'package:agro_guardian/l10n/locale_scope.dart';
import 'package:agro_guardian/splash_screen.dart';
import 'package:agro_guardian/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('splash screen shows app title', (WidgetTester tester) async {
    final localeController = LocaleController();

    await tester.pumpWidget(
      LocaleScope(
        controller: localeController,
        child: MaterialApp(
          theme: AppTheme.dark,
          locale: localeController.locale,
          localizationsDelegates: const [
            AppStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ur'),
          ],
          home: const SplashScreen(),
        ),
      ),
    );

    expect(find.text('Agro Guardian'), findsOneWidget);
  });
}
