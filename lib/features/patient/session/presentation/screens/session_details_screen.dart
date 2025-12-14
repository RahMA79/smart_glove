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

    return Scaffold(
      appBar: AppBar(title: Text(sessionTitle)),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 5,
          vertical: SizeConfig.blockHeight * 2.5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sessionTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 1.6),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      theme.brightness == Brightness.dark ? 0.12 : 0.06,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.4,
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.85),
                ),
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 2.2),

            Row(
              children: [
                Icon(Icons.timer, color: theme.colorScheme.primary),
                SizedBox(width: SizeConfig.blockWidth * 2.5),
                Text(
                  "$durationMinutes min",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const Spacer(),

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
