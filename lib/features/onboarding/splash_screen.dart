import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/routes.dart';
import '../../core/session/session.dart';
import '../../core/settings/app_settings.dart';
import '../../data/data.dart';
import '../../shared/widgets/widgets.dart';
import '../accounts/sync_controller.dart';

/// 01 Splash — animated mark, then routes: first run → onboarding; no
/// accounts → add; default + "open on launch" → home; else Profiles.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  // ox-logo 1200 ms; tagline rises at 500 ms; loader fades in at 900 ms.
  late final _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..forward();
  late final _progress = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void initState() {
    super.initState();
    unawaited(_route());
  }

  Future<void> _route() async {
    final minimum = Future<void>.delayed(const Duration(milliseconds: 1700));
    unawaited(_progress.animateTo(0.64, curve: OxMotion.easeOut));
    final target = await ref.read(sessionProvider).launchTarget();
    // Straight into Home: refresh a stale catalog / guide in the background
    // (Settings › Auto-update playlist, EPG refresh interval).
    if (target == LaunchTarget.home) {
      final sync = ref.read(syncControllerProvider.notifier);
      final id = ref.read(appSettingsProvider).activeAccountId;
      final account = id == null ? null : await ref.read(accountRepositoryProvider).byId(id);
      if (account != null) unawaited(sync.refreshIfStale(account));
    }
    await minimum;
    await _progress.animateTo(1, duration: OxMotion.slow);
    if (!mounted) return;
    context.go(switch (target) {
      LaunchTarget.onboarding => Routes.welcome,
      LaunchTarget.addAccount => Routes.addAccount,
      LaunchTarget.profiles => Routes.accounts,
      LaunchTarget.home => Routes.start(ref.read(appSettingsProvider).startScreen),
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _progress.dispose();
    super.dispose();
  }

  Animation<double> _interval(double begin, double end) =>
      CurvedAnimation(parent: _intro, curve: Interval(begin / 1800, end / 1800, curve: OxMotion.easeOut));

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final reduce = context.reduceMotion;
    final logo = _interval(0, 1200);
    final rise = _interval(500, 1400);
    final fade = _interval(900, 1500);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.08),
            radius: 1.0,
            colors: [Color(0xFF1A0E0A), OxColors.ink1, OxColors.ink0],
            stops: [0, 0.55, 1],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final cy = c.maxHeight * 0.47;
            return Stack(
              children: [
                OxAmbient(color: OxColors.ember, size: const Size.square(360), opacity: 0.22, left: c.maxWidth / 2 - 180, top: cy - 180),
                OxAmbient(color: OxColors.halo, size: const Size.square(260), opacity: 0.08, left: c.maxWidth / 2 - 6, top: cy + 90),
                Positioned(left: c.maxWidth / 2 - 310, top: cy - 105, width: 620, height: 210, child: const _Orbit(color: Color(0x0FFFFFFF))),
                Positioned(left: c.maxWidth / 2 - 235, top: cy - 75, width: 470, height: 150, child: const _Orbit(color: Color(0x24FF7A3D))),
                Positioned(
                  left: 0,
                  right: 0,
                  top: cy - 100,
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: logo,
                        builder: (context, child) {
                          final v = logo.value;
                          if (reduce) return Opacity(opacity: v, child: child);
                          // ox-logo: scale .6 → 1, rotate −90° → 0, blur 8 → 0 (by 60 %).
                          return Opacity(
                            opacity: (v / 0.6).clamp(0, 1),
                            child: Transform.rotate(
                              angle: -math.pi / 2 * (1 - v),
                              child: Transform.scale(scale: 0.6 + 0.4 * v, child: child),
                            ),
                          );
                        },
                        child: const OxLogoMark(size: 112, orbiting: true, orbitPeriod: Duration(seconds: 5), glow: true),
                      ),
                      const SizedBox(height: 30),
                      AnimatedBuilder(
                        animation: rise,
                        builder: (context, child) => Opacity(
                          opacity: rise.value,
                          child: Transform.translate(offset: Offset(0, reduce ? 0 : 14 * (1 - rise.value)), child: child),
                        ),
                        child: Column(
                          spacing: 10,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 40 * 0.22),
                              child: OxWordmark(fontSize: 40, tracking: 0.22),
                            ),
                            Text(l.splashTagline, style: t.title.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: OxColors.text2, letterSpacing: t.isArabic ? 0 : 0.28)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 64,
                  right: 64,
                  bottom: 120,
                  child: FadeTransition(
                    opacity: fade,
                    child: Column(
                      spacing: 14,
                      children: [
                        AnimatedBuilder(
                          animation: _progress,
                          builder: (context, _) => _GlowBar(value: _progress.value),
                        ),
                        Text(l.splashLoading, style: t.caption),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 32,
                  right: 32,
                  bottom: 40 + MediaQuery.paddingOf(context).bottom * 0.5,
                  child: Text(
                    l.playerOnlyNotice,
                    textAlign: TextAlign.center,
                    style: t.caption.copyWith(fontSize: 11, height: 1.5),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Tilted orbit ellipse (−18°).
class _Orbit extends StatelessWidget {
  const _Orbit({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: -18 * math.pi / 180,
        child: DecoratedBox(decoration: ShapeDecoration(shape: OvalBorder(side: BorderSide(color: color)))),
      );
}

/// Splash progress: ember gradient fill with glow.
class _GlowBar extends StatelessWidget {
  const _GlowBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: BoxDecoration(color: const Color(0x1AFFFFFF), borderRadius: BorderRadius.circular(3)),
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: const LinearGradient(colors: [Color(0x33FF7A3D), OxColors.ember]),
            boxShadow: const [BoxShadow(color: Color(0xCCFF7A3D), blurRadius: 12)],
          ),
        ),
      ),
    );
  }
}
