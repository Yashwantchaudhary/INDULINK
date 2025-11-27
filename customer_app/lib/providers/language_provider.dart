import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

part 'language_provider.g.dart';

class LanguageState {
  final Locale locale;

  LanguageState({required this.locale});

  LanguageState copyWith({Locale? locale}) {
    return LanguageState(locale: locale ?? this.locale);
  }
}

@riverpod
class LanguageNotifier extends _$LanguageNotifier {
  static const String _languageKey = 'selected_language';

  @override
  Future<LanguageState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    final defaultLocale = Locale('en'); // Default to English

    if (languageCode != null) {
      final locale = Locale(languageCode);
      if (AppLocalizations.supportedLocales.contains(locale)) {
        return LanguageState(locale: locale);
      }
    }

    return LanguageState(locale: defaultLocale);
  }

  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  Future<void> changeLanguage(Locale locale) async {
    if (AppLocalizations.supportedLocales.contains(locale)) {
      state = AsyncData(LanguageState(locale: locale));
      await _saveLanguage(locale.languageCode);
    }
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'hi':
        return 'हिन्दी';
      case 'ne':
        return 'नेपाली';
      default:
        return languageCode.toUpperCase();
    }
  }

  String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'hi':
        return '🇮🇳';
      case 'ne':
        return '🇳🇵';
      default:
        return '🌍';
    }
  }
}
