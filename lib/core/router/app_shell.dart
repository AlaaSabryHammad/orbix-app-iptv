import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounts/sync_controller.dart';
import '../../features/common/account_problem.dart';
import '../../shared/widgets/widgets.dart';
import '../design/design.dart';
import '../l10n/l10n.dart';
import '../network/connectivity.dart';
import '../session/session.dart';
import 'routes.dart';

/// Adaptive navigation chrome around the shell branches:
/// floating glass bottom nav <600 dp, navigation rail ≥600 dp.
///
/// On phones the bar floats over content, so the shell adds its height to the
/// bottom [MediaQuery] padding — scroll views and SafeAreas inside the
/// branches clear it automatically — and publishes it via [OxChromeInsets]
/// so snackbars rise above it.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _go(AppDestination d) {
    final index = d.index;
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  /// Back online → retry a sync that failed offline; a refresh that added
  /// channels → "Playlist updated · 12 new channels".
  void _listen(BuildContext context, WidgetRef ref) {
    ref.listen(onlineProvider, (prev, next) {
      if (prev?.value == false && next.value == true) {
        final a = ref.read(activeAccountProvider).value;
        if (a != null) unawaited(ref.read(syncControllerProvider.notifier).retryAfterReconnect(a));
      }
    });
    final id = ref.watch(activeAccountIdProvider);
    ref.listen(syncControllerProvider.select((m) => m[id]?.newChannels), (prev, next) {
      if (next != null && next > 0 && prev != next) {
        showOxSnack(context, message: context.l10n.playlistUpdated(next), icon: OxIcons.playlist, iconColor: const Color(0xFF2F6FB0));
      }
    });
  }

  /// The tab content, covered by the account's blocking problem (States
  /// 06–08) everywhere but Settings, which stays usable.
  Widget _content(WidgetRef ref, AppDestination current) {
    final problem = ref.watch(accountProblemProvider);
    if (problem == null || current == AppDestination.settings) return shell;
    return Stack(
      children: [
        shell,
        Positioned.fill(child: AccountProblemView(problem: problem)),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = AppDestination.values[shell.currentIndex];
    _listen(context, ref);
    final content = _content(ref, current);

    if (OxWindowSize.of(context).hasNavRail) {
      final main = AppDestination.values.where((d) => d != AppDestination.settings).toList();
      final railIndex = current == AppDestination.settings ? main.length : main.indexOf(current);
      return Scaffold(
        body: OfflineBanner(
          child: Row(
            children: [
              OxNavRail(
                items: [for (final d in main) OxNavItem(icon: d.icon, label: d.label(context, rail: true))],
                footer: [OxNavItem(icon: AppDestination.settings.icon, label: AppDestination.settings.label(context, rail: true))],
                currentIndex: railIndex,
                onTap: (i) => _go(i < main.length ? main[i] : AppDestination.settings),
              ),
              Expanded(
                // The rail already consumed the start inset.
                child: MediaQuery.removePadding(
                  context: context,
                  removeLeft: Directionality.of(context) == TextDirection.ltr,
                  removeRight: Directionality.of(context) == TextDirection.rtl,
                  child: content,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Guide has no bottom-nav slot on phones; it is reached from Live TV.
    final selected = AppDestination.phone.indexOf(current == AppDestination.guide ? AppDestination.live : current);
    final navSpace = OxBottomNav.occupiedHeight(context);
    final margin = OxBottomNav.marginOf(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: OfflineBanner(
        child: OxChromeInsets(
          bottom: navSpace,
          child: Stack(
            children: [
              // Insets are read inside the offline banner, which may own the top edge.
              Builder(
                builder: (context) {
                  final mq = MediaQuery.of(context);
                  return MediaQuery(data: mq.copyWith(padding: mq.padding.copyWith(bottom: navSpace)), child: content);
                },
              ),
              Positioned(
                left: margin.left,
                right: margin.right,
                bottom: margin.bottom,
                child: OxBottomNav(
                  items: [for (final d in AppDestination.phone) OxNavItem(icon: d.phoneIcon ?? d.icon, label: d.label(context, rail: false))],
                  currentIndex: selected,
                  onTap: (i) => _go(AppDestination.phone[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
