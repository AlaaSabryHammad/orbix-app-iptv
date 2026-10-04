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
import '../common/favorites.dart';
import '../common/media_tiles.dart';
import '../common/navigation.dart';
import '../common/providers.dart';
import '../player/live_preview.dart';
import 'live_providers.dart';

enum _Sort { number, name, recent, favoritesFirst }

/// 17 Live TV (phone) and 30 the tablet three-pane layout.
class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  String _category = LiveKey.all;
  String? _selected;
  String _filter = '';
  _Sort _sort = _Sort.number;

  /// Opens a channel — the player route asks for the PIN when it's locked.
  void _play(Channel c, Set<(LockKind, String)> locks) => context.playChannel(c.id);

  List<LiveCategory> _categories(BuildContext context) {
    final l = context.l10n;
    final cats = ref.watch(_categoriesProvider).value ?? const [];
    final counts = ref.watch(liveCategoryCountsProvider).value ?? const {};
    final all = ref.watch(liveChannelsProvider(LiveKey.all)).value?.length ?? 0;
    final fav = ref.watch(favoriteChannelsProvider).value?.length ?? 0;
    final locked = ref.watch(liveChannelsProvider(LiveKey.locked)).value?.length ?? 0;
    return [
      LiveCategory(LiveKey.all, l.allChannels, OxIcons.live, all),
      LiveCategory(LiveKey.favorites, l.favoritesCategory, OxIcons.heart, fav),
      for (final c in cats) LiveCategory(c.id, c.name, iconForCategory(c.name), counts[c.id] ?? 0),
      if (locked > 0) LiveCategory(LiveKey.locked, l.lockedCategory, OxIcons.lock, locked),
    ];
  }

  List<Channel> _sorted(List<Channel> list) {
    final f = _filter.trim().toLowerCase();
    final out = f.isEmpty ? [...list] : list.where((c) => c.name.toLowerCase().contains(f)).toList();
    switch (_sort) {
      case _Sort.number:
        break;
      case _Sort.name:
        out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case _Sort.recent:
        final recent = [for (final c in ref.read(recentChannelsProvider).value ?? const <Channel>[]) c.id];
        int rank(Channel c) => recent.contains(c.id) ? recent.indexOf(c.id) : 1 << 30;
        out.sort((a, b) => rank(a).compareTo(rank(b)));
      case _Sort.favoritesFirst:
        final fav = ref.read(favoriteIdsProvider(ContentKind.live)).value ?? const {};
        out.sort((a, b) => (fav.contains(a.id) ? 0 : 1).compareTo(fav.contains(b.id) ? 0 : 1));
    }
    return out;
  }

  Future<void> _pickSort() async {
    final l = context.l10n;
    final picked = await showOxSheet<_Sort>(
      context,
      title: l.sortChannels,
      builder: (s) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (sort, label, icon) in [
            (_Sort.number, l.sortNumber, OxIcons.list),
            (_Sort.name, l.sortName, OxIcons.translate),
            (_Sort.recent, l.sortRecent, OxIcons.history),
            (_Sort.favoritesFirst, l.sortFavoritesFirst, OxIcons.heart),
          ])
            OxSheetOption(icon: icon, label: label, selected: _sort == sort, onTap: () => Navigator.pop(s, sort)),
        ],
      ),
    );
    if (picked != null) setState(() => _sort = picked);
  }

  @override
  Widget build(BuildContext context) {
    final channels = _sorted(ref.watch(liveChannelsProvider(_category)).value ?? const []);
    final nn = ref.watch(liveNowNextProvider(_category)).value ?? const {};
    final locks = ref.watch(locksProvider).value ?? const {};
    final favorites = ref.watch(favoriteIdsProvider(ContentKind.live)).value ?? const {};
    final recent = ref.watch(recentChannelsProvider).value ?? const [];
    final all = ref.watch(liveChannelsProvider(LiveKey.all)).value ?? const [];
    final cats = _categories(context);

    // The preview channel: the one picked here, else the last watched, else the first.
    final selected = all.where((c) => c.id == _selected).firstOrNull ?? recent.firstOrNull ?? channels.firstOrNull;

    final tablet = MediaQuery.sizeOf(context).width >= OxBreakpoints.expanded;
    final args = _LiveArgs(
      channels: channels,
      nowNext: nn,
      locks: locks,
      favorites: favorites,
      selected: selected,
      categories: cats,
      category: _category,
      onCategory: (k) => setState(() => _category = k),
      onRow: (c) => tablet ? setState(() => _selected = c.id) : _play(c, locks),
      onPlay: (c) => _play(c, locks),
    );

    return Scaffold(
      body: tablet
          ? _TabletLive(args: args, filter: _filter, onFilter: (f) => setState(() => _filter = f), onSort: _pickSort)
          : _PhoneLive(args: args),
    );
  }
}

