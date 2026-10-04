import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/routes.dart';
import '../../core/session/session.dart';
import '../../core/settings/app_settings.dart';
import '../../data/data.dart';
import '../../shared/format/format.dart';
import '../../shared/widgets/widgets.dart';
import '../live/live_providers.dart';

String _account(Ref ref) => ref.watch(activeAccountIdProvider) ?? '';

/// When the PIN was set; null = no PIN.
final pinInfoProvider = FutureProvider.autoDispose<({bool hasPin, DateTime? setAt})>((ref) async {
  final p = ref.watch(parentalProvider);
  return (hasPin: await p.hasPin(), setAt: await p.pinSetAt());
});

typedef _Cat = ({LockKind kind, MediaCategory category, int count});

/// Every category of the active account (live, movies, series) with sizes.
final _lockableCategories = StreamProvider.autoDispose<List<_Cat>>((ref) async* {
  final id = _account(ref);
  final repo = ref.watch(catalogRepositoryProvider);
  final out = <_Cat>[];
  for (final (content, lock) in const [
    (ContentKind.live, LockKind.liveCategory),
    (ContentKind.movie, LockKind.movieCategory),
    (ContentKind.series, LockKind.seriesCategory),
  ]) {
    final cats = await repo.watchCategories(id, content).first;
    final counts = await repo.watchCategoryCounts(id, content).first;
    out.addAll([for (final c in cats) (kind: lock, category: c, count: counts[c.id] ?? 0)]);
  }
  yield out;
});

final _lockedChannels = FutureProvider.autoDispose<List<Channel>>((ref) async {
  final id = _account(ref);
  final locks = await ref.watch(locksProvider.future);
  final repo = ref.read(catalogRepositoryProvider);
  final out = <Channel>[];
  for (final (kind, itemId) in locks) {
    if (kind != LockKind.channel) continue;
    final c = await repo.channel(id, itemId);
    if (c != null) out.add(c);
  }
  return out..sort((a, b) => (a.number ?? 1 << 30).compareTo(b.number ?? 1 << 30));
});

/// 23 Parental controls — behind the PIN when one is set.
class ParentalScreen extends ConsumerWidget {
  const ParentalScreen({super.key});

  Future<void> _togglePin(BuildContext context, WidgetRef ref, bool on) async {
    if (on) {
      final ok = await context.push<bool>('${Routes.pin}?mode=create');
      if (ok ?? false) ref.invalidate(pinInfoProvider);
    } else {
      await ref.read(parentalProvider).removePin();
      ref.invalidate(pinInfoProvider);
      if (context.mounted) showOxSnack(context, message: context.l10n.pinRemoved, icon: OxIcons.unlock);
    }
  }

