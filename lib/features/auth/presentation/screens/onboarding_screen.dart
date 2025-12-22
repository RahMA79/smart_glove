import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      imagePath: 'assets/images/onboarding1.png',
      title: 'Track Your Recovery Easily',
      subtitle: 'Monitor exercises with real-time progress.',
      accent: Color(0xFF2B6DFF),
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboarding2.png',
      title: 'Smart AI-Based Insights',
      subtitle: 'AI analyzes activity and guides recovery.',
      accent: Color(0xFF6E56FF),
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboarding3.png',
      title: 'Personalized Therapy Programs',
      subtitle: 'Custom programs based on your condition.',
      accent: Color(0xFF18A0FB),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _pages.length - 1;

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _onNext() {
    if (_isLast) return _goToLogin();
    _controller.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _onSkip() => _goToLogin();

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgTop = isDark ? const Color(0xFF070B16) : const Color(0xFFF7F9FB);
    final bgBottom = isDark ? const Color(0xFF0B1020) : const Color(0xFFEFF4FF);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (SizeConfig.blockWidth * 6).clamp(16.0, 28.0),
              vertical: (SizeConfig.blockHeight * 2).clamp(10.0, 20.0),
            ),
            child: Column(
              children: [
                // Top bar (Back / Skip)
                Row(
                  children: [
                    _TopIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () {
                        if (_index == 0) {
                          Navigator.pop(context);
                        } else {
                          _controller.previousPage(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.85),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Skip'),
                    ),
                  ],
                ),

                SizedBox(height: SizeConfig.blockHeight * 1.5),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (_, i) => OnboardingCard(data: _pages[i]),
                  ),
                ),

                SizedBox(height: SizeConfig.blockHeight * 2),

                // Indicator
                SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3,
                    activeDotColor: _pages[_index].accent,
                    dotColor: theme.dividerColor.withOpacity(0.35),
                  ),
                ),

                SizedBox(height: SizeConfig.blockHeight * 3),

                // Bottom CTA
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: _pages[_index].accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(_isLast ? 'Get Started' : 'Next'),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: SizeConfig.blockHeight * 1.2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingCard extends StatelessWidget {
  final _OnboardingData data;

  const OnboardingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final imageHeight = (SizeConfig.blockHeight * 34).clamp(220.0, 360.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hero image with soft glow (بدون مربع)
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: imageHeight,
              height: imageHeight,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: data.accent.withOpacity(isDark ? 0.22 : 0.18),
                    blurRadius: 60,
                    spreadRadius: 12,
                  ),
                ],
              ),
            ),
            Image.asset(
              data.imagePath,
              height: imageHeight,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              isAntiAlias: true,
            ),
          ],
        ),

        SizedBox(height: SizeConfig.blockHeight * 4),

        Text(
          data.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),

        SizedBox(height: SizeConfig.blockHeight * 1.6),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.80),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface.withOpacity(0.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: theme.colorScheme.surface.withOpacity(0.30),
            border: Border.all(color: theme.dividerColor.withOpacity(0.18)),
          ),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String imagePath;
  final String title;
  final String subtitle;
  final Color accent;

  const _OnboardingData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.accent,
  });
}