final _categoriesProvider = StreamProvider.autoDispose<List<MediaCategory>>((ref) {
  final hidden = ref.watch(hiddenCategoriesProvider(ContentKind.live)).value ?? const {};
  return ref
      .watch(catalogRepositoryProvider)
      .watchCategories(ref.watch(activeAccountIdProvider) ?? '', ContentKind.live)
      .map((c) => c.where((x) => !hidden.contains(x.id)).toList());
});

class _LiveArgs {
  const _LiveArgs({
    required this.channels,
    required this.nowNext,
    required this.locks,
    required this.favorites,
    required this.selected,
    required this.categories,
    required this.category,
    required this.onCategory,
    required this.onRow,
    required this.onPlay,
  });

  final List<Channel> channels;
  final Map<String, NowNext> nowNext;
  final Set<(LockKind, String)> locks;
  final Set<String> favorites;
  final Channel? selected;
  final List<LiveCategory> categories;
  final String category;
  final ValueChanged<String> onCategory;
  final ValueChanged<Channel> onRow;
  final ValueChanged<Channel> onPlay;

  NowNext? nnOf(Channel c) => nowNext[EpgRepository.guideIdOf(c)];
}

/// A row in the channel list.
Widget _row(BuildContext context, WidgetRef ref, _LiveArgs a, Channel c, DateTime now) {
  final l = context.l10n;
  final locked = isChannelLocked(c, a.locks);
  final n = a.nnOf(c);
  final p = n?.now;
  return OxChannelRow(
    number: c.number?.toString() ?? '',
    name: c.name,
    logoUrl: c.logo,
    programme: locked ? l.lockedByParental : (p == null ? null : '${p.title} · ${Fmt.range(p.start, p.stop)}'),
    progress: locked ? 0 : (p == null ? null : n!.progressAt(now)),
    nowPlaying: c.id == a.selected?.id,
    locked: locked,
    favorite: a.favorites.contains(c.id),
    onTap: () => a.onRow(c),
    onLongPress: () => a.onPlay(c),
    onFavoriteTap: () => toggleFavoriteWithFeedback(context, ref, ContentKind.live, c.id),
  );
}

class _PhoneLive extends ConsumerWidget {
  const _PhoneLive({required this.args});

  final _LiveArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final top = MediaQuery.paddingOf(context).top;
    final sel = args.selected;

