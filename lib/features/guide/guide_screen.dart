import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/session/session.dart';
import '../../data/data.dart';
import '../../shared/format/format.dart';
import '../../shared/widgets/widgets.dart';
import '../accounts/sync_controller.dart';
import '../common/favorites.dart';
import '../common/media_tiles.dart';
import '../common/navigation.dart';
import '../common/providers.dart';
import '../live/live_providers.dart';

/// Layout constants per size class (EPG spec 2.4 dp/min; tablet 5 dp/min).
class _M {
  const _M({required this.pxPerMin, required this.channelCol, required this.rowH, required this.headerH, required this.leadMin});

  final double pxPerMin;
  final double channelCol;
  final double rowH;
  final double headerH;

  /// Minutes shown before "now" when the guide opens.
  final int leadMin;

  static const phone = _M(pxPerMin: 2.4, channelCol: 76, rowH: 66, headerH: 36, leadMin: 45);
  static const tablet = _M(pxPerMin: 5, channelCol: 210, rowH: 60, headerH: 40, leadMin: 75);
}

typedef _Sel = (Channel, EpgProgramme);

/// Programmes for the day window, by guide id.
final _dayProgrammes = FutureProvider.autoDispose.family<Map<String, List<EpgProgramme>>, (DateTime, String)>((ref, args) async {
  final (day, filterKey) = args;
  final channels = _filter(await ref.watch(liveChannelsProvider(LiveKey.all).future), filterKey);
  final ids = channels.take(400).map(EpgRepository.guideIdOf).toList();
  return ref.read(epgRepositoryProvider).programmes(ref.watch(activeAccountIdProvider) ?? '', ids, day, day.add(const Duration(days: 1)));
});

/// Channels in the selected categories ('' = all), encoded as a sorted id list.
List<Channel> _filter(List<Channel> all, String filterKey) {
  if (filterKey.isEmpty) return all;
  final ids = filterKey.split(',').toSet();
  return all.where((c) => ids.contains(c.categoryId)).toList();
}

/// 18 TV Guide (phone) and 29 the tablet full guide.
class GuideScreen extends ConsumerStatefulWidget {
  const GuideScreen({super.key});

