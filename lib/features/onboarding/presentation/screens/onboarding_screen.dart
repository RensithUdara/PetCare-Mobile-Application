import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../providers/onboarding_controller.dart';

class _OnboardingPage {
  const _OnboardingPage(this.image, this.icon, this.title, this.body, this.accent);

  /// Illustration under `assets/onboard/clean/` (transparent background).
  final String image;
  final IconData icon;
  final String title;
  final String body;
  final FeatureAccent accent;
}

const _pages = [
  _OnboardingPage(
    'pets',
    Icons.pets,
    'Manage Your Pets',
    "Keep all your pets' information in one place.",
    FeatureAccent.pets,
  ),
  _OnboardingPage(
    'vaccinations',
    Icons.vaccines,
    'Never Miss a Vaccination',
    'Get reminders before important vaccinations are due.',
    FeatureAccent.vaccinations,
  ),
  _OnboardingPage(
    'appointments',
    Icons.event_available,
    'Track Vet Appointments',
    'Manage upcoming veterinary visits.',
    FeatureAccent.appointments,
  ),
  _OnboardingPage(
    'records',
    Icons.folder_shared,
    'Keep Medical Records Safe',
    'Store important documents digitally.',
    FeatureAccent.documents,
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The router listens to onboarding state and redirects automatically.
  void _finish() => ref.read(onboardingCompleteProvider.notifier).complete();

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _isLast ? null : _finish, child: Text(_isLast ? '' : 'Skip')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(child: _Illustration(page: page)),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.body,
                          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index ? _pages[_index].accent.color : scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _pages[_index].accent.color,
                  shadowColor: _pages[_index].accent.color.withValues(alpha: 0.5),
                ),
                onPressed: _next,
                child: Text(_isLast ? 'Get Started' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The page's picture on a soft accent-tinted card, with the feature icon
/// floating on its corner.
class _Illustration extends StatelessWidget {
  const _Illustration({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final color = page.accent.color;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420, maxHeight: 360),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withValues(alpha: 0.10), color.withValues(alpha: 0.24)],
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      top: -40,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Image.asset(
                          'assets/onboard/clean/${page.image}.png',
                          fit: BoxFit.contain,
                          semanticLabel: page.title,
                          errorBuilder: (_, _, _) => Icon(page.icon, size: 96, color: color),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: -18,
              child: IconBadge(icon: page.icon, accent: page.accent, size: 52),
            ),
          ],
        ),
      ),
    );
  }
}
