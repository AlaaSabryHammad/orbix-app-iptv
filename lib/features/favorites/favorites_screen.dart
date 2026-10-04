import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/routes.dart';
import '../../core/session/session.dart';
import '../../data/data.dart';
import '../../shared/format/format.dart';
import '../../shared/widgets/widgets.dart';
import '../common/browse.dart';
import '../common/navigation.dart';
import '../common/providers.dart';

/// One favorite, whatever its kind.
class _Fav {
  const _Fav({required this.id, required this.name, this.image, this.channel});

  final String id;
  final String name;
  final String? image;
  final Channel? channel;
}

/// 16 Favorites: Channels / Movies / Series; Edit mode reorders (drag) and
/// removes (with Undo).
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  int _tab = 0;
  bool _editing = false;

  /// Local order while dragging, so the list doesn't jump back before the
  /// database write lands.
  List<_Fav>? _pending;

  static const _kinds = [ContentKind.live, ContentKind.movie, ContentKind.series];

  List<_Fav> _items(int tab) => switch (tab) {
        0 => [for (final c in ref.watch(favoriteChannelsProvider).value ?? const <Channel>[]) _Fav(id: c.id, name: c.name, image: c.logo, channel: c)],
        1 => [for (final m in ref.watch(favoriteMoviesProvider).value ?? const <Movie>[]) _Fav(id: m.id, name: m.name, image: m.poster)],
        _ => [for (final s in ref.watch(favoriteSeriesProvider).value ?? const <Show>[]) _Fav(id: s.id, name: s.name, image: s.cover)],
      };

  Future<void> _remove(_Fav f) async {
    final l = context.l10n;
    final account = ref.read(activeAccountIdProvider) ?? '';
    final removed = await ref.read(libraryRepositoryProvider).removeFavorite(account, _kinds[_tab], f.id);
    if (!mounted || removed == null) return;
    showOxSnack(
      context,
      message: l.removedFromFavorites(f.name),
      icon: OxIcons.heart,
      iconColor: OxColors.snackAction,
      actionLabel: l.actionUndo,
      onAction: () => ref.read(libraryRepositoryProvider).restoreFavorite(removed),
    );
  }

  Future<void> _reorder(List<_Fav> items, int from, int to) async {
    // onReorderItem already gives the index after removal.
    final next = [...items];
    final moved = next.removeAt(from);
    next.insert(to, moved);
    setState(() => _pending = next);
    await ref.read(libraryRepositoryProvider).reorderFavorites(ref.read(activeAccountIdProvider) ?? '', _kinds[_tab], [for (final f in next) f.id]);
    if (mounted) setState(() => _pending = null);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final counts = [for (var i = 0; i < 3; i++) _items(i).length];
    final items = _pending ?? _items(_tab);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(
            title: l.favoritesTitle,
            actions: [
              if (items.isNotEmpty)
                _editing
                    ? _DoneButton(label: l.actionDone, onPressed: () => setState(() => _editing = false))
                    : OxButton(
                        label: l.actionEdit,
                        icon: OxIcons.edit,
                        variant: OxButtonVariant.ghost,
                        size: OxButtonSize.sm,
                        onPressed: () => setState(() => _editing = true),
                      ),
            ],
          ),
          const SizedBox(height: 14),
          OxTabs(
            labels: [l.filterChannels, l.filterMovies, l.filterSeries],
            counts: counts,
            index: _tab,
            onChanged: (i) => setState(() {
              _tab = i;
              _pending = null;
            }),
          ),
          Expanded(
            child: items.isEmpty
                ? _Empty(onBrowse: () => context.go(Routes.live))
                : _editing
                    ? _EditList(items: items, isChannels: _tab == 0, onRemove: _remove, onReorder: (a, b) => _reorder(items, a, b))
                    : _tab == 0
                        ? _ChannelList(items: items)
                        : CustomScrollView(
                            slivers: [
                              const SliverPadding(padding: EdgeInsets.only(top: 18)),
                              PosterGridSliver(
                                itemCount: items.length,
                                captionHeight: 22,
                                itemBuilder: (context, i) {
                                  final f = items[i];
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 8,
                                    children: [
                                      OxPoster(
                                        image: f.image,
                                        semanticLabel: f.name,
                                        topEnd: const OxIcon(OxIcons.heartFill, size: OxIconSize.sm, color: OxColors.ember),
                                        onTap: () => _tab == 1 ? context.openMovie(f.id) : context.openSeries(f.id),
                                      ),
                                      OxContentText(f.name, style: context.oxText.title.copyWith(fontSize: 13)),
                                    ],
                                  );
                                },
                              ),
                              SliverPadding(padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 24)),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OxPressable(
        onTap: onPressed,
        child: Container(
          height: OxSize.buttonSm,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: OxColors.emberSoft, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              const OxIcon(OxIcons.check, size: OxIconSize.sm, color: OxColors.emberHi),
              Text(label, style: context.oxText.title.copyWith(fontSize: 13.5, fontWeight: FontWeight.w800, color: OxColors.emberHi)),
            ],
          ),
        ),
      );
}

