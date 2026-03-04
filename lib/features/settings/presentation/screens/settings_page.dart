import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/notification_settings_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/language_selector.dart';
import '../../../../core/providers/biometric_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../notification_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 0. Language Selection
          _buildSectionHeader(l10n.currentLanguage.displayName),
          _buildSettingsCard(
            context: context,
            child: ListTile(
              leading: const Icon(Icons.language_rounded, color: AppTheme.accent),
              title: Text(l10n.currentLanguage.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const LanguageSelector(compact: false),
            ),
          ),
          const SizedBox(height: 16),

          // 1. Notification Settings
          _buildSectionHeader(l10n.notificationsAboutClasses),
          SwitchListTile(
            title: Text(l10n.enableNotifications, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(l10n.reminderBeforeClass),
            value: settings.isEnabled,
            activeColor: AppTheme.accent,
            onChanged: (val) async {
              final notifier = ref.read(notificationSettingsProvider.notifier);
              await notifier.updateSettings(settings.copyWith(isEnabled: val));
              if (val) {
                 await NotificationService().requestPermissions();
              }
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Theme.of(context).cardColor,
          ),
          const SizedBox(height: 8),

          if (settings.isEnabled) ...[
            _buildSettingsCard(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(l10n.howLongBefore, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const Divider(height: 1),
                  _buildIntervalCheckbox(ref, settings, l10n, 5, l10n.minutesBefore(5)),
                  _buildIntervalCheckbox(ref, settings, l10n, 15, l10n.minutesBefore(15)),
                  _buildIntervalCheckbox(ref, settings, l10n, 30, l10n.minutesBefore(30)),
                  _buildIntervalCheckbox(ref, settings, l10n, 60, l10n.hoursBefore(1)),
                  _buildIntervalCheckbox(ref, settings, l10n, 120, l10n.hoursBefore(2)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // DND Settings
            _buildSectionHeader(l10n.quietHours),
            _buildSettingsCard(
              context: context,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.doNotDisturbAtNight, style: const TextStyle(fontWeight: FontWeight.w500)),
                    value: settings.dndEnabled,
                    activeColor: AppTheme.accent,
                    onChanged: (val) {
                      ref.read(notificationSettingsProvider.notifier)
                         .updateSettings(settings.copyWith(dndEnabled: val));
                    },
                  ),
                  if (settings.dndEnabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      title: Text(l10n.startHour),
                      trailing: Text('${settings.dndStartHour}:00', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 16)),
                      onTap: () => _selectDndHour(context, ref, settings, true),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: Text(l10n.endHour),
                      trailing: Text('${settings.dndEndHour}:00', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 16)),
                      onTap: () => _selectDndHour(context, ref, settings, false),
                    ),
                  ],
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),

          // 2. Security
          _buildSectionHeader(l10n.security),
          _buildSettingsCard(
            context: context,
            child: FutureBuilder<bool>(
              future: ref.read(biometricServiceProvider).isBiometricAvailable(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  final biometricEnabled = ref.watch(biometricEnabledProvider);
                  return SwitchListTile(
                    title: Text(l10n.useBiometrics, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n.biometricSubtitle),
                    value: biometricEnabled,
                    activeColor: AppTheme.accent,
                    onChanged: (val) => ref.read(biometricEnabledProvider.notifier).setEnabled(val),
                    secondary: const Icon(Icons.fingerprint_rounded, color: AppTheme.accent),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 4. Cache / Data
          _buildSectionHeader(l10n.data),
          _buildSettingsCard(
            context: context,
            child: ListTile(
              leading: const Icon(Icons.delete_sweep_rounded, color: AppTheme.accent),
              title: Text(l10n.clearCache),
              subtitle: Text(l10n.clearCacheSubtitle),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.cacheCleared),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),

          // 3. Info & Support
          _buildSectionHeader(l10n.support),
          _buildSettingsCard(
            context: context,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_center_rounded, color: AppTheme.accent),
                  title: Text(l10n.helpAndFaq),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => context.push('/help-faq'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.policy_rounded, color: AppTheme.accent),
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => context.push('/privacy-policy'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Danger zone
          _buildSettingsCard(
            context: context,
            child: ListTile(
              leading: Icon(Icons.logout_rounded, color: AppTheme.errorColor),
              title: Text(l10n.logoutFromAccount, style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w600)),
              onTap: () => _confirmLogout(context, ref, l10n),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required BuildContext context, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }

  Widget _buildIntervalCheckbox(WidgetRef ref, NotificationSettings settings, AppLocalizations l10n, int minutes, String label) {
    final isChecked = settings.intervalsMinutes.contains(minutes);
    return CheckboxListTile(
      title: Text(label),
      value: isChecked,
      activeColor: AppTheme.accent,
      onChanged: (val) {
        final List<int> newIntervals = List.from(settings.intervalsMinutes);
        if (val == true) {
          if (!newIntervals.contains(minutes)) newIntervals.add(minutes);
        } else {
          newIntervals.remove(minutes);
        }
        newIntervals.sort();
        ref.read(notificationSettingsProvider.notifier)
           .updateSettings(settings.copyWith(intervalsMinutes: newIntervals));
      },
    );
  }

  Future<void> _selectDndHour(BuildContext context, WidgetRef ref, NotificationSettings settings, bool isStart) async {
    final initialHour = isStart ? settings.dndStartHour : settings.dndEndHour;
    
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      }
    );

    if (selectedTime != null) {
      final hour = selectedTime.hour;
      final notifier = ref.read(notificationSettingsProvider.notifier);
      if (isStart) {
        notifier.updateSettings(settings.copyWith(dndStartHour: hour));
      } else {
        notifier.updateSettings(settings.copyWith(dndEndHour: hour));
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmBody),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.logout, style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        GoRouter.of(context).go('/login');
      }
    }
  }
}
