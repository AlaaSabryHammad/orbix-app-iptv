import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/routes.dart';
import '../../core/settings/app_settings.dart';
import '../../shared/widgets/widgets.dart';

/// 02–04 Onboarding. Skip / Get started → Add account.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(appSettingsProvider.notifier).update((s) => s.copyWith(onboardingDone: true));
    if (mounted) context.go(Routes.addAccount);
  }

  void _go(int page) => _pages.animateToPage(page, duration: context.reduceMotion ? OxMotion.fast : OxMotion.slow, curve: OxMotion.easeOut);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final copy = [
      (l.onboarding1Title, l.onboarding1Body),
      (l.onboarding2Title, l.onboarding2Body),
      (l.onboarding3Title, l.onboarding3Body),
    ];
    const ambients = [
      [(OxColors.ember, 320.0, 320.0, 0.2, 46.0, 150.0), (OxColors.halo, 200.0, 200.0, 0.12, 220.0, 320.0)],
      [(Color(0xFF7A4BFF), 340.0, 300.0, 0.18, 36.0, 180.0), (OxColors.ember, 240.0, 240.0, 0.2, 150.0, 330.0)],
      [(OxColors.ember, 320.0, 320.0, 0.2, 50.0, 170.0), (OxColors.halo, 220.0, 220.0, 0.1, 10.0, 360.0)],
    ];
    final last = _page == 2;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          final dx = (c.maxWidth - 412) / 2;
          return Stack(
            children: [
              for (final (color, w, h, o, x, y) in ambients[_page])
                OxAmbient(color: color, size: Size(w, h), opacity: o, left: dx + x, top: y),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      children: [
                        // Top bar: logo on page 1, back afterwards; Skip.
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(20, 6, 12, 0),
                          child: SizedBox(
                            height: 44,
                            child: Row(
                              children: [
                                if (_page == 0)
                                  const OxBrandLockup()
                                else
                                  Transform.translate(
                                    offset: const Offset(-10, 0),
                                    child: OxIconButton(icon: OxIcons.back, semanticLabel: l.actionBack, onPressed: () => _go(_page - 1)),
                                  ),
                                const Spacer(),
                                _SkipButton(label: l.actionSkip, onPressed: _finish),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: PageView(
                            controller: _pages,
                            onPageChanged: (p) => setState(() => _page = p),
                            children: [
                              for (var i = 0; i < 3; i++)
                                Column(
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: SizedBox(width: 412, height: 480, child: [const _ArtConnect(), const _ArtLibrary(), const _ArtResume()][i]),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 14,
                                        children: [
                                          Text(t.overlineText(l.onboardingStep(i + 1, 3)), style: t.overline.copyWith(color: OxColors.emberHi)),
                                          Semantics(header: true, child: Text(copy[i].$1, style: t.display.copyWith(fontSize: 30))),
                                          Text(copy[i].$2, style: t.body.copyWith(fontSize: 15)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                          child: last
                              ? Column(
                                  spacing: 18,
                                  children: [
                                    _Dots(index: _page),
                                    OxButton(label: l.actionGetStarted, size: OxButtonSize.lg, expand: true, onPressed: _finish),
                                  ],
                                )
                              : Row(
                                  children: [
                                    _Dots(index: _page),
                                    const Spacer(),
                                    OxButton(label: l.actionNext, trailingIcon: OxIcons.chevR, onPressed: () => _go(_page + 1)),
                                  ],
                                ),
                        ),
                      ],
                    ),
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

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OxPressable(
        onTap: onPressed,
        child: Container(
          height: OxSize.buttonSm,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Text(label, style: context.oxText.title.copyWith(fontSize: 13.5, fontWeight: FontWeight.w800, color: OxColors.text2)),
        ),
      );
}

/// Page dots: active is a 26 × 6 ember pill.
class _Dots extends StatelessWidget {
  const _Dots({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          for (var i = 0; i < 3; i++)
            AnimatedContainer(
              duration: OxMotion.base,
              curve: OxMotion.easeOut,
              width: i == index ? 26 : 6,
              height: 6,
              decoration: BoxDecoration(color: i == index ? OxColors.ember : const Color(0x38FFFFFF), borderRadius: BorderRadius.circular(6)),
            ),
        ],
      );
}

/// `ox-rise` entrance with a delay, once.
class _Rise extends StatefulWidget {
  const _Rise({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<_Rise> createState() => _RiseState();
}

class _RiseState extends State<_Rise> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = CurvedAnimation(parent: _c, curve: OxMotion.easeOut);
    final reduce = context.reduceMotion;
    return AnimatedBuilder(
      animation: a,
      builder: (context, child) => Opacity(
        opacity: a.value,
        child: Transform.translate(offset: Offset(0, reduce ? 0 : 14 * (1 - a.value)), child: child),
      ),
      child: widget.child,
    );
  }
}

Widget _rotated(double deg, Widget child) => Transform.rotate(angle: deg * math.pi / 180, child: child);

class _OrbitRing extends StatelessWidget {
  const _OrbitRing({required this.w, required this.h, required this.color, this.dashed = false});

  final double w, h;
  final Color color;
  final bool dashed;

  @override
  Widget build(BuildContext context) => Positioned(
        left: 206 - w / 2,
        top: 235 - h / 2,
        width: w,
        height: h,
        child: _rotated(-14, DecoratedBox(decoration: ShapeDecoration(shape: OvalBorder(side: BorderSide(color: color))))),
      );
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.icon, required this.color, required this.label});

  final OxIcons icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => OxGlass(
        lite: true,
        borderRadius: BorderRadius.circular(OxRadius.pill),
        child: SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                OxIcon(icon, size: OxIconSize.sm, color: color),
                Text(label, style: context.oxText.title.copyWith(fontSize: 13, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      );
}

/// Step 1 — sources around a connected Xtream card.
class _ArtConnect extends StatelessWidget {
  const _ArtConnect();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    Widget field(OxIcons icon, String text, {bool secret = false}) => Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0x0DFFFFFF),
            borderRadius: BorderRadius.circular(OxRadius.sm),
            border: Border.all(color: const Color(0x12FFFFFF)),
          ),
          child: Row(
            spacing: 10,
            children: [
              OxIcon(icon, size: OxIconSize.xs, color: OxColors.text3),
              Text(text, textDirection: TextDirection.ltr, style: t.small.copyWith(color: OxColors.text1)),
              if (secret) ...[
                const Spacer(),
                Text('••••••', style: t.small.copyWith(letterSpacing: 3, color: OxColors.text3, fontWeight: FontWeight.w800)),
              ],
            ],
          ),
        );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const _OrbitRing(w: 520, h: 230, color: Color(0x1AFFFFFF), dashed: true),
        const _OrbitRing(w: 380, h: 160, color: Color(0x2EFF7A3D)),
        Positioned(
          left: 66,
          top: 132,
          width: 280,
          child: _Rise(
            child: OxGlass(
              borderRadius: BorderRadius.circular(24),
              shadows: OxShadows.e2,
              padding: const EdgeInsets.all(18),
              child: Column(
                spacing: 14,
                children: [
                  Row(
                    spacing: 12,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: OxColors.emberSoft, borderRadius: BorderRadius.circular(12)),
                        child: const Center(child: OxIcon(OxIcons.server, size: OxIconSize.md, color: OxColors.ember)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.onboardingXtreamCard, style: t.title),
                            Text(l.onboardingCardCaption, style: t.caption),
                          ],
                        ),
                      ),
                      Container(
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(color: const Color(0x245BD69B), borderRadius: BorderRadius.circular(OxRadius.xs)),
                        alignment: Alignment.center,
                        child: Text(l.onboardingOnline, style: t.caption.copyWith(fontSize: 10.5, fontWeight: FontWeight.w800, color: OxColors.ok, height: 1)),
                      ),
                    ],
                  ),
                  Column(spacing: 8, children: [field(OxIcons.link, 'line.yourprovider.tv:8080'), field(OxIcons.user, 'living_room', secret: true)]),
                  const Row(
                    spacing: 10,
                    children: [
                      Expanded(child: _GreenBar()),
                      OxIcon(OxIcons.check, size: OxIconSize.sm, color: OxColors.ok),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(left: 26, top: 64, child: _Rise(delay: const Duration(milliseconds: 150), child: _rotated(-6, _GlassChip(icon: OxIcons.playlist, color: OxColors.emberHi, label: l.onboardingM3uChip)))),
        Positioned(right: 22, top: 84, child: _Rise(delay: const Duration(milliseconds: 250), child: _rotated(5, _GlassChip(icon: OxIcons.epg, color: OxColors.halo, label: l.onboardingEpgChip)))),
        Positioned(left: 48, top: 392, child: _Rise(delay: const Duration(milliseconds: 350), child: _rotated(4, _GlassChip(icon: OxIcons.file, color: OxColors.text1, label: l.onboardingFileChip)))),
        Positioned(
          right: 54,
          top: 380,
          child: _Rise(
            delay: const Duration(milliseconds: 450),
            child: _rotated(
              -8,
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: OxColors.ember,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: Color(0xCCFF7A3D), blurRadius: 34, spreadRadius: -8, offset: Offset(0, 14))],
                ),
                child: const Center(child: OxIcon(OxIcons.play, size: OxIconSize.lg, color: OxColors.emberInk)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GreenBar extends StatelessWidget {
  const _GreenBar();

  @override
  Widget build(BuildContext context) => Container(height: 3, decoration: BoxDecoration(color: OxColors.ok, borderRadius: BorderRadius.circular(3)));
}

/// Step 2 — fanned posters over a live card.
class _ArtLibrary extends StatelessWidget {
  const _ArtLibrary();

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 34,
          top: 84,
          width: 150,
          child: _Rise(delay: const Duration(milliseconds: 100), child: _rotated(-11, const Opacity(opacity: 0.9, child: OxPoster(image: 'assets/onboarding/p-neon.jpg', title: 'Neon Requiem')))),
        ),
        Positioned(
          right: 34,
          top: 84,
          width: 150,
          child: _Rise(
            delay: const Duration(milliseconds: 200),
            child: _rotated(11, const Opacity(opacity: 0.9, child: OxPoster(image: 'assets/onboarding/p-hollow.jpg', title: 'Hollow Crown District'))),
          ),
        ),
        Positioned(
          left: 116,
          top: 44,
          width: 180,
          child: _Rise(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(OxRadius.md),
                boxShadow: const [BoxShadow(color: Color(0xE6000000), blurRadius: 60, spreadRadius: -10, offset: Offset(0, 30)), BoxShadow(color: Color(0x1FFFFFFF), spreadRadius: 1)],
              ),
              child: OxPoster(image: 'assets/onboarding/p-meridian.jpg', title: 'The Last Meridian', titleSize: 15, badges: [OxBadge.quality('4K')]),
            ),
          ),
        ),
        Positioned(
          left: 40,
          right: 40,
          top: 340,
          child: _Rise(
            delay: const Duration(milliseconds: 350),
            child: OxGlass(
              borderRadius: BorderRadius.circular(20),
              shadows: OxShadows.e2,
              padding: const EdgeInsets.all(12),
              child: Row(
                spacing: 12,
                children: [
                  SizedBox(
                    width: 96,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: OxThumb(image: 'assets/onboarding/b-stadium.jpg', shade: false, topStart: Transform.translate(offset: const Offset(-2, -2), child: OxBadge.live(context))),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6,
                      children: [
                        Text('Pulse Sports 1 · FHD', style: t.caption.copyWith(color: OxColors.halo)),
                        Text('Coastal FC vs Northern United', maxLines: 1, overflow: TextOverflow.ellipsis, style: t.title.copyWith(fontSize: 14)),
                        const OxProgressBar(value: 0.12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Step 3 — resume card, favorite heart, favorite channels.
class _ArtResume extends StatelessWidget {
  const _ArtResume();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 36,
          right: 36,
          top: 74,
          child: _Rise(
            child: OxGlass(
              borderRadius: BorderRadius.circular(24),
              shadows: OxShadows.e2,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const OxThumb(image: 'assets/onboarding/b-hollow.jpg'),
                          Center(
                            child: OxGlass(
                              lite: true,
                              borderRadius: BorderRadius.circular(29),
                              color: const Color(0x29FFFFFF),
                              borderColor: const Color(0x4DFFFFFF),
                              child: const SizedBox.square(
                                dimension: 58,
                                child: Padding(padding: EdgeInsets.only(left: 3), child: Center(child: OxIcon(OxIcons.play, size: OxIconSize.lg))),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 14,
                            child: Column(
                              spacing: 8,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Expanded(child: Text('Hollow Crown District', style: t.title)),
                                    Text(l.onboardingMinLeft, style: t.caption.copyWith(color: OxColors.text1)),
                                  ],
                                ),
                                const OxProgressBar(value: 0.64, large: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 12, 6, 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(l.onboardingResume, style: t.small)),
                        Text('34:52', style: OxTypography.en.time.copyWith(color: OxColors.emberHi)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Positioned(right: 30, top: 36, child: _HeartBadge()),
        Positioned(
          left: 56,
          right: 56,
          top: 340,
          child: _Rise(
            delay: const Duration(milliseconds: 250),
            child: OxGlass(
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                spacing: 10,
                children: [
                  for (final (name, i) in [('Meridian News', 0), ('Pulse Sports 1', 1), ('Wave', 6), ('Kitezoo', 5)])
                    OxChannelLogo(name: name, size: 40, colors: OxChannelLogo.palette[i]),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('24', style: OxTypography.en.h1.copyWith(fontSize: 18)),
                      Text(l.onboardingFavorites, style: t.caption),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The ember heart with ring burst (ox-ring 1.8 s) and the spring pop.
class _HeartBadge extends StatefulWidget {
  const _HeartBadge();

  @override
  State<_HeartBadge> createState() => _HeartBadgeState();
}

class _HeartBadgeState extends State<_HeartBadge> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.reduceMotion ? _c.stop() : _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 72,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          // Heart pops in the first half of each loop.
          final pop = t < 0.5 ? TweenSequence<double>([
                TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 30),
                TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 25),
                TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 45),
              ]).transform(t * 2) : 1.0;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (_c.isAnimating)
                Opacity(
                  opacity: 0.9 * (1 - t),
                  child: Transform.scale(
                    scale: 0.6 + 1.2 * t,
                    child: Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: OxColors.ember, width: 2))),
                  ),
                ),
              Container(
                decoration: const BoxDecoration(
                  color: OxColors.ember,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Color(0xCCFF7A3D), blurRadius: 40, spreadRadius: -6, offset: Offset(0, 16))],
                ),
                child: Center(child: Transform.scale(scale: pop, child: const OxIcon(OxIcons.heartFill, size: OxIconSize.xl, color: OxColors.emberInk))),
              ),
            ],
          );
        },
      ),
    );
  }
}
