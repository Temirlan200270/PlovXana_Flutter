import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/user_prefs.dart';

const String kLocalePrefKey = 'app_locale';

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._prefs) : super(_loadInitial(_prefs));

  final SharedPreferences _prefs;

  static Locale _loadInitial(SharedPreferences prefs) {
    final code = prefs.getString(kLocalePrefKey);
    if (code == 'kk') return const Locale('kk');
    return const Locale('ru');
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'ru' && locale.languageCode != 'kk') return;
    await _prefs.setString(kLocalePrefKey, locale.languageCode);
    state = locale;
  }

  String get languageCode => state.languageCode;
}
