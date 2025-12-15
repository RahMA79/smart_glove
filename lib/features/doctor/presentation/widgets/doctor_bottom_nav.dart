import 'package:flutter/material.dart';

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

    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.only(top: 6),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onChanged,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.cardColor,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.55),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, size: 34),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            label: "Inbox",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
