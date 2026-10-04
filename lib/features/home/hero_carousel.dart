import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../data/data.dart';
import '../../shared/format/format.dart';
import '../../shared/widgets/widgets.dart';
import '../common/favorites.dart';
import '../common/media_tiles.dart';
import '../common/navigation.dart';
import '../common/providers.dart';

/// A featured title: a movie with its details, or the item to resume.
class HeroItem {
  const HeroItem({required this.movie, this.details, this.resume});

  final Movie movie;
  final MovieDetails? details;

  /// Set when this slide resumes playback (compact Home).
  final ContinueItem? resume;

  String? get image => details?.backdrop ?? movie.poster;
}

/// Up to 5 featured movies: new and well rated first, then the most popular.
final heroItemsProvider = FutureProvider.autoDispose<List<HeroItem>>((ref) async {
  final recent = await ref.watch(recentMoviesProvider.future);
  final popular = await ref.watch(popularMoviesProvider.future);
  final picked = <String, Movie>{};
  final fresh = recent.where((m) => isNew(m.addedAt)).toList()..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
  for (final m in [...fresh, ...popular]) {
    picked.putIfAbsent(m.id, () => m);
    if (picked.length == 5) break;
  }
  final details = await Future.wait(picked.values.map((m) => ref.watch(movieDetailsProvider(m.id).future).catchError((Object _) => null)));
  return [for (final (i, m) in picked.values.indexed) HeroItem(movie: m, details: details[i])];
});

enum HeroLayout { phone, compact, tablet }

/// Home hero with auto-advance (8 s), swipe, cross-fade (600 ms) and a slow
/// Ken Burns drift on the artwork.
class HeroCarousel extends ConsumerStatefulWidget {
  const HeroCarousel({super.key, required this.items, required this.layout, this.topBar});

  final List<HeroItem> items;
  final HeroLayout layout;

  /// Phone layouts overlay the top bar on the artwork.
  final Widget? topBar;

  @override
  ConsumerState<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends ConsumerState<HeroCarousel> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  void _restart() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => _go(1));
  }

  void _go(int delta) {
    if (widget.items.length < 2 || !mounted) return;
    setState(() => _index = (_index + delta) % widget.items.length);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();
    final i = _index % items.length;
    final item = items[i];
    final tablet = widget.layout == HeroLayout.tablet;

    final art = AnimatedSwitcher(
      duration: OxMotion.heroFade,
      child: KeyedSubtree(key: ValueKey(item.movie.id), child: _KenBurns(image: item.image, alignment: const Alignment(0.24, 0))),
    );

    final body = GestureDetector(
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v.abs() < 200) return;
        final rtl = Directionality.of(context) == TextDirection.rtl;
        _go((v < 0) != rtl ? 1 : -1);
        _restart();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          art,
          if (tablet)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xE608080B), Color(0x6608080B), Color(0x0008080B)], stops: [0, 0.45, 0.75]),
              ),
            )
          else ...[
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [Color(0xB308080B), Color(0x0008080B), Color(0x0008080B), Color(0xBF08080B), OxColors.ink1],
                  stops: widget.layout == HeroLayout.compact ? const [0, 0.22, 0.40, 0.72, 1] : const [0, 0.22, 0.42, 0.72, 1],
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0x8C08080B), Color(0x0008080B)], stops: [0, 0.6])),
            ),
          ],
          AnimatedSwitcher(
            duration: OxMotion.heroFade,
            child: KeyedSubtree(
              key: ValueKey('c${item.movie.id}'),
              child: _HeroContent(item: item, layout: widget.layout, count: items.length, index: i),
            ),
          ),
          ?widget.topBar,
        ],
      ),
    );

    if (!tablet) return body;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x80FF7A3D), blurRadius: 60, spreadRadius: -30, offset: Offset(0, 30)),
          BoxShadow(color: Color(0x0FFFFFFF), spreadRadius: 1),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(28), child: body),
    );
  }
}

class _HeroContent extends ConsumerWidget {
  const _HeroContent({required this.item, required this.layout, required this.count, required this.index});

  final HeroItem item;
  final HeroLayout layout;
  final int count;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.oxText;
    final m = item.movie;
    final d = item.details;
    final tablet = layout == HeroLayout.tablet;
    final compact = layout == HeroLayout.compact;
    final favorites = ref.watch(favoriteIdsProvider(ContentKind.movie)).value ?? const {};
    final fav = favorites.contains(m.id);
    final resume = item.resume;

