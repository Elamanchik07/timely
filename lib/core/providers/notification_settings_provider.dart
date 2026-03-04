import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationSettings {
  final bool isEnabled;
  final List<int> intervalsMinutes; // [5, 15, 60] means 5 mins, 15 mins, 1 hr before
  final bool dndEnabled;
  final int dndStartHour; // 0-23
  final int dndEndHour;   // 0-23

  const NotificationSettings({
    this.isEnabled = true,
    this.intervalsMinutes = const [5],
    this.dndEnabled = true,
    this.dndStartHour = 22, // 10 PM
    this.dndEndHour = 7,    // 7 AM
  });

  NotificationSettings copyWith({
    bool? isEnabled,
    List<int>? intervalsMinutes,
    bool? dndEnabled,
    int? dndStartHour,
    int? dndEndHour,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      intervalsMinutes: intervalsMinutes ?? this.intervalsMinutes,
      dndEnabled: dndEnabled ?? this.dndEnabled,
      dndStartHour: dndStartHour ?? this.dndStartHour,
      dndEndHour: dndEndHour ?? this.dndEndHour,
    );
  }

  Map<String, dynamic> toJson() => {
    'isEnabled': isEnabled,
    'intervalsMinutes': intervalsMinutes,
    'dndEnabled': dndEnabled,
    'dndStartHour': dndStartHour,
    'dndEndHour': dndEndHour,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      isEnabled: json['isEnabled'] as bool? ?? true,
      intervalsMinutes: (json['intervalsMinutes'] as List<dynamic>?)?.cast<int>() ?? [5],
      dndEnabled: json['dndEnabled'] as bool? ?? true,
      dndStartHour: json['dndStartHour'] as int? ?? 22,
      dndEndHour: json['dndEndHour'] as int? ?? 7,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final SharedPreferences _prefs;

  NotificationSettingsNotifier(this._prefs) : super(const NotificationSettings()) {
    _load();
  }

  void _load() {
    final str = _prefs.getString('notification_settings');
    if (str != null) {
      try {
        state = NotificationSettings.fromJson(jsonDecode(str));
      } catch (e) {
        // Fallback to default
      }
    }
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    state = newSettings;
    await _prefs.setString('notification_settings', jsonEncode(newSettings.toJson()));
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in main.dart');
});

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationSettingsNotifier(prefs);
});
