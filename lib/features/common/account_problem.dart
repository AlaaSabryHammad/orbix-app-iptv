import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/network/connectivity.dart';
import '../../core/router/routes.dart';
import '../../core/session/session.dart';
import '../../data/data.dart';
import '../../shared/format/format.dart';
import '../../shared/widgets/widgets.dart';
import '../accounts/sync_controller.dart';

/// Why the active account can't be browsed right now (States 06–08).
enum AccountProblemKind { offline, server, expired, disabled, credentials }

typedef AccountProblem = ({AccountProblemKind kind, Account account, OrbixFailure? failure});

/// The blocking problem of the active account, if any. With a cached catalog
/// only an expired, disabled or rejected account blocks (the provider won't
/// stream); being offline or the server being down just shows the banner /
/// keeps the cached lists.
final accountProblemProvider = Provider<AccountProblem?>((ref) {
  final account = ref.watch(activeAccountProvider).value;
  if (account == null) return null;
  final online = ref.watch(onlineProvider).value ?? true;
  final failure = ref.watch(syncControllerProvider.select((m) => m[account.id]?.catalog.failure));
  final empty = account.liveCount + account.movieCount + account.seriesCount == 0;

  AccountProblem p(AccountProblemKind k) => (kind: k, account: account, failure: failure);
  switch (failure) {
    case AccountExpiredFailure():
      return p(AccountProblemKind.expired);
    case AccountDisabledFailure():
      return p(AccountProblemKind.disabled);
    case InvalidCredentialsFailure():
      return p(AccountProblemKind.credentials);
    default:
  }
  if (account.status == AccountStatus.expired) return p(AccountProblemKind.expired);
  if (account.status == AccountStatus.disabled) return p(AccountProblemKind.disabled);
  if (!empty) return null;
  if (!online || failure is OfflineFailure) return p(AccountProblemKind.offline);
  return switch (failure) {
    HostNotFoundFailure() || ConnectionRefusedFailure() || ServerTimeoutFailure() || ServerErrorFailure() || AccessDeniedFailure() || TlsFailure() || NotIptvServerFailure() || UnknownFailure() =>
      p(AccountProblemKind.server),
    _ => null,
  };
});

/// States 06 — amber "No connection" strip across the top of the app.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(onlineProvider).value ?? true;
    final top = MediaQuery.paddingOf(context).top;
    final t = context.oxText;
    return Column(
      children: [
        AnimatedSize(
          duration: OxMotion.base,
          curve: OxMotion.easeOut,
          child: online
              ? const SizedBox(width: double.infinity)
              : Semantics(
                  liveRegion: true,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: top),
                    color: const Color(0xFF2A2210),
                    child: SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children: [
                          const OxIcon(OxIcons.wifiOff, size: OxIconSize.xs, color: OxColors.warn),
                          Text(context.l10n.offlineBanner, style: t.small.copyWith(fontSize: 12, fontWeight: FontWeight.w800, color: OxColors.warn)),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        Expanded(
          // The strip already covers the status bar.
          child: MediaQuery.removePadding(context: context, removeTop: !online, child: child),
        ),
      ],
    );
  }
}

/// Full-screen state for an [AccountProblem] (States 06, 07, 08 + rejected
/// sign-in), shown in place of the browse tabs.
class AccountProblemView extends ConsumerWidget {
  const AccountProblemView({super.key, required this.problem});

  final AccountProblem problem;

  void _retry(WidgetRef ref) => unawaited(ref.read(syncControllerProvider.notifier).start(problem.account));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final a = problem.account;
    final f = problem.failure;
    final switchAccount = OxButton(
      label: l.switchAccount,
      variant: OxButtonVariant.ghost,
      size: OxButtonSize.sm,
      onPressed: () => context.go(Routes.accounts),
    );

