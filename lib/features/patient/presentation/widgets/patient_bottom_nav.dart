import 'package:flutter/material.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';

class PatientBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PatientBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        elevation: 5,
        backgroundColor: theme.scaffoldBackgroundColor,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurface.withOpacity(0.55),

        selectedLabelStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),

        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: context.tr('Home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.timer_outlined),
            activeIcon: const Icon(Icons.timer_rounded),
            label: context.tr('Sessions'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add),
            activeIcon: const Icon(Icons.add_rounded),
            label: context.tr('Request doctor'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings_rounded),
            label: context.tr('Settings'),
          ),
        ],
      ),
    );
  }
}
