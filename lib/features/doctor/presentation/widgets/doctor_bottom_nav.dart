import 'package:flutter/material.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';

class DoctorBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const DoctorBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
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
        onTap: onChanged,
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
            icon: const Icon(Icons.add_outlined),
            activeIcon: const Icon(Icons.add_rounded),
            label: context.tr('Add'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.mail_outline),
            activeIcon: const Icon(Icons.mail_rounded),
            label: context.tr('Inbox'),
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