    return Stack(
      children: [
        const OxAmbient(color: Color(0xFF2FBF71), size: Size(360, 240), opacity: 0.12, left: 26, top: 120),
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, top + 10, 12, 0),
                child: SizedBox(
                  height: 48,
                  child: Row(
                    spacing: 4,
                    children: [
                      Expanded(child: Semantics(header: true, child: Text(l.liveTitle, style: context.oxText.h1.copyWith(fontSize: 28)))),
                      OxIconButton(icon: OxIcons.search, semanticLabel: l.actionSearch, onPressed: context.openSearch),
                      OxButton(label: l.guide, icon: OxIcons.epg, variant: OxButtonVariant.tonal, size: OxButtonSize.sm, onPressed: () => context.go(Routes.guide)),
                    ],
                  ),
                ),
              ),
            ),
            if (sel != null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
                  child: _Preview(channel: sel, nowNext: args.nnOf(sel), onTap: () => args.onPlay(sel), radius: 20),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 0), child: _NowNextCard(channel: sel, nowNext: args.nnOf(sel), favorite: args.favorites.contains(sel.id))),
              ),
            ],
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
                  itemCount: args.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final c = args.categories[i];
                    return OxChip(
                      label: c.name,
                      icon: c.icon,
                      count: Fmt.count(c.count),
                      small: true,
                      selected: c.key == args.category,
                      onTap: () => args.onCategory(c.key),
                    );
                  },
                ),
              ),
            ),
            if (args.channels.isEmpty)
              const SliverToBoxAdapter(child: _NoChannels())
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, MediaQuery.paddingOf(context).bottom + 24),
                sliver: SliverList.separated(
                  itemCount: args.channels.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 2),
                  itemBuilder: (context, i) => _row(context, ref, args, args.channels[i], now),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TabletLive extends ConsumerWidget {
  const _TabletLive({required this.args, required this.filter, required this.onFilter, required this.onSort});

  final _LiveArgs args;
  final String filter;
  final ValueChanged<String> onFilter;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.oxText;
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final top = MediaQuery.paddingOf(context).top;
    final sel = args.selected;
    final categoryName = args.categories.where((c) => c.key == args.category).firstOrNull?.name ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Categories
        Container(
          width: 224,
          padding: EdgeInsets.fromLTRB(12, top + 24, 12, 24),
          decoration: const BoxDecoration(border: BorderDirectional(end: BorderSide(color: Color(0x0FFFFFFF)))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 14), child: Text(l.liveTitle, style: t.h1)),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final c in args.categories)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: OxPressable(
                          onTap: () => args.onCategory(c.key),
                          selected: c.key == args.category,
                          pressedScale: 0.98,
                          child: AnimatedContainer(
                            duration: OxMotion.base,
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: c.key == args.category ? const Color(0x24FF7A3D) : const Color(0x00000000),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              spacing: 12,
                              children: [
                                OxIcon(
                                  c.icon,
                                  size: OxIconSize.sm,
                                  color: c.key == LiveKey.locked ? OxColors.warn : (c.key == args.category ? OxColors.text1 : OxColors.text2),
                                ),
                                Expanded(
                                  child: OxContentText(
                                    c.name,
                                    style: t.title.copyWith(
                                      fontSize: 14,
                                      color: c.key == LiveKey.locked ? OxColors.warn : (c.key == args.category ? OxColors.text1 : OxColors.text2),
                                    ),
                                  ),
                                ),
                                Opacity(opacity: 0.65, child: Text(Fmt.count(c.count), style: t.small.copyWith(fontSize: 12))),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Channel list
        Container(
          width: 380,
          decoration: const BoxDecoration(border: BorderDirectional(end: BorderSide(color: Color(0x0FFFFFFF)))),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, top + 24, 16, 12),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(child: SizedBox(height: 44, child: OxSearchField(hint: l.filterCategory(categoryName), onChanged: onFilter))),
                    OxIconButton(icon: OxIcons.filter, semanticLabel: l.sortChannels, variant: OxIconButtonVariant.tonal, iconSize: OxIconSize.sm, onPressed: onSort),
                  ],
                ),
              ),
              Expanded(
                child: args.channels.isEmpty
                    ? const _NoChannels()
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, MediaQuery.paddingOf(context).bottom + 16),
                        itemCount: args.channels.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 2),
                        itemBuilder: (context, i) => _row(context, ref, args, args.channels[i], now),
                      ),
              ),
            ],
          ),
        ),
        // Preview + schedule
        Expanded(
          child: Stack(
            children: [
              const OxAmbient(color: Color(0xFF2FBF71), size: Size(400, 260), opacity: 0.14, left: 60, top: 80),
              if (sel != null)
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, top + 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 18,
                    children: [
                      _Preview(channel: sel, nowNext: args.nnOf(sel), onTap: () => args.onPlay(sel), radius: 22),
                      Row(
                        spacing: 14,
                        children: [
                          OxChannelLogo(name: sel.name, logoUrl: sel.logo, size: 52),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                OxContentText(
                                  sel.number == null ? sel.name : '${sel.name} · ${l.channelNumber('${sel.number}')}',
                                  style: t.caption.copyWith(color: OxColors.halo),
                                ),
                                OxContentText(args.nnOf(sel)?.now?.title ?? sel.name, maxLines: 2, style: t.h2.copyWith(fontSize: 19)),
                              ],
                            ),
                          ),
                          OxFavoriteButton(
                            value: args.favorites.contains(sel.id),
                            onChanged: (_) => toggleFavoriteWithFeedback(context, ref, ContentKind.live, sel.id),
                          ),
                          OxButton(label: l.guide, icon: OxIcons.epg, variant: OxButtonVariant.tonal, size: OxButtonSize.sm, onPressed: () => context.go(Routes.guide)),
                        ],
                      ),
                      _Schedule(channel: sel),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The preview frame. Phase 5 puts the live video here; until then it shows
/// the programme artwork and opens the player.
class _Preview extends ConsumerStatefulWidget {
  const _Preview({required this.channel, required this.nowNext, required this.onTap, required this.radius});

  final Channel channel;
  final NowNext? nowNext;
  final VoidCallback onTap;
  final double radius;

  @override
  ConsumerState<_Preview> createState() => _PreviewState();
}

class _PreviewState extends ConsumerState<_Preview> {
  bool _muted = true;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final channel = widget.channel, nowNext = widget.nowNext, onTap = widget.onTap, radius = widget.radius;
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final p = nowNext?.now;
    final glow = OxChannelLogo.gradientFor(channel.name).first;
    return OxPressable(
      onTap: onTap,
      semanticLabel: '${channel.name}, ${p?.title ?? ''}',
      pressedScale: 0.99,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(color: glow.withValues(alpha: 0.4), blurRadius: 50, spreadRadius: -20, offset: const Offset(0, 24)),
            const BoxShadow(color: Color(0x14FFFFFF), spreadRadius: 1),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                liveArtwork(LiveItem(channel, nowNext)),
                LivePreviewVideo(channel: channel, muted: _muted),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x73000000), Color(0x00000000), Color(0x00000000), Color(0xB3000000)],
                      stops: [0, 0.3, 0.6, 1],
                    ),
                  ),
                ),
                PositionedDirectional(top: 12, start: 12, child: OxBadge.live(context)),
                PositionedDirectional(
                  start: 12,
                  end: 8,
                  bottom: 10,
                  child: Row(
                    spacing: 10,
                    children: [
                      if (p != null) Text(Fmt.clock(p.start), textDirection: TextDirection.ltr, style: OxTypography.en.time.copyWith(fontSize: 11)),
                      Expanded(child: p == null ? const SizedBox.shrink() : OxProgressBar(value: nowNext!.progressAt(now))),
                      if (p != null) Text(Fmt.clock(p.stop), textDirection: TextDirection.ltr, style: OxTypography.en.time.copyWith(fontSize: 11, color: OxColors.text2)),
                      OxIconButton(
                        icon: _muted ? OxIcons.volume : OxIcons.audio,
                        semanticLabel: l.actionMute,
                        dimension: 36,
                        iconSize: OxIconSize.md,
                        color: _muted ? OxColors.text2 : OxColors.ember,
                        onPressed: () => setState(() => _muted = !_muted),
                      ),
                      OxIconButton(icon: OxIcons.fullscreen, semanticLabel: l.actionFullscreen, dimension: 36, iconSize: OxIconSize.md, onPressed: onTap),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NowNextCard extends ConsumerWidget {
  const _NowNextCard({required this.channel, required this.nowNext, required this.favorite});

  final Channel channel;
  final NowNext? nowNext;
  final bool favorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.oxText;
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final p = nowNext?.now;
    final n = nowNext?.next;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: OxColors.ink2, borderRadius: BorderRadius.circular(20), border: Border.all(color: OxColors.line)),
      child: Column(
        spacing: 12,
        children: [
          Row(
            spacing: 12,
            children: [
              OxChannelLogo(name: channel.name, logoUrl: channel.logo, size: 44),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 6,
                      children: [
                        Flexible(child: OxContentText(channel.name, style: t.title)),
                        if (channel.number != null) Text('${channel.number}', style: OxTypography.en.time.copyWith(fontSize: 11, color: OxColors.text3)),
                      ],
                    ),
                    OxContentText(p?.title ?? l.noGuideData, style: t.small.copyWith(color: OxColors.text1)),
                  ],
                ),
              ),
              OxFavoriteButton(
                value: favorite,
                onChanged: (_) => toggleFavoriteWithFeedback(context, ref, ContentKind.live, channel.id),
              ),
            ],
          ),
          if (p != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Expanded(
                  child: _Slot(
                    label: l.nowAt(Fmt.range(p.start, p.stop)),
                    title: p.title,
                    active: true,
                    footer: OxProgressBar(value: nowNext!.progressAt(now)),
                  ),
                ),
                Expanded(
                  child: n == null
                      ? const SizedBox.shrink()
                      : _Slot(
                          label: l.nextAt(Fmt.clock(n.start)),
                          title: n.title,
                          footer: Text(Fmt.runtime(context.l10n, n.stop.difference(n.start)), style: t.caption),
                        ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.label, required this.title, required this.footer, this.active = false});

  final String label;
  final String title;
  final Widget footer;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0x14FF7A3D) : const Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? const Color(0x38FF7A3D) : const Color(0x12FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(t.overlineText(label), maxLines: 1, overflow: TextOverflow.ellipsis, style: t.overline.copyWith(fontSize: 10, color: active ? OxColors.emberHi : null)),
          OxContentText(title, maxLines: 2, style: t.title.copyWith(fontSize: 13, height: 1.3, color: active ? null : const Color(0xFFD2CED8))),
          footer,
        ],
      ),
    );
  }
}

