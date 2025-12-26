import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';

import 'session_screen.dart';

class SessionDetailsScreen extends StatelessWidget {
  final String sessionTitle;
  final String description;
  final int durationMinutes;

  const SessionDetailsScreen({
    super.key,
    required this.sessionTitle,
    required this.description,
    required this.durationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final hPad = (SizeConfig.blockWidth * 5).clamp(16.0, 26.0);
    final vPad = (SizeConfig.blockHeight * 2.5).clamp(14.0, 22.0);

    return Scaffold(
      appBar: AppBar(title: Text(sessionTitle), centerTitle: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sessionTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 1.4),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(isDark ? 0.16 : 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_rounded, size: 18, color: cs.primary),
                      const SizedBox(width: 6),
                      Text(
                        "$durationMinutes min",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeConfig.blockHeight * 2.0),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(isDark ? 0.20 : 0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.12 : 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: cs.onSurface.withOpacity(0.80),
                ),
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            PrimaryButton(
              text: "Start Session",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SessionScreen(
                      title: sessionTitle,
                      durationMinutes: durationMinutes,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
