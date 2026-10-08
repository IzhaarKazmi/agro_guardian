import 'package:agro_guardian/firebase_options.dart';
import 'package:agro_guardian/l10n/app_strings.dart';
import 'package:agro_guardian/l10n/locale_controller.dart';
import 'package:agro_guardian/l10n/locale_scope.dart';
import 'package:agro_guardian/login_page.dart';
import 'package:agro_guardian/signup_page.dart';
import 'package:agro_guardian/splash_screen.dart';
import 'package:agro_guardian/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  final localeController = LocaleController();
  await localeController.load();

  runApp(MyApp(localeController: localeController));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.localeController});

  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: localeController,
      child: ListenableBuilder(
        listenable: localeController,
        builder: (context, _) {
          return MaterialApp(
            title: 'Agro Guardian',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            themeMode: ThemeMode.dark,
            locale: localeController.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ur'),
            ],
            localizationsDelegates: const [
              AppStringsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: localeController.textDirection,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginPage(),
              '/signup': (context) => const SignupPage(),
            },
          );
        },
      ),
    );
  }
}