/// Tablet schedule: the programme before, now, next and later.
class _Schedule extends ConsumerWidget {
  const _Schedule({required this.channel});

  final Channel channel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.oxText;
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final list = ref.watch(_scheduleProvider(EpgRepository.guideIdOf(channel))).value ?? const [];
    if (list.isEmpty) return const SizedBox.shrink();
    final nowIdx = list.indexWhere((p) => !p.start.isAfter(now) && p.stop.isAfter(now));
    final from = (nowIdx - 1).clamp(0, list.length);
    final shown = list.skip(from).take(4).toList();

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: OxColors.ink2, borderRadius: BorderRadius.circular(20), border: Border.all(color: OxColors.line)),
      child: Column(
        spacing: 4,
        children: [
          for (final p in shown)
            Builder(builder: (context) {
              final past = !p.stop.isAfter(now);
              final current = !past && !p.start.isAfter(now);
              final isNext = !past && !current && p == shown.firstWhere((x) => x.start.isAfter(now), orElse: () => p);
              final tag = past ? l.scheduleEnded : current ? l.scheduleNow : isNext ? l.scheduleNext : l.scheduleLater;
              final tc = current ? OxColors.emberHi : (past ? OxColors.text3 : OxColors.text2);
              return Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: current ? const Color(0x1AFF7A3D) : const Color(0x00000000),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  spacing: 14,
                  children: [
                    SizedBox(width: 92, child: Text(Fmt.range(p.start, p.stop), textDirection: TextDirection.ltr, style: OxTypography.en.time.copyWith(color: tc))),
                    Expanded(child: OxContentText(p.title, style: t.title.copyWith(fontSize: 13.5, color: past ? OxColors.text3 : null))),
                    Text(tag, style: t.caption.copyWith(color: tc)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

final _scheduleProvider = FutureProvider.autoDispose.family<List<EpgProgramme>, String>((ref, guideId) async {
  final now = ref.watch(clockProvider).value ?? DateTime.now();
  final map = await ref.read(epgRepositoryProvider).programmes(ref.watch(activeAccountIdProvider) ?? '', [guideId], now.subtract(const Duration(hours: 3)), now.add(const Duration(hours: 8)));
  return map[guideId] ?? const [];
});

class _NoChannels extends StatelessWidget {
  const _NoChannels();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(34),
        child: OxStateView(
          emblem: const OxStateEmblem(icon: OxIcons.live, background: OxColors.ink3, foreground: OxColors.text3),
          title: context.l10n.noChannelsTitle,
          message: context.l10n.noChannelsBody,
        ),
      );
}
