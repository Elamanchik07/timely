import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import 'notification_settings_provider.dart';

const _kLanguageKey = 'app_language';

final localeProvider = StateNotifierProvider<LocaleNotifier, AppLanguage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

/// Convenience provider for getting localized strings anywhere
final l10nProvider = Provider<AppLocalizations>((ref) {
  final lang = ref.watch(localeProvider);
  return AppLocalizations(lang);
});

class LocaleNotifier extends StateNotifier<AppLanguage> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(AppLanguage.ru) {
    _load();
  }

  void _load() {
    final stored = _prefs.getString(_kLanguageKey);
    if (stored != null) {
      state = AppLanguage.values.firstWhere(
        (l) => l.name == stored,
        orElse: () => AppLanguage.ru,
      );
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    state = lang;
    await _prefs.setString(_kLanguageKey, lang.name);
  }
}
