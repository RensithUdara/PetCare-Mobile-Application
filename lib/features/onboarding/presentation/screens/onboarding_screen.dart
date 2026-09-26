import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/onboarding_controller.dart';
import '../../../../core/theme/app_colors.dart';

class _OnboardingPage {
  const _OnboardingPage(this.icon, this.title, this.body, this.accent);
  final IconData icon;
  final String title;
  final String body;
  final FeatureAccent accent;
}

const _pages = [
  _OnboardingPage(Icons.pets, 'Manage Your Pets',
      "Keep all your pets' information in one place.", FeatureAccent.pets),
  _OnboardingPage(Icons.vaccines, 'Never Miss a Vaccination',
      'Get reminders before important vaccinations are due.', FeatureAccent.vaccinations),
  _OnboardingPage(Icons.event_available, 'Track Vet Appointments',
      'Manage upcoming veterinary visits.', FeatureAccent.appointments),
  _OnboardingPage(Icons.folder_shared, 'Keep Medical Records Safe',
      'Store important documents digitally.', FeatureAccent.documents),
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
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
              child: TextButton(
                onPressed: _isLast ? null : _finish,
                child: Text(_isLast ? '' : 'Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: page.accent.color.withValues(alpha: 0.12),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: page.accent.gradient,
                              boxShadow: [
                                BoxShadow(
                                  color: page.accent.color.withValues(alpha: 0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Icon(page.icon, size: 72, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.body,
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(color: scheme.onSurfaceVariant),
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
