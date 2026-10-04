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
import 'sync_controller.dart';

/// After Connect: States 02 "Loading your playlist" (progressive — Live TV
/// can be opened as soon as channels are in), then States 11 "You're all set".
class AccountSetupScreen extends ConsumerWidget {
  const AccountSetupScreen({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final sync = ref.watch(syncControllerProvider.select((m) => m[accountId])) ?? const AccountSync();
    final account = ref.watch(activeAccountProvider).value;
    final p = sync.catalog;
    final failure = p.failure;
    // Success once the catalog is in and the guide finished (or failed — a
    // missing guide doesn't block watching).
    final done = p.finished && failure == null && sync.guideDone;

    Widget body;
    if (failure != null && !p.liveReady) {
      body = OxStateView(
        emblem: const OxStateEmblem(icon: OxIcons.alert, background: Color(0x29FF6B6B), foreground: OxColors.errText),
        title: l.testFailed,
        message: describeFailure(context, failure),
        detail: failureDetail(failure),
        actions: [
          OxButton(label: l.actionRetry, expand: true, onPressed: () => _retry(ref)),
          OxButton(label: l.actionEditDetails, variant: OxButtonVariant.tonal, expand: true, onPressed: () => context.go(Routes.editAccount(accountId))),
        ],
      );
    } else if (done) {
      body = OxStateView(
        emblem: const OxStateEmblem.success(),
        title: l.allSetTitle,
        titleSize: 22,
        message: l.allSetBody(account?.name ?? ''),
        actions: [OxButton(label: l.startWatching, expand: true, onPressed: () => context.go(Routes.home))],
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.6,
            children: [
              _Stat(value: Fmt.count(account?.liveCount ?? 0), label: l.statLive),
              _Stat(value: Fmt.count(account?.movieCount ?? 0), label: l.statMovies),
              _Stat(value: Fmt.count(account?.seriesCount ?? 0), label: l.statSeries),
              _Stat(value: sync.guideDays == null || sync.guideDays == 0 ? '—' : l.guideDays(sync.guideDays!), label: l.statGuide),
            ],
          ),
        ],
      );
    } else {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OxOrbitLoader(size: 84),
          const SizedBox(height: 26),
          Text(l.loadingPlaylist, textAlign: TextAlign.center, style: context.oxText.h1.copyWith(fontSize: 20)),
          const SizedBox(height: 16),
          Text(l.loadingPlaylistBody, textAlign: TextAlign.center, style: context.oxText.body.copyWith(fontSize: 13)),
          const SizedBox(height: 24),
          _Section(label: l.sectionChannels, progress: p.live),
          const SizedBox(height: 12),
          _Section(label: l.sectionMovies, progress: p.movies),
          const SizedBox(height: 12),
          _Section(label: l.sectionSeries, progress: p.series),
          const SizedBox(height: 28),
          OxButton(
            label: l.watchLiveNow,
            icon: OxIcons.live,
            expand: true,
            onPressed: p.liveReady ? () => context.go(Routes.live) : null,
          ),
        ],
      );
    }

    final success = done;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: success
              ? const RadialGradient(center: Alignment(0, -0.3), radius: 0.62, colors: [Color(0x245BD69B), OxColors.ink1], stops: [0, 0.7])
              : null,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AnimatedSwitcher(duration: OxMotion.base, child: KeyedSubtree(key: ValueKey(success ? 'done' : failure != null ? 'fail' : 'load'), child: body)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _retry(WidgetRef ref) async {
    final account = await ref.read(accountRepositoryProvider).byId(accountId);
    if (account != null) await ref.read(syncControllerProvider.notifier).start(account);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.progress});

  final String label;
  final SectionProgress progress;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final ready = progress.phase == SectionPhase.ready;
    final waiting = progress.phase == SectionPhase.waiting;
    final failed = progress.phase == SectionPhase.failed;
    final total = progress.total;
    final value = switch (progress.phase) {
      SectionPhase.waiting => l.stepWaiting,
      SectionPhase.ready => '${Fmt.count(progress.done)} ✓',
      SectionPhase.failed => l.stepGuideBroken,
      SectionPhase.loading => total == null ? '' : '${Fmt.count(progress.done)} / ${Fmt.count(total)}',
    };
    final fraction = ready ? 1.0 : (total == null || total == 0 ? 0.0 : progress.done / total);
    return Column(
      spacing: 6,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: t.small.copyWith(color: waiting ? null : OxColors.text1))),
            Text(
              value,
              textDirection: TextDirection.ltr,
              style: t.small.copyWith(color: ready ? OxColors.ok : failed ? OxColors.errText : null),
            ),
          ],
        ),
        if (ready)
          Container(height: 3, decoration: BoxDecoration(color: OxColors.ok, borderRadius: BorderRadius.circular(3)))
        else
          OxProgressBar(value: fraction),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: OxColors.ink2, borderRadius: BorderRadius.circular(14), border: Border.all(color: OxColors.line)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: OxTypography.en.time.copyWith(fontSize: 16)),
            Text(label, style: context.oxText.caption),
          ],
        ),
      );
}