    final meta = OxMetaLine([
      if (m.rating != null) OxRating(m.rating!.toStringAsFixed(1)),
      if (m.year != null) '${m.year}',
      if (!compact && d?.genre != null) d!.genre!,
      if (d?.durationSecs != null) Fmt.runtime(context.l10n, Duration(seconds: d!.durationSecs!)),
    ]);

    final buttons = Row(
      spacing: compact ? 8 : 10,
      children: [
        Expanded(
          flex: tablet ? 0 : 1,
          child: OxPlayGlow(
            borderRadius: BorderRadius.circular(OxRadius.md),
            child: OxButton(
              label: resume != null ? l.actionResume : l.actionPlay,
              icon: OxIcons.play,
              expand: !tablet,
              onPressed: () => context.playMovie(m.id),
            ),
          ),
        ),
        if (compact)
          OxIconButton(icon: OxIcons.info, semanticLabel: l.actionMoreInfo, variant: OxIconButtonVariant.glass, dimension: 46, onPressed: () => context.openMovie(m.id))
        else
          Expanded(
            flex: tablet ? 0 : 1,
            child: OxButton(
              label: l.actionMoreInfo,
              icon: OxIcons.info,
              variant: OxButtonVariant.glass,
              expand: !tablet,
              onPressed: () => context.openMovie(m.id),
            ),
          ),
        OxIconButton(
          icon: fav ? OxIcons.check : OxIcons.plus,
          semanticLabel: fav ? l.a11yRemoveFavorite : l.a11yAddFavorite,
          variant: OxIconButtonVariant.glass,
          dimension: compact ? 46 : 50,
          onPressed: () => toggleFavoriteWithFeedback(context, ref, ContentKind.movie, m.id),
        ),
      ],
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: compact ? 10 : (tablet ? 14 : 12),
      children: [
        if (isNew(m.addedAt)) Row(spacing: 6, children: [OxBadge.fresh(context)]),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tablet ? 380 : 330),
          child: OxContentText(
            t.isArabic ? m.name : m.name.toUpperCase(),
            maxLines: 3,
            style: t.hero.copyWith(fontSize: compact ? 30 : (tablet ? 42 : 38)),
          ),
        ),
        meta,
        if (!compact && d?.plot != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: OxContentText.paragraph(d!.plot!, maxLines: 3, style: t.body.copyWith(color: const Color(0xFFD9D5DE))),
          ),
        Padding(padding: const EdgeInsets.only(top: 4), child: buttons),
        if (resume != null) OxProgressBar(value: resume.fraction),
        if (!tablet && count > 1) Padding(padding: const EdgeInsets.only(top: 6), child: _Dots(count: count, index: index)),
      ],
    );

    if (tablet) {
      return Stack(
        children: [
          PositionedDirectional(start: 36, top: 0, bottom: 0, width: 380, child: Align(alignment: AlignmentDirectional.centerStart, child: content)),
          if (count > 1) PositionedDirectional(end: 24, bottom: 22, child: _Dots(count: count, index: index, tablet: true)),
        ],
      );
    }
    final g = compact ? 16.0 : 20.0;
    return PositionedDirectional(start: g, end: g, bottom: compact ? 20 : 26, child: content).wrapInStack();
  }
}

extension on Widget {
  Widget wrapInStack() => Stack(children: [this]);
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index, this.tablet = false});

  final int count;
  final int index;
  final bool tablet;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: OxMotion.base,
              width: i == index ? 22 : 8,
              height: 4,
              decoration: BoxDecoration(
                color: i == index ? OxColors.text1 : Color(tablet ? 0x4DFFFFFF : 0x47FFFFFF),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      );
}

/// `ox-drift` — 18 s scale/translate loop; static under reduced motion.
class _KenBurns extends StatefulWidget {
  const _KenBurns({required this.image, required this.alignment});

  final String? image;
  final Alignment alignment;

  @override
  State<_KenBurns> createState() => _KenBurnsState();
}

class _KenBurnsState extends State<_KenBurns> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(seconds: 9));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.reduceMotion ? _c.stop() : _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = OxImage(widget.image, alignment: widget.alignment);
    return ClipRect(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final v = Curves.easeInOut.transform(_c.value);
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.translationValues(-0.015 * v * 400, -0.01 * v * 600, 0)..scaleByDouble(1.04 + 0.04 * v, 1.04 + 0.04 * v, 1, 1),
            child: child,
          );
        },
        child: image,
      ),
    );
  }
}
