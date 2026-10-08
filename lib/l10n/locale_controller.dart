import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const _prefsKey = 'app_locale';

  Locale _locale = const Locale('en');
  bool _loaded = false;

  Locale get locale => _locale;

  bool get isUrdu => _locale.languageCode == 'ur';

  bool get isLoaded => _loaded;

  TextDirection get textDirection =>
      isUrdu ? TextDirection.rtl : TextDirection.ltr;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == 'ur') {
      _locale = const Locale('ur');
    } else {
      _locale = const Locale('en');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }

  Future<void> setEnglish() => setLocale(const Locale('en'));

  Future<void> setUrdu() => setLocale(const Locale('ur'));
}
