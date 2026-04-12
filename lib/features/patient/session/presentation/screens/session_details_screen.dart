import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'session_screen.dart';

class SessionDetailsScreen extends StatelessWidget {
  final String sessionTitle;
  final String description;
  final int durationMinutes;
  final String injuryType;
  final List<String> exercises;

  const SessionDetailsScreen({
    super.key,
    required this.sessionTitle,
    required this.description,
    required this.durationMinutes,
    this.injuryType = 'Stroke',
    this.exercises = const [],
  });

  String _getDifficulty(BuildContext context) {
    if (durationMinutes >= 30) return context.tr('Moderate');
    return context.tr('Gentle');
  }

  Color _getDifficultyColor() {
    if (durationMinutes >= 30) return const Color(0xFFFF7043);
    return const Color(0xFF00BFA5);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final hPad = (SizeConfig.blockWidth * 5).clamp(16.0, 26.0);
    final vPad = (SizeConfig.blockHeight * 2.5).clamp(14.0, 22.0);
    final difficulty = _getDifficulty(context);
    final diffColor = _getDifficultyColor();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ──────────────────────────────────
          SliverAppBar(
            leading: BackButton(
              onPressed: () => Navigator.pop(context),
              color: Colors.white,
            ),
            expandedHeight: 140,
            pinned: true,
            backgroundColor: cs.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.primary.withOpacity(0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 48, hPad, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            difficulty,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sessionTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Chips row ──────────────────────────────────
                Wrap(
                  spacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.timer_rounded,
                      label: '$durationMinutes min',
                      color: cs.primary.withOpacity(0.10),
                      textColor: cs.onSurface,
                    ),
                    _InfoChip(
                      icon: Icons.fitness_center_rounded,
                      label:
                          '${exercises.isEmpty ? 5 : exercises.length} ${context.tr("Exercises")}',
                      color: const Color(0xFF00BFA5).withOpacity(0.10),
                      textColor: cs.onSurface,
                    ),
                    _InfoChip(
                      icon: Icons.trending_up_rounded,
                      label: difficulty,
                      color: diffColor.withOpacity(0.12),
                      textColor: diffColor,
                    ),
                  ],
                ),

                SizedBox(height: SizeConfig.blockHeight * 2.5),

                // ── About section ──────────────────────────────
                Text(
                  context.tr('About this session'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(
                        isDark ? 0.18 : 0.12,
                      ),
                    ),
                  ),
                  child: Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: cs.onSurface.withOpacity(0.80),
                    ),
                  ),
                ),

                SizedBox(height: SizeConfig.blockHeight * 2.5),

                // ── Session steps ──────────────────────────────
                if (exercises.isNotEmpty) ...[
                  Text(
                    context.tr('Session Steps'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(
                          isDark ? 0.18 : 0.10,
                        ),
                      ),
                    ),
                    child: Column(
                      children: exercises.asMap().entries.map((e) {
                        final isLast = e.key == exercises.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: cs.primary.withOpacity(0.10),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${e.key + 1}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: cs.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 20,
                                    color: cs.onSurface.withOpacity(0.30),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              Divider(
                                height: 1,
                                color: theme.dividerColor.withOpacity(0.10),
                                indent: 56,
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 2),
                ],

                // ── Glove connection notice ────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(isDark ? 0.12 : 0.07),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.bluetooth_rounded,
                          color: cs.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('Glove Connection'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr(
                                'Ensure your Smart Glove is paired and charged before starting.',
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.60),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: SizeConfig.blockHeight * 2.5),

                // ── Start button ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SessionScreen(
                          title: sessionTitle,
                          durationMinutes: durationMinutes,
                          exercises: exercises,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      context.tr('Start Session'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.blockHeight * 2),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
