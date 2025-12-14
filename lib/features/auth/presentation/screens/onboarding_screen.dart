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
      imagePath: 'assets/images/i1.jpg',
      title: 'Track Your Recovery Easily',
      subtitle: 'Monitor exercises with real-time progress.',
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboardin2.png',
      title: 'Smart AI-Based Insights',
      subtitle: 'AI analyzes activity and guides recovery.',
    ),
    _OnboardingData(
      imagePath: 'assets/images/bord.jpg',
      title: 'Personalized Therapy Programs',
      subtitle: 'Custom programs based on your condition.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _pages.length - 1;

  void _onNext() {
    if (_isLast) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_index == 0) {
              Navigator.pop(context);
            } else {
              _controller.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 6,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => OnboardingCard(data: _pages[i]),
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 2),

            SmoothPageIndicator(
              controller: _controller,
              count: _pages.length,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3,
                activeDotColor: theme.colorScheme.primary,
                dotColor: theme.dividerColor.withOpacity(0.4),
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(_isLast ? 'Get Started' : 'Next'),
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 2),
          ],
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          data.imagePath,
          height: SizeConfig.blockHeight * 28,
          fit: BoxFit.contain,
        ),
        SizedBox(height: SizeConfig.blockHeight * 4),

        Text(
          data.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        SizedBox(height: SizeConfig.blockHeight * 1.5),

        Text(
          data.subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
        ),
      ],
    );
  }
}

class _OnboardingData {
  final String imagePath;
  final String title;
  final String subtitle;

  const _OnboardingData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}