  Future<void> _relock(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final current = ref.read(appSettingsProvider).relockMinutes;
    final picked = await showOxSheet<int>(
      context,
      title: l.relockAfter,
      builder: (s) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final m in const [1, 5, 15, 30, 60])
            OxSheetOption(label: l.minutesN(m), icon: OxIcons.clock, selected: m == current, onTap: () => Navigator.pop(s, m)),
        ],
      ),
    );
    if (picked != null) await ref.read(appSettingsProvider.notifier).update((s) => s.copyWith(relockMinutes: picked));
  }

  Future<void> _addChannel(BuildContext context, WidgetRef ref) async {
    final picked = await showOxSheet<Channel>(context, title: context.l10n.lockChannelTitle, builder: (_) => const _ChannelPicker());
    if (picked != null) await ref.read(lockRepositoryProvider).setLocked(ref.read(activeAccountIdProvider) ?? '', LockKind.channel, picked.id, true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.oxText;
    final pad = MediaQuery.paddingOf(context);
    final pin = ref.watch(pinInfoProvider).value;
    final settings = ref.watch(appSettingsProvider);
    final locks = ref.watch(locksProvider).value ?? const {};
    final cats = ref.watch(_lockableCategories).value ?? const [];
    final channels = ref.watch(_lockedChannels).value ?? const [];
    final account = ref.read(activeAccountIdProvider) ?? '';
    final on = pin?.hasPin ?? false;
    final liveNames = {for (final c in cats) if (c.kind == LockKind.liveCategory) c.category.id: c.category.name};
    final lockedCats = cats.where((c) => locks.contains((c.kind, c.category.id))).length;

    String countLabel(_Cat c) => switch (c.kind) {
          LockKind.liveCategory => l.channelsCount(c.count),
          LockKind.movieCategory => l.moviesCount(c.count),
          _ => l.seriesCount(c.count),
        };

    Widget groupTitle(String text, Widget trailing) => Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
          child: Row(children: [Expanded(child: Text(t.overlineText(text), style: t.overline)), trailing]),
        );

    final content = [
      // Status card.
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: OxColors.line),
          color: OxColors.ink2,
          gradient: on
              ? LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [Color.alphaBlend(const Color(0x1AFFC65C), OxColors.ink2), OxColors.ink2],
                  stops: const [0, 0.6],
                )
              : null,
          boxShadow: OxShadows.e1,
        ),
        child: Row(
          spacing: 16,
          children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: on ? const Color(0x24FFC65C) : OxColors.ink4,
                border: Border.all(color: on ? const Color(0x59FFC65C) : OxColors.line),
              ),
              child: OxIcon(OxIcons.shield, size: OxIconSize.lg, color: on ? OxColors.warn : OxColors.text3),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(on ? l.protectionOn : l.protectionOff, style: t.title.copyWith(fontSize: 16)),
                  Text(on ? l.protectionOnBody : l.protectionOffBody, style: t.caption.copyWith(height: 1.45)),
                ],
              ),
            ),
          ],
        ),
      ),
      OxGroup(
        children: [
          OxListRow(
            icon: OxIcons.key,
            title: l.pinProtection,
            subtitle: on ? (pin?.setAt != null ? l.pinSetOn(Fmt.date(context, pin!.setAt!)) : null) : l.pinNotSet,
            trailing: OxSwitch(value: on, semanticLabel: l.pinProtection, onChanged: pin == null ? null : (v) => _togglePin(context, ref, v)),
          ),
          if (on)
            OxListRow(
              icon: OxIcons.edit,
              title: l.changePin,
              chevron: true,
              onTap: () async {
                final ok = await context.push<bool>('${Routes.pin}?mode=change');
                if (ok ?? false) ref.invalidate(pinInfoProvider);
              },
            ),
          OxListRow(
            icon: OxIcons.eyeOff,
            title: l.adultProtection,
            subtitle: l.adultProtectionHint,
            trailing: OxSwitch(
              value: settings.adultFilter,
              semanticLabel: l.adultProtection,
              onChanged: (v) => ref.read(appSettingsProvider.notifier).update((s) => s.copyWith(adultFilter: v)),
            ),
          ),
          OxListRow(icon: OxIcons.clock, title: l.relockAfter, value: l.minutesN(settings.relockMinutes), chevron: true, onTap: () => _relock(context, ref)),
        ],
      ),
      if (cats.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            groupTitle(
              l.lockedCategories,
              Text(l.lockedOfTotal(lockedCats, cats.length), style: t.caption.copyWith(fontSize: 12, fontWeight: FontWeight.w800, color: OxColors.warn)),
            ),
            OxGroup(
              children: [
                for (final c in cats)
                  _CategoryRow(
                    name: c.category.name,
                    caption: c.category.isAdult && settings.adultFilter ? l.hiddenSuffix(countLabel(c)) : countLabel(c),
                    locked: locks.contains((c.kind, c.category.id)),
                    onToggle: (v) => ref.read(lockRepositoryProvider).setLocked(account, c.kind, c.category.id, v),
                  ),
              ],
            ),
          ],
        ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          groupTitle(
            l.lockedChannels,
            OxPressable(
              onTap: () => _addChannel(context, ref),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(l.actionAdd, style: t.caption.copyWith(fontSize: 12, fontWeight: FontWeight.w800, color: OxColors.text2)),
              ),
            ),
          ),
          OxGroup(
            children: [
              if (channels.isEmpty) OxListRow(title: l.noLockedChannels, icon: OxIcons.lock, iconColor: OxColors.text3),
              for (final c in channels)
                OxListRow(
                  title: c.name,
                  subtitle: [?liveNames[c.categoryId], if (c.number != null) '${c.number}'].join(' · '),
                  trailing: OxIconButton(
                    icon: OxIcons.close,
                    semanticLabel: l.unlockChannel,
                    color: OxColors.text3,
                    onPressed: () => ref.read(lockRepositoryProvider).setLocked(account, LockKind.channel, c.id, false),
                  ),
                  leading: _LockedLogo(channel: c),
                ),
            ],
          ),
        ],
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const OxAmbient(size: Size(300, 220), left: 56, top: 90, color: OxColors.warn, opacity: 0.12),
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsetsDirectional.fromSTEB(8, pad.top + 10, 12, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    spacing: 4,
                    children: [
                      OxIconButton(icon: OxIcons.back, semanticLabel: l.actionBack, onPressed: () => context.pop()),
                      Expanded(child: Text(l.parentalTitle, style: t.h1.copyWith(fontSize: 22))),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 18, 16, pad.bottom + 40),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 22, children: content),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.name, required this.caption, required this.locked, required this.onToggle});

  final String name;
  final String caption;
  final bool locked;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: 14,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OxContentText(name, style: t.title.copyWith(fontSize: 14.5)),
                Text(caption, style: t.caption),
              ],
            ),
          ),
          OxPressable(
            onTap: () => onToggle(!locked),
            selected: locked,
            semanticLabel: '${l.toggleLock}, $name',
            child: AnimatedContainer(
              duration: OxMotion.fast,
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: locked ? const Color(0x24FFC65C) : null,
                borderRadius: BorderRadius.circular(OxRadius.pill),
                border: Border.all(color: locked ? const Color(0x66FFC65C) : const Color(0x24FFFFFF)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  OxIcon(locked ? OxIcons.lock : OxIcons.unlock, size: OxIconSize.xs, color: locked ? OxColors.warn : OxColors.text2),
                  Text(locked ? l.lockLocked : l.lockOpen, style: t.caption.copyWith(fontSize: 12, fontWeight: FontWeight.w800, color: locked ? OxColors.warn : OxColors.text2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedLogo extends StatelessWidget {
  const _LockedLogo({required this.channel});

  final Channel channel;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.57, 0.34, 0.09, 0, 0, //
                0.17, 0.74, 0.09, 0, 0,
                0.17, 0.34, 0.49, 0, 0,
                0, 0, 0, 1, 0,
              ]),
              child: OxChannelLogo(name: channel.name, logoUrl: channel.logo, size: 40),
            ),
            PositionedDirectional(
              end: -1,
              bottom: -1,
              child: Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: OxColors.warn, borderRadius: BorderRadius.circular(6)),
                child: const OxIcon(OxIcons.lock, size: 11, color: Color(0xFF1C1204)),
              ),
            ),
          ],
        ),
      );
}

/// "Add" — pick a channel to lock.
class _ChannelPicker extends ConsumerStatefulWidget {
  const _ChannelPicker();

  @override
  ConsumerState<_ChannelPicker> createState() => _ChannelPickerState();
}

class _ChannelPickerState extends ConsumerState<_ChannelPicker> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locks = ref.watch(locksProvider).value ?? const {};
    final all = ref.watch(liveChannelsProvider(LiveKey.all)).value ?? const <Channel>[];
    final q = _q.trim().toLowerCase();
    final list = all.where((c) => !locks.contains((LockKind.channel, c.id)) && (q.isEmpty || c.name.toLowerCase().contains(q) || '${c.number}' == q)).toList();
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: Column(
        spacing: 10,
        children: [
          OxSearchField(hint: l.searchChannels, onChanged: (v) => setState(() => _q = v)),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemExtent: 64,
              itemBuilder: (context, i) => OxChannelRow(number: list[i].number?.toString() ?? '', name: list[i].name, logoUrl: list[i].logo, onTap: () => Navigator.pop(context, list[i])),
            ),
          ),
        ],
      ),
    );
  }
}