  @override
  ConsumerState<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends ConsumerState<GuideScreen> {
  late DateTime _day = _midnight(DateTime.now());
  final _h = ScrollController();
  Set<String> _categories = {};
  _Sel? _selected;
  bool _positioned = false;

  static DateTime _midnight(DateTime t) => DateTime(t.year, t.month, t.day);

  _M get _m => MediaQuery.sizeOf(context).width >= OxBreakpoints.expanded ? _M.tablet : _M.phone;

  @override
  void dispose() {
    _h.dispose();
    super.dispose();
  }

  /// Scrolls so "now" sits [leadMin] minutes from the left edge.
  void _toNow({bool animate = true}) {
    final now = DateTime.now();
    if (_midnight(now) != _day) {
      setState(() => _day = _midnight(now));
      WidgetsBinding.instance.addPostFrameCallback((_) => _toNow(animate: false));
      return;
    }
    if (!_h.hasClients) return;
    final x = (now.difference(_day).inMinutes - _m.leadMin) * _m.pxPerMin;
    final target = x.clamp(0.0, _h.position.maxScrollExtent);
    animate ? _h.animateTo(target, duration: OxMotion.slow, curve: OxMotion.easeOut) : _h.jumpTo(target);
  }

  void _onDrag(DragUpdateDetails d) {
    if (!_h.hasClients) return;
    _h.jumpTo((_h.offset - d.delta.dx).clamp(0.0, _h.position.maxScrollExtent));
  }

  void _onDragEnd(DragEndDetails d) {
    final pos = _h.hasClients ? _h.position : null;
    if (pos is ScrollPositionWithSingleContext) pos.goBallistic(-d.velocity.pixelsPerSecond.dx);
  }

  Future<void> _pickDay() async {
    final l = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final today = _midnight(DateTime.now());
    final picked = await showOxSheet<DateTime>(
      context,
      title: l.pickDate,
      builder: (s) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = -2; i <= 6; i++)
            Builder(builder: (_) {
              final d = today.add(Duration(days: i));
              final label = i == 0 ? l.today : (i == 1 ? l.tomorrow : (i == -1 ? l.yesterdayShort : DateFormat('EEEE d MMM', lang).format(d)));
              return OxSheetOption(label: label, icon: OxIcons.calendar, selected: d == _day, onTap: () => Navigator.pop(s, d));
            }),
        ],
      ),
    );
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _pickCategories(List<LiveCategory> cats) async {
    final l = context.l10n;
    final chosen = {..._categories};
    final result = await showOxSheet<Set<String>>(
      context,
      title: l.filterCategories,
      builder: (s) => StatefulBuilder(
        builder: (context, setSheet) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  OxSheetOption(label: l.allCategories, icon: OxIcons.live, selected: chosen.isEmpty, onTap: () => setSheet(chosen.clear)),
                  for (final c in cats)
                    OxSheetOption(
                      label: c.name,
                      icon: c.icon,
                      selected: chosen.contains(c.key),
                      onTap: () => setSheet(() => chosen.contains(c.key) ? chosen.remove(c.key) : chosen.add(c.key)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            OxButton(label: l.actionDone, expand: true, onPressed: () => Navigator.pop(s, chosen)),
          ],
        ),
      ),
    );
    if (result != null) setState(() => _categories = result);
  }

  void _open(Channel c, EpgProgramme p) {
    final tablet = _m == _M.tablet;
    setState(() => _selected = (c, p));
    if (!tablet) unawaited(showOxSheet<void>(context, builder: (_) => _ProgrammeDetails(channel: c, programme: p)).then((_) => mounted ? setState(() => _selected = null) : null));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final m = _m;
    final tablet = m == _M.tablet;
    final lang = Localizations.localeOf(context).languageCode;
    final top = MediaQuery.paddingOf(context).top;
    final account = ref.watch(activeAccountIdProvider) ?? '';
    final sync = ref.watch(syncControllerProvider.select((s) => s[account]));
    final refreshing = sync?.guide != null && !sync!.guideDone;
    // States 03: a refresh that just finished → "Guide data from 2 sources · 7 days".
    ref.listen(syncControllerProvider.select((m) => m[account]), (prev, next) {
      final wasRunning = prev?.guide != null && !prev!.guideDone;
      if (!wasRunning || next == null || !next.guideDone || next.guideFailure != null) return;
      final sources = ref.read(activeAccountProvider).value?.guideSourceCount ?? 1;
      final days = next.guideDays ?? 0;
      showOxSnack(
        context,
        tone: OxSnackTone.info,
        icon: OxIcons.epg,
        iconColor: OxColors.halo,
        message: l.guideSources(sources < 1 ? 1 : sources, l.guideDays(days)),
      );
    });

    final filterKey = (_categories.toList()..sort()).join(',');
    final channels = _filter(ref.watch(liveChannelsProvider(LiveKey.all)).value ?? const <Channel>[], filterKey);
    final progs = ref.watch(_dayProgrammes((_day, filterKey)));
    final data = progs.value ?? const {};
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final cats = (ref.watch(_liveCats).value ?? const <MediaCategory>[]).map((c) => LiveCategory(c.id, c.name, iconForCategory(c.name), 0)).toList();
    final today = _midnight(now);

    if (!_positioned && progs.hasValue) {
      _positioned = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _toNow(animate: false));
    }

    final header = Padding(
      padding: EdgeInsetsDirectional.fromSTEB(tablet ? 24 : 8, top + (tablet ? 22 : 10), tablet ? 24 : 12, tablet ? 16 : 0),
      child: Row(
        spacing: tablet ? 12 : 4,
        children: [
          if (!tablet) const SizedBox(width: 12),
          Text(l.tvGuideTitle, style: t.h1.copyWith(fontSize: tablet ? 24 : 22)),
          if (refreshing) _UpdatingBadge(percent: ((sync.guide?.fraction ?? 0) * 100).round()),
          if (tablet)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsetsDirectional.only(start: 12),
                child: Row(
                  spacing: 12,
                  children: [
                    for (var i = -1; i <= 3; i++)
                      Builder(builder: (_) {
                        final d = today.add(Duration(days: i));
                        final label = i == 0 ? l.today : (i == 1 ? l.tomorrow : (i == -1 ? l.yesterdayShort : DateFormat('EEE d', lang).format(d)));
                        return OxChip(label: label, selected: d == _day, onTap: () => setState(() => _day = d));
                      }),
                  ],
                ),
              ),
            )
          else
            const Spacer(),
          if (tablet) ...[
            OxChip(
              label: _categories.isEmpty
                  ? l.allCategories
                  : (_categories.length == 1
                      ? (cats.where((c) => _categories.contains(c.key)).firstOrNull?.name ?? '')
                      : l.categoriesSummary(cats.where((c) => _categories.contains(c.key)).firstOrNull?.name ?? '', _categories.length - 1)),
              icon: OxIcons.filter,
              onTap: () => _pickCategories(cats),
            ),
            OxButton(label: l.nowButton, icon: OxIcons.clock, size: OxButtonSize.sm, onPressed: _toNow),
          ] else ...[
            OxIconButton(icon: OxIcons.calendar, semanticLabel: l.pickDate, onPressed: _pickDay),
            OxIconButton(icon: OxIcons.filter, semanticLabel: l.filterCategories, color: _categories.isEmpty ? null : OxColors.ember, onPressed: () => _pickCategories(cats)),
          ],
        ],
      ),
    );

    final dayPills = tablet
        ? const SizedBox.shrink()
        : SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              itemCount: 7,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final d = today.add(Duration(days: i - 2));
                final on = d == _day;
                return OxPressable(
                  onTap: () => setState(() => _day = d),
                  selected: on,
                  child: AnimatedContainer(
                    duration: OxMotion.base,
                    width: 52,
                    height: 58,
                    decoration: BoxDecoration(
                      color: on ? OxColors.text1 : OxColors.ink2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: on ? const Color(0x00000000) : OxColors.line),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 2,
                      children: [
                        Opacity(
                          opacity: 0.8,
                          child: Text(
                            i == 2 ? l.today : (t.isArabic ? DateFormat('EEE', lang).format(d) : DateFormat('EEE', lang).format(d).toUpperCase()),
                            maxLines: 1,
                            style: t.caption.copyWith(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: t.isArabic ? 0 : 0.63, color: on ? OxColors.onChipOn : OxColors.text2),
                          ),
                        ),
                        Text('${d.day}', style: OxTypography.en.h1.copyWith(fontSize: 16, color: on ? OxColors.onChipOn : OxColors.text2)),
                      ],
                    ),
                  ),
                );
              },
            ),
          );

    final hasData = data.values.any((l) => l.isNotEmpty);

    // The grid is laid out left-to-right in every language: time runs that way.
    final grid = Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, c) {
          final timelineW = 1440 * m.pxPerMin;
          return Stack(
            children: [
              Column(
                children: [
                  // Time header (the one real horizontal scrollable).
                  SizedBox(
                    height: m.headerH,
                    child: Row(
                      children: [
                        Container(
                          width: m.channelCol,
                          color: const Color(0xFF0B0B0F),
                          padding: EdgeInsets.only(left: tablet ? 20 : 14),
                          alignment: Alignment.centerLeft,
                          child: Text(DateFormat(tablet ? 'EEEE d MMM' : 'EEE d MMM', lang).format(_day), maxLines: 1, style: t.caption),
                        ),
                        Expanded(
                          child: ColoredBox(
                            color: const Color(0xFF0B0B0F),
                            child: SingleChildScrollView(
                              controller: _h,
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: timelineW,
                                height: m.headerH,
                                child: Stack(
                                  children: [
                                    for (var min = 0; min < 1440; min += 30)
                                      Positioned(
                                        left: min * m.pxPerMin,
                                        top: tablet ? 13 : 11,
                                        child: Container(
                                          height: 14,
                                          padding: EdgeInsets.only(left: tablet ? 8 : 6),
                                          decoration: BoxDecoration(border: Border(left: BorderSide(color: Color(tablet ? 0x24FFFFFF : 0x1FFFFFFF)))),
                                          child: Text(
                                            Fmt.clock(_day.add(Duration(minutes: min))),
                                            style: OxTypography.en.time.copyWith(fontSize: tablet ? 11.5 : 11, color: OxColors.text3, height: 1.2),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: progs.isLoading && !progs.hasValue
                        ? _SkeletonGrid(m: m)
                        : !hasData
                            ? _EmptyGuide(onRefresh: () => ref.read(syncControllerProvider.notifier).refreshGuide(account))
                            : GestureDetector(
                                onHorizontalDragUpdate: _onDrag,
                                onHorizontalDragEnd: _onDragEnd,
                                child: ListView.builder(
                                  padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + (tablet ? 200 : 24)),
                                  itemCount: channels.length,
                                  itemExtent: m.rowH,
                                  itemBuilder: (context, i) => _Row(
                                    channel: channels[i],
                                    programmes: data[EpgRepository.guideIdOf(channels[i])] ?? const [],
                                    m: m,
                                    day: _day,
                                    now: now,
                                    h: _h,
                                    selected: _selected?.$2,
                                    tablet: tablet,
                                    onTap: _open,
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
              // Now line + badge.
              if (_day == today && hasData)
                AnimatedBuilder(
                  animation: _h,
                  builder: (context, _) {
                    final x = m.channelCol + now.difference(_day).inSeconds / 60 * m.pxPerMin - (_h.hasClients ? _h.offset : 0);
                    if (x < m.channelCol || x > c.maxWidth) return const SizedBox.shrink();
                    return Stack(
                      children: [
                        Positioned(
                          left: x - 1,
                          top: 0,
                          bottom: MediaQuery.paddingOf(context).bottom,
                          width: 2,
                          child: const IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: OxColors.ember,
                                boxShadow: [BoxShadow(color: Color(0xCCFF7A3D), blurRadius: 12)],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: x - 22,
                          top: tablet ? 9 : 6,
                          child: IgnorePointer(
                            child: Container(
                              height: 22,
                              padding: const EdgeInsets.symmetric(horizontal: 7),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: OxColors.ember, borderRadius: BorderRadius.circular(8)),
                              child: Text(Fmt.clock(now), style: OxTypography.en.time.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: OxColors.emberInk, height: 1)),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          );
        },
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              dayPills,
              SizedBox(height: tablet ? 0 : 14),
              const Divider(),
              Expanded(child: grid),
            ],
          ),
          if (tablet && _selected != null)
            PositionedDirectional(
              end: 20,
              bottom: 20 + MediaQuery.paddingOf(context).bottom,
              width: 380,
              child: OxGlass(
                borderRadius: BorderRadius.circular(24),
                shadows: OxShadows.e2,
                padding: const EdgeInsets.all(14),
                child: _ProgrammeDetails(channel: _selected!.$1, programme: _selected!.$2, card: true, onClose: () => setState(() => _selected = null)),
              ),
            ),
        ],
      ),
    );
  }
}

final _liveCats = StreamProvider.autoDispose<List<MediaCategory>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchCategories(ref.watch(activeAccountIdProvider) ?? '', ContentKind.live);
});

class _Row extends StatelessWidget {
  const _Row({
    required this.channel,
    required this.programmes,
    required this.m,
    required this.day,
    required this.now,
    required this.h,
    required this.selected,
    required this.tablet,
    required this.onTap,
  });

  final Channel channel;
  final List<EpgProgramme> programmes;
  final _M m;
  final DateTime day;
  final DateTime now;
  final ScrollController h;
  final EpgProgramme? selected;
  final bool tablet;
  final void Function(Channel, EpgProgramme) onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    // Titles stick to the visible edge when a block starts off-screen.
    Widget blocks(double offset) => Stack(
      clipBehavior: Clip.none,
      children: [
        for (final p in programmes)
          Builder(builder: (context) {
            final a = math.max(0, p.start.difference(day).inMinutes);
            final b = math.min(1440, p.stop.difference(day).inMinutes);
            if (b <= 0 || a >= 1440) return const SizedBox.shrink();
            final left = a * m.pxPerMin + (tablet ? 3 : 2);
            final width = math.max(28.0, (b - a) * m.pxPerMin - (tablet ? 6 : 4));
            final past = !p.stop.isAfter(now);
            final current = !past && !p.start.isAfter(now);
            final isSel = selected != null && selected!.channelId == p.channelId && selected!.start == p.start;
            final pad = tablet ? 12.0 : 10.0;
            final inset = (offset - left).clamp(0.0, math.max(0.0, width - pad * 2 - 64));
            return Positioned(
              left: left,
              top: 5,
              bottom: 5,
              width: width,
              child: OxPressable(
                onTap: () => onTap(channel, p),
                semanticLabel: '${p.title}, ${Fmt.range(p.start, p.stop)}',
                pressedScale: 0.98,
                child: Container(
                  padding: EdgeInsets.only(left: pad + inset, right: pad),
                  decoration: BoxDecoration(
                    color: current ? null : (past ? const Color(0xFF0F0F13) : const Color(0xFF15151B)),
                    gradient: current ? const LinearGradient(colors: [Color(0x38FF7A3D), Color(0x14FF7A3D)]) : null,
                    borderRadius: BorderRadius.circular(12),
                    border: isSel
                        ? Border.all(color: OxColors.ember, width: 2)
                        : Border.all(color: current ? const Color(0x59FF7A3D) : (past ? const Color(0x0AFFFFFF) : const Color(0x0FFFFFFF))),
                    // Outer-only glow: blocks are translucent, a normal shadow would tint them.
                    boxShadow: isSel ? const [BoxShadow(color: Color(0x59FF7A3D), blurRadius: 24, blurStyle: BlurStyle.outer)] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      OxContentText(
                        '${inset > 0 || p.start.isBefore(day) ? '‹ ' : ''}${p.title}',
                        style: t.title.copyWith(fontSize: tablet ? 13 : 12.5, fontWeight: FontWeight.w800, height: 1.2, color: past ? OxColors.text3 : OxColors.text1),
                      ),
                      Text(
                        Fmt.range(p.start, p.stop),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: OxTypography.en.time.copyWith(fontSize: tablet ? 10.5 : 10, color: current ? OxColors.emberHi : OxColors.text3, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );

    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF)))),
      child: Row(
        children: [
          Container(
            width: m.channelCol,
            decoration: const BoxDecoration(color: Color(0xFF0B0B0F), border: Border(right: BorderSide(color: Color(0x0FFFFFFF)))),
            padding: tablet ? const EdgeInsets.symmetric(horizontal: 16) : null,
            child: tablet
                ? Row(
                    spacing: 12,
                    children: [
                      SizedBox(width: 26, child: Text(channel.number?.toString() ?? '', style: OxTypography.en.time.copyWith(fontSize: 10.5, color: OxColors.text3))),
                      OxChannelLogo(name: channel.name, logoUrl: channel.logo, size: 38),
                      Expanded(child: OxContentText(channel.name, style: t.title.copyWith(fontSize: 13, fontWeight: FontWeight.w800))),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 3,
                    children: [
                      OxChannelLogo(name: channel.name, logoUrl: channel.logo, size: 36),
                      if (channel.number != null) Text('${channel.number}', style: OxTypography.en.time.copyWith(fontSize: 9.5, color: OxColors.text3)),
                    ],
                  ),
          ),
          Expanded(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: h,
                builder: (context, _) {
                  final offset = h.hasClients ? h.offset : 0.0;
                  // Translate inside the OverflowBox: hit tests are checked
                  // against the visible box first, then shifted into the day.
                  return OverflowBox(
                    alignment: Alignment.centerLeft,
                    minWidth: 1440 * m.pxPerMin,
                    maxWidth: 1440 * m.pxPerMin,
                    child: Transform.translate(
                      offset: Offset(-offset, 0),
                      child: SizedBox(width: 1440 * m.pxPerMin, height: m.rowH, child: blocks(offset)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Programme details — the phone sheet and the tablet floating card.
class _ProgrammeDetails extends ConsumerWidget {
  const _ProgrammeDetails({required this.channel, required this.programme, this.card = false, this.onClose});

  final Channel channel;
  final EpgProgramme programme;
  final bool card;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.oxText;
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final p = programme;
    final live = !p.start.isAfter(now) && p.stop.isAfter(now);
    final fraction = live ? now.difference(p.start).inSeconds / p.stop.difference(p.start).inSeconds : (p.stop.isAfter(now) ? 0.0 : 1.0);
    final fav = (ref.watch(favoriteIdsProvider(ContentKind.live)).value ?? const {}).contains(channel.id);
    final art = liveArtwork(LiveItem(channel, NowNext(p, null)));
    final left = live ? l.minLeft(p.stop.difference(now).inMinutes) : null;

    final favButton = OxIconButton(
      icon: fav ? OxIcons.heartFill : OxIcons.heart,
      semanticLabel: fav ? l.a11yRemoveFavorite : l.a11yAddFavorite,
      variant: OxIconButtonVariant.tonal,
      color: fav ? OxColors.ember : null,
      dimension: card ? 38 : 44,
      iconSize: OxIconSize.sm,
      onPressed: () => toggleFavoriteWithFeedback(context, ref, ContentKind.live, channel.id),
    );
    final watch = OxButton(
      label: card ? l.watch : l.watchNow,
      icon: OxIcons.play,
      size: OxButtonSize.sm,
      expand: true,
      onPressed: p.start.isAfter(now) ? null : () => context.playChannel(channel.id),
    );

    if (card) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          OxThumb(
            image: null,
            art: art,
            radius: 16,
            progress: live ? fraction : null,
            topStart: live ? Row(spacing: 6, children: [OxBadge(l.onNow, tone: OxBadgeTone.live)]) : null,
            topEnd: OxIconButton(icon: OxIcons.close, semanticLabel: l.a11yDismiss, variant: OxIconButtonVariant.glass, dimension: 32, iconSize: OxIconSize.sm, onPressed: onClose),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OxContentText([channel.name, Fmt.range(p.start, p.stop), ?left].join(' · '), style: t.caption.copyWith(color: OxColors.halo)),
              OxContentText(p.title, maxLines: 2, style: t.h2.copyWith(fontSize: 17)),
              if (p.description != null)
                Padding(padding: const EdgeInsets.only(top: 4), child: OxContentText.paragraph(p.description!, maxLines: 3, style: t.body.copyWith(fontSize: 13))),
            ],
          ),
          Row(spacing: 8, children: [Expanded(child: watch), favButton]),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 12,
            children: [
              SizedBox(width: 112, child: OxThumb(image: null, art: art, radius: 12, shade: false, topStart: live ? OxBadge.live(context) : null)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    OxContentText('${channel.name} · ${Fmt.range(p.start, p.stop)}', style: t.caption.copyWith(color: OxColors.halo)),
                    OxContentText(p.title, maxLines: 2, style: t.title),
                    if (p.category != null || p.description != null) OxContentText(p.category ?? p.description!, maxLines: 2, style: t.caption),
                  ],
                ),
              ),
            ],
          ),
          if (live) OxProgressBar(value: fraction),
          Row(spacing: 10, children: [Expanded(child: watch), favButton]),
        ],
      ),
    );
  }
}

class _UpdatingBadge extends StatelessWidget {
  const _UpdatingBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) => Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: OxColors.glassLite, borderRadius: BorderRadius.circular(OxRadius.xs)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            const OxSpinner(size: 12, strokeWidth: 2, color: OxColors.halo),
            Text(context.l10n.updatingPercent(percent), style: context.oxText.caption.copyWith(fontWeight: FontWeight.w800, color: OxColors.text2)),
          ],
        ),
      );
}

/// States 03 — guide skeleton while loading.
class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid({required this.m});

  final _M m;

  @override
  Widget build(BuildContext context) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 10,
        itemExtent: m.rowH - 8,
        itemBuilder: (context, i) => Container(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF)))),
          child: Row(
            children: [
              Container(width: m.channelCol, color: const Color(0xFF0B0B0F), alignment: Alignment.center, child: const OxSkeleton(width: 34, height: 34)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    spacing: 4,
                    children: [
                      OxSkeleton(width: 60.0 + (i * 37) % 90, radius: 10),
                      OxSkeleton(width: 80.0 + (i * 53) % 110, radius: 10),
                      const Expanded(child: OxSkeleton(radius: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _EmptyGuide extends StatelessWidget {
  const _EmptyGuide({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(34),
        child: OxStateView(
          emblem: const OxStateEmblem(icon: OxIcons.epg, background: OxColors.haloSoft, foreground: OxColors.halo),
          title: l.guideEmptyTitle,
          message: l.guideEmptyBody,
          actions: [OxButton(label: l.refreshGuide, icon: OxIcons.refresh, variant: OxButtonVariant.tonal, onPressed: onRefresh)],
        ),
      ),
    );
  }
}