    final content = switch (problem.kind) {
      AccountProblemKind.offline => OxStateView(
          emblem: const OxStateEmblem(icon: OxIcons.wifiOff, background: Color(0x1AFFC65C), foreground: OxColors.warn),
          title: l.errorOffline,
          message: l.errorOfflineBody,
          actions: [
            OxButton(label: l.actionTryAgain, icon: OxIcons.refresh, onPressed: () {
              ref.invalidate(onlineProvider);
              _retry(ref);
            }),
            OxButton(label: l.networkSettings, variant: OxButtonVariant.ghost, size: OxButtonSize.sm, onPressed: openNetworkSettings),
          ],
        ),
      AccountProblemKind.server => _ServerDown(problem: problem, onRetry: () => _retry(ref), switchAccount: switchAccount),
      AccountProblemKind.expired || AccountProblemKind.disabled => OxStateView(
          emblem: const OxStateEmblem(icon: OxIcons.calendar, background: Color(0x1AFFC65C), foreground: OxColors.warn),
          title: problem.kind == AccountProblemKind.expired ? l.errorExpired : l.errorDisabled(f is AccountDisabledFailure ? f.status : l.statusDisabled),
          message: problem.kind == AccountProblemKind.disabled
              ? null
              : (_expiry(f, a) == null ? l.errorExpiredShort : l.errorExpiredBody(a.name, Fmt.date(context, _expiry(f, a)!))),
          actions: [
            OxButton(label: l.refreshStatus, icon: OxIcons.refresh, onPressed: () => _retry(ref)),
            OxButton(label: l.useAnotherAccount, variant: OxButtonVariant.ghost, size: OxButtonSize.sm, onPressed: () => context.go(Routes.accounts)),
          ],
          children: [
            _StatusRow(label: l.statusLabel, value: problem.kind == AccountProblemKind.expired ? l.statusExpired : l.statusDisabled),
          ],
        ),
      AccountProblemKind.credentials => OxStateView(
          emblem: const OxStateEmblem(icon: OxIcons.key, background: OxColors.errSoft, foreground: Color(0xFFFF8C8C)),
          title: l.signInFailedTitle,
          message: l.errorCredentials,
          actions: [
            OxButton(label: l.editAccount, icon: OxIcons.edit, onPressed: () => context.go(Routes.editAccount(a.id))),
            switchAccount,
          ],
        ),
    };

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(34, 34, 34, 34 + MediaQuery.paddingOf(context).bottom),
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400), child: content),
        ),
      ),
    );
  }

  static DateTime? _expiry(OrbixFailure? f, Account a) => f is AccountExpiredFailure ? (f.expiresAt ?? a.expiresAt) : a.expiresAt;
}

/// States 07 — provider down, with an automatic retry countdown.
class _ServerDown extends StatefulWidget {
  const _ServerDown({required this.problem, required this.onRetry, required this.switchAccount});

  final AccountProblem problem;
  final VoidCallback onRetry;
  final Widget switchAccount;

  @override
  State<_ServerDown> createState() => _ServerDownState();
}

class _ServerDownState extends State<_ServerDown> {
  static const _interval = 10;
  int _left = _interval;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_left <= 1) {
        _left = _interval;
        widget.onRetry();
      } else {
        _left--;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final f = widget.problem.failure;
    final host = switch (f) {
      ServerTimeoutFailure(:final host) || HostNotFoundFailure(:final host) || ConnectionRefusedFailure(:final host) || ServerErrorFailure(:final host) => host,
      _ => null,
    };
    return OxStateView(
      emblem: const OxStateEmblem(icon: OxIcons.server, background: Color(0x1AFF6B6B), foreground: Color(0xFFFF8C8C)),
      title: l.errorTimeout,
      message: f is ServerTimeoutFailure || f == null
          ? l.errorTimeoutBody(host ?? widget.problem.account.displayHost ?? widget.problem.account.name)
          : describeFailure(context, f),
      actions: [
        OxButton(label: l.retryNow, expand: true, onPressed: () {
          setState(() => _left = _interval);
          widget.onRetry();
        }),
        widget.switchAccount,
      ],
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFF101015), borderRadius: BorderRadius.circular(14), border: Border.all(color: OxColors.line)),
          child: Row(
            spacing: 10,
            children: [
              const OxOrbitLoader(size: 22),
              Expanded(child: Text(l.retryingAutomatically, style: t.small)),
              Text('0:${_left.toString().padLeft(2, '0')}', textDirection: TextDirection.ltr, style: OxTypography.en.time.copyWith(fontSize: 12, color: OxColors.emberHi)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF101015), borderRadius: BorderRadius.circular(14), border: Border.all(color: OxColors.line)),
      child: Row(
        children: [
          Expanded(child: Text(label, style: t.small)),
          Text(value, style: t.small.copyWith(fontWeight: FontWeight.w800, color: OxColors.warn)),
        ],
      ),
    );
  }
}