/// Now / next for favorite channels.
final _favNowProvider = FutureProvider.autoDispose<Map<String, NowNext>>((ref) async {
  final now = ref.watch(clockProvider).value ?? DateTime.now();
  final channels = await ref.watch(favoriteChannelsProvider.future);
  return ref.read(epgRepositoryProvider).nowNext(ref.watch(activeAccountIdProvider) ?? '', channels.map(EpgRepository.guideIdOf), at: now);
});

String _nowLine(BuildContext context, NowNext? nn) {
  final p = nn?.now;
  if (p == null) return '';
  return '${p.title} · ${context.l10n.endsAt(Fmt.clock(p.stop))}';
}

class _ChannelList extends ConsumerWidget {
  const _ChannelList({required this.items});

  final List<_Fav> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nn = ref.watch(_favNowProvider).value ?? const {};
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(8, 12, 8, MediaQuery.paddingOf(context).bottom + 24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 2),
      itemBuilder: (context, i) {
        final c = items[i].channel!;
        final n = nn[EpgRepository.guideIdOf(c)];
        return OxChannelRow(
          number: c.number?.toString() ?? '${i + 1}',
          name: c.name,
          logoUrl: c.logo,
          programme: n?.now == null ? null : '${n!.now!.title} · ${Fmt.range(n.now!.start, n.now!.stop)}',
          progress: n?.now == null ? null : n!.progressAt(now),
          favorite: true,
          onTap: () => context.playChannel(c.id),
          onFavoriteTap: () => ref.read(libraryRepositoryProvider).toggleFavorite(ref.read(activeAccountIdProvider) ?? '', ContentKind.live, c.id),
        );
      },
    );
  }
}

class _EditList extends ConsumerWidget {
  const _EditList({required this.items, required this.isChannels, required this.onRemove, required this.onReorder});

  final List<_Fav> items;
  final bool isChannels;
  final ValueChanged<_Fav> onRemove;
  final void Function(int from, int to) onReorder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.oxText;
    final nn = isChannels ? (ref.watch(_favNowProvider).value ?? const {}) : const <String, NowNext>{};
    final reduce = context.reduceMotion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Row(
            spacing: 8,
            children: [const OxIcon(OxIcons.grip, size: OxIconSize.xs, color: OxColors.text3), Text(l.dragToReorder, style: t.caption)],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: EdgeInsets.fromLTRB(12, 4, 12, MediaQuery.paddingOf(context).bottom + 24),
            buildDefaultDragHandles: false,
            itemCount: items.length,
            onReorderItem: onReorder,
            proxyDecorator: (child, index, animation) => AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final v = Curves.easeOut.transform(animation.value);
                return Transform.rotate(
                  angle: reduce ? 0 : -1.2 * math.pi / 180 * v,
                  child: Transform.scale(
                    scale: reduce ? 1 : 1 + 0.03 * v,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C24),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.6 * v), blurRadius: 40, offset: const Offset(0, 18)),
                          BoxShadow(color: Color.fromRGBO(255, 122, 61, 0.55 * v), spreadRadius: 1.5),
                        ],
                      ),
                      child: Material(type: MaterialType.transparency, child: child),
                    ),
                  ),
                );
              },
              child: child,
            ),
            itemBuilder: (context, i) {
              final f = items[i];
              final sub = isChannels ? _nowLine(context, nn[EpgRepository.guideIdOf(f.channel!)]) : '';
              return Padding(
                key: ValueKey(f.id),
                padding: const EdgeInsets.only(bottom: 6),
                child: SizedBox(
                  height: 66,
                  child: Row(
                    spacing: 12,
                    children: [
                      ReorderableDragStartListener(
                        index: i,
                        child: Semantics(
                          label: l.dragToReorder,
                          child: const SizedBox(width: 36, height: 66, child: Center(child: OxIcon(OxIcons.grip, size: OxIconSize.md, color: OxColors.text3))),
                        ),
                      ),
                      SizedBox(
                        width: 22,
                        child: Text((i + 1).toString().padLeft(2, '0'), textDirection: TextDirection.ltr, style: OxTypography.en.time.copyWith(color: OxColors.text3)),
                      ),
                      if (isChannels)
                        OxChannelLogo(name: f.name, logoUrl: f.image, size: 44)
                      else
                        SizedBox(width: 30, child: ClipRRect(borderRadius: BorderRadius.circular(6), child: AspectRatio(aspectRatio: 2 / 3, child: OxImage(f.image)))),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OxContentText(f.name, style: t.title.copyWith(fontSize: 14.5)),
                            if (sub.isNotEmpty) OxContentText(sub, style: t.caption),
                          ],
                        ),
                      ),
                      OxPressable(
                        onTap: () => onRemove(f),
                        semanticLabel: l.removeFavorite,
                        child: SizedBox(
                          width: 44,
                          height: 66,
                          child: Center(
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: OxColors.errText, width: 1.8)),
                              child: Center(child: Container(width: 10, height: 2, decoration: BoxDecoration(color: OxColors.errText, borderRadius: BorderRadius.circular(2)))),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(34),
        child: OxStateView(
          emblem: const OxStateEmblem(icon: OxIcons.heart, background: OxColors.emberSoft, foreground: OxColors.ember, beat: true),
          title: l.noFavoritesTitle,
          message: l.noFavoritesBody,
          actions: [OxButton(label: l.browseLiveTv, onPressed: onBrowse)],
        ),
      ),
    );
  }
}
