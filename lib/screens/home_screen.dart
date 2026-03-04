import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/news/presentation/screens/news_feed_screen.dart';
import '../features/schedule/presentation/screens/schedule_page.dart';
import '../features/map/presentation/screens/map_page.dart';
import '../features/profile/presentation/screens/profile_page.dart';
import '../core/providers/navigation_providers.dart';
import '../core/providers/locale_provider.dart';
import '../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(homeTabProvider);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          NewsFeedScreen(),
          SchedulePage(),
          MapPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: _FloatingNavBar(
        selectedIndex: selectedIndex,
        onTap: (i) => ref.read(homeTabProvider.notifier).state = i,
        labels: [l10n.feed, l10n.schedule, l10n.map, l10n.profile],
      ),
    );
  }
}

/// Premium floating glassmorphism navigation bar.
class _FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<String> labels;

  const _FloatingNavBar({
    required this.selectedIndex,
    required this.onTap,
    required this.labels,
  });

  static const _icons = [
    _NavIconPair(Icons.newspaper_outlined, Icons.newspaper_rounded),
    _NavIconPair(Icons.calendar_today_outlined, Icons.calendar_today_rounded),
    _NavIconPair(Icons.map_outlined, Icons.map_rounded),
    _NavIconPair(Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        color: AppTheme.primaryMid.withOpacity(0.85),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_icons.length, (i) {
                  final iconPair = _icons[i];
                  final isActive = selectedIndex == i;
                  return _NavItem(
                    icon: iconPair.icon,
                    activeIcon: iconPair.activeIcon,
                    label: labels[i],
                    isActive: isActive,
                    onTap: () => onTap(i),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIconPair {
  final IconData icon;
  final IconData activeIcon;
  const _NavIconPair(this.icon, this.activeIcon);
}

/// Custom navigation bar item with animated indicator.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accent.withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive ? AppTheme.accent : AppTheme.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppTheme.accent : AppTheme.textSecondary,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
