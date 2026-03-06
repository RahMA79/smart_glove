import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/core/localization/locale_notifier.dart';
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

  Future<void> _goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _onNext(int pagesCount) {
    final isLast = _index == pagesCount - 1;
    if (isLast) {
      _goToLogin();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _onSkip() => _goToLogin();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgTop = isDark ? const Color(0xFF070B16) : const Color(0xFFF7F9FB);
    final bgBottom = isDark ? const Color(0xFF0B1020) : const Color(0xFFEFF4FF);

    const pages = <_OnboardingData>[
      _OnboardingData(
        imagePath: 'assets/images/onboarding1.png',
        titleKey: 'onboarding_title_1',
        subtitleKey: 'onboarding_subtitle_1',
        accent: Color(0xFF2B6DFF),
      ),
      _OnboardingData(
        imagePath: 'assets/images/onboarding2.png',
        titleKey: 'onboarding_title_2',
        subtitleKey: 'onboarding_subtitle_2',
        accent: Color(0xFF6E56FF),
      ),
      _OnboardingData(
        imagePath: 'assets/images/onboarding3.png',
        titleKey: 'onboarding_title_3',
        subtitleKey: 'onboarding_subtitle_3',
        accent: Color(0xFF18A0FB),
      ),
    ];

    final safeIndex = _index.clamp(0, pages.length - 1);

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
                Row(
                  children: [
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
                      child: Text(context.tr('skip')),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: context.tr('language'),
                      icon: const Icon(Icons.language),
                      onPressed: () => context.read<LocaleNotifier>().toggle(),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.blockHeight * 1.5),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (_, i) => OnboardingCard(data: pages[i]),
                  ),
                ),
                SizedBox(height: SizeConfig.blockHeight * 2),
                SmoothPageIndicator(
                  controller: _controller,
                  count: pages.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3,
                    activeDotColor: pages[safeIndex].accent,
                    dotColor: theme.dividerColor.withOpacity(0.35),
                  ),
                ),
                SizedBox(height: SizeConfig.blockHeight * 3),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => _onNext(pages.length),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: pages[safeIndex].accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      safeIndex == pages.length - 1
                          ? context.tr('get_started')
                          : context.tr('next'),
                    ),
                  ),
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
          context.tr(data.titleKey),
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
            context.tr(data.subtitleKey),
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

class _OnboardingData {
  final String imagePath;
  final String titleKey;
  final String subtitleKey;
  final Color accent;

  const _OnboardingData({
    required this.imagePath,
    required this.titleKey,
    required this.subtitleKey,
    required this.accent,
  });
}
