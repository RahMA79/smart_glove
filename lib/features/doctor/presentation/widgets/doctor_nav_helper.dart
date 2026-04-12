import 'package:flutter/material.dart';

/// Fade-transition pushReplacement used by every doctor screen's bottom nav.
/// The actual target widget is passed in by the caller to avoid circular imports.
void doctorNavPush(BuildContext context, Widget target) {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => target,
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ),
  );
}
