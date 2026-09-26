import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Full-screen launch screen, shown while the router resolves auth state
/// (and for a minimum time — see `splashTimerProvider`). Redirection itself
/// is handled by the router, not this widget.
///
/// The first frame matches the native splash (white, logo centred at
/// 240dp — see `flutter_native_splash` in pubspec.yaml), so the hand-off
/// is seamless; the intro animation then builds on top of it.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Logo size; must match the native splash image (960px @4x).
  static const logoSize = 240.0;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
    ..forward();
  late final _loop = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat();

  @override
  void initState() {
    super.initState();
    // Truly full screen: hide the status and navigation bars.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  Animation<double> _interval(double begin, double end, [Curve curve = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _intro, curve: Interval(begin, end, curve: curve));

  @override
  Widget build(BuildContext context) {
    final blobs = _interval(0, 0.7);
    final tagline = _interval(0.35, 0.8);
    final footer = _interval(0.55, 1);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Soft brand-coloured glows drifting in from the corners.
          _Glow(
            animation: blobs,
            alignment: Alignment.topRight,
            offset: const Offset(0.35, -0.3),
            size: size.width * 1.1,
            color: AppColors.teal,
          ),
          _Glow(
            animation: blobs,
            alignment: Alignment.bottomLeft,
            offset: const Offset(-0.4, 0.3),
            size: size.width * 1.2,
            color: AppColors.blue,
          ),

          // Logo, exactly centred like the native splash, gently breathing.
          Center(
            child: AnimatedBuilder(
              animation: _loop,
              builder: (_, child) {
                final t = Curves.easeInOut.transform((_loop.value * 2 - 1).abs());
                return Transform.scale(scale: 1 + 0.03 * blobs.value * (1 - t), child: child);
              },
              child: Image.asset(
                'assets/images/app_logo.png',
                width: SplashScreen.logoSize,
                height: SplashScreen.logoSize,
                semanticLabel: 'PetCare',
              ),
            ),
          ),

          // Tagline, just below the logo.
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: SplashScreen.logoSize + 40),
              child: _FadeUp(
                animation: tagline,
                child: Text(
                  'Healthy pets, happy homes',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.navy.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                ),
              ),
            ),
          ),

          // Loading bar and caption at the bottom.
          Positioned(
            left: 0,
            right: 0,
            bottom: 56 + MediaQuery.paddingOf(context).bottom,
            child: _FadeUp(
              animation: footer,
              child: Column(
                children: [
                  _GradientLoader(animation: _loop),
                  const SizedBox(height: 14),
                  Text(
                    'Caring for your companions…',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.navy.withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FadeUp extends StatelessWidget {
  const _FadeUp({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(animation),
          child: child,
        ),
      );
}

/// Large, soft radial glow in one corner.
class _Glow extends StatelessWidget {
  const _Glow({
    required this.animation,
    required this.alignment,
    required this.offset,
    required this.size,
    required this.color,
  });

  final Animation<double> animation;
  final Alignment alignment;
  final Offset offset;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.6, end: 1.0).animate(animation),
          child: FractionalTranslation(
            translation: offset,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded track with a brand-gradient segment sweeping across it.
class _GradientLoader extends StatelessWidget {
  const _GradientLoader({required this.animation});

  final Animation<double> animation;

  static const _width = 140.0;
  static const _segment = 56.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, _) {
          final x = Curves.easeInOut.transform(animation.value) * (_width + _segment) - _segment;
          return Stack(
            children: [
              Positioned(
                left: x,
                top: 0,
                bottom: 0,
                width: _segment,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
