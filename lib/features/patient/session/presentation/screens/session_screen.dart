import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'feedback_screen.dart';

class SessionScreen extends StatefulWidget {
  final String title;
  final int durationMinutes;
  final List<String> exercises;

  const SessionScreen({
    super.key,
    required this.title,
    required this.durationMinutes,
    this.exercises = const [],
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  late int _totalSeconds;
  Timer? _timer;
  bool _paused = false;
  int _currentStep = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  List<String> get _steps => widget.exercises.isEmpty
      ? List.generate(5, (i) => 'Exercise ${i + 1}')
      : widget.exercises;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.durationMinutes * 60;
    _remainingSeconds = _totalSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_paused) return;
      if (_remainingSeconds <= 0) {
        t.cancel();
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => FeedbackScreen(
            sessionTitle: widget.title,
            exercisesCount: _steps.length,
            durationSeconds: _totalSeconds,
          ),
        ));
      } else {
        setState(() {
          _remainingSeconds--;
          // Advance step automatically based on time elapsed
          final elapsed = _totalSeconds - _remainingSeconds;
          final stepDuration = _totalSeconds ~/ _steps.length;
          _currentStep = (elapsed ~/ stepDuration).clamp(0, _steps.length - 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    if (_totalSeconds == 0) return 0;
    return 1 - (_remainingSeconds / _totalSeconds);
  }

  void _onStopPressed() {
    _timer?.cancel();
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => FeedbackScreen(
        sessionTitle: widget.title,
        exercisesCount: _currentStep + 1,
        durationSeconds: _totalSeconds - _remainingSeconds,
      ),
    ));
  }

  void _onSkipPressed() {
    setState(() {
      if (_currentStep < _steps.length - 1) {
        _currentStep++;
        final stepDuration = _totalSeconds ~/ _steps.length;
        _remainingSeconds = ((_steps.length - 1 - _currentStep) * stepDuration)
            .clamp(0, _totalSeconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final circleSize = (SizeConfig.blockWidth * 60).clamp(200.0, 280.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _steps.length,
            backgroundColor: cs.primary.withOpacity(0.15),
            color: cs.primary,
            minHeight: 3,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: (SizeConfig.blockWidth * 5).clamp(16.0, 28.0),
          vertical: (SizeConfig.blockHeight * 2).clamp(12.0, 20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Step label ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_steps[_currentStep],
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900, letterSpacing: -0.2)),
                Text('Step ${_currentStep + 1} of ${_steps.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.55))),
              ],
            ),
            const SizedBox(height: 4),
            Text(context.tr('Keep going until the timer ends.'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.60))),

            SizedBox(height: SizeConfig.blockHeight * 2.5),

            // ── Timer card ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: theme.dividerColor.withOpacity(isDark ? 0.20 : 0.14)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.12 : 0.06),
                    blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: Column(
                children: [
                  // Animated circular timer
                  ScaleTransition(
                    scale: _paused ? const AlwaysStoppedAnimation(1.0) : _pulseAnim,
                    child: SizedBox(
                      width: circleSize,
                      height: circleSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: Size(circleSize, circleSize),
                            painter: _CircleTimerPainter(
                              progress: _progress,
                              progressColor: cs.primary,
                              bgColor: cs.primary.withOpacity(isDark ? 0.12 : 0.10),
                              strokeWidth: 14,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_formatTime(_remainingSeconds),
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w900, letterSpacing: -1)),
                              const SizedBox(height: 4),
                              Text(context.tr('Remaining'),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurface.withOpacity(0.55),
                                    fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.tr('Total'),
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                        Text(context.tr('{count} min', params: {'count': '${widget.durationMinutes}'}),
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Control buttons ─────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _paused = !_paused),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: cs.outline.withOpacity(0.40)),
                    ),
                    child: Text(_paused ? context.tr('Resume') : context.tr('Pause'),
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _onSkipPressed,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: cs.outline.withOpacity(0.40)),
                    ),
                    child: Text(context.tr('Skip'),
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onStopPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(context.tr('Stop'),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),
          ],
        ),
      ),
    );
  }
}

// ── Custom circular timer painter ─────────────────────────────────────────
class _CircleTimerPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color bgColor;
  final double strokeWidth;

  _CircleTimerPainter({
    required this.progress,
    required this.progressColor,
    required this.bgColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final fgPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleTimerPainter old) =>
      old.progress != progress;
}
