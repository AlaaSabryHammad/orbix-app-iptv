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
import 'account_avatar.dart';
import 'sync_controller.dart';

/// 07 Choose an account. Tap to open; long-press (or Edit) for
/// Edit / Set as default / Delete.
class ProfilesScreen extends ConsumerStatefulWidget {
  const ProfilesScreen({super.key});

  @override
  ConsumerState<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends ConsumerState<ProfilesScreen> {
  bool _editing = false;

  Future<void> _open(Account a) async {
    await ref.read(sessionProvider).select(a.id);
    unawaited(ref.read(syncControllerProvider.notifier).refreshIfStale(a));
    if (mounted) context.go(Routes.start(ref.read(appSettingsProvider).startScreen));
  }

  Future<void> _menu(Account a) async {
    final l = context.l10n;
    final action = await showOxSheet<String>(
      context,
      title: a.name,
      builder: (s) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OxSheetOption(icon: OxIcons.edit, label: l.editAccount, onTap: () => Navigator.pop(s, 'edit')),
          if (!a.isDefault) OxSheetOption(icon: OxIcons.star, label: l.setAsDefault, onTap: () => Navigator.pop(s, 'default')),
          _DangerOption(label: l.actionDelete, onTap: () => Navigator.pop(s, 'delete')),
        ],
      ),
    );
    if (!mounted) return;
    switch (action) {
      case 'edit':
        await context.push(Routes.editAccount(a.id));
      case 'default':
        await ref.read(accountRepositoryProvider).setDefault(a.id);
      case 'delete':
        await _delete(a);
    }
  }

  Future<void> _delete(Account a) async {
    final l = context.l10n;
    final ok = await showOxDialog<bool>(
      context,
      builder: (d) => OxDialog(
        icon: OxIcons.trash,
        tone: OxDialogTone.danger,
        title: l.deleteAccountTitle(a.name),
        message: l.deleteAccountBody,
        actions: [
          OxButton(label: l.actionCancel, variant: OxButtonVariant.ghost, size: OxButtonSize.sm, onPressed: () => Navigator.pop(d, false)),
          OxButton(label: l.actionDelete, variant: OxButtonVariant.destructive, size: OxButtonSize.sm, onPressed: () => Navigator.pop(d, true)),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(accountRepositoryProvider).delete(a.id);
    if (ref.read(activeAccountIdProvider) == a.id) await ref.read(sessionProvider).clear();
    if (mounted) showOxSnack(context, message: l.accountDeleted, icon: OxIcons.trash, iconColor: OxColors.live);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final settings = ref.watch(appSettingsProvider);
    final primary = accounts.where((a) => a.isDefault).firstOrNull ?? accounts.firstOrNull;
    final wide = MediaQuery.sizeOf(context).width >= OxBreakpoints.medium;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(0, -1), radius: 1.1, colors: [Color(0xFF1A1210), OxColors.ink1], stops: [0, 0.7]),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(24, 6, 12, 0),
                    child: SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          const OxBrandLockup(),
                          const Spacer(),
                          OxButton(
                            label: _editing ? l.actionDone : l.actionEdit,
                            icon: _editing ? OxIcons.check : OxIcons.edit,
                            variant: OxButtonVariant.ghost,
                            size: OxButtonSize.sm,
                            onPressed: () => setState(() => _editing = !_editing),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 46, 24, 24),
                      children: [
                        Semantics(header: true, child: Text(l.profilesTitle, textAlign: TextAlign.center, style: t.display)),
                        const SizedBox(height: 8),
                        Text(l.profilesSubtitle, textAlign: TextAlign.center, style: t.body),
                        const SizedBox(height: 40),
                        LayoutBuilder(
                          builder: (context, c) {
                            final cols = wide ? 4 : 3;
                            final w = (c.maxWidth - 14 * (cols - 1)) / cols;
                            return Wrap(
                              spacing: 14,
                              runSpacing: 26,
                              alignment: WrapAlignment.center,
                              children: [
                                for (final a in accounts)
                                  SizedBox(
                                    width: w,
                                    child: _AccountTile(
                                      account: a,
                                      selected: a.id == primary?.id,
                                      editing: _editing,
                                      onTap: () => _editing ? _menu(a) : _open(a),
                                      onLongPress: () => _menu(a),
                                    ),
                                  ),
                                SizedBox(width: w, child: _AddTile(onTap: () => context.push(Routes.addAccount))),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      spacing: 14,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: OxColors.ink2, borderRadius: BorderRadius.circular(20), border: Border.all(color: OxColors.line)),
                          child: Row(
                            spacing: 12,
                            children: [
                              const OxIcon(OxIcons.autoplay, size: OxIconSize.md, color: OxColors.ember),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l.openDefaultOnLaunch, style: t.title.copyWith(fontSize: 14)),
                                    Text(l.openDefaultOnLaunchHint, style: t.caption),
                                  ],
                                ),
                              ),
                              OxSwitch(
                                value: settings.openDefaultOnLaunch,
                                semanticLabel: l.openDefaultOnLaunch,
                                onChanged: (v) => ref.read(appSettingsProvider.notifier).update((s) => s.copyWith(openDefaultOnLaunch: v)),
                              ),
                            ],
                          ),
                        ),
                        if (primary != null)
                          OxButton(
                            label: l.continueWith(primary.name),
                            icon: OxIcons.play,
                            size: OxButtonSize.lg,
                            expand: true,
                            onPressed: () => _open(primary),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account, required this.selected, required this.editing, required this.onTap, required this.onLongPress});

  final Account account;
  final bool selected;
  final bool editing;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final g = accountGradient(account.id);
    final mono = OxChannelLogo.initialsOf(account.name);
    final kind = switch (account.kind) {
      AccountKind.xtream => l.kindXtream,
      AccountKind.m3u => l.kindM3u,
      AccountKind.file => l.kindFile,
    };
    final subtitle = account.status == AccountStatus.expired
        ? l.errorExpired
        : Fmt.relative(context, account.lastUsedAt);

    return OxPressable.builder(
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: '${account.name}, $kind',
      builder: (context, s) => Column(
        spacing: 10,
        children: [
          AnimatedContainer(
            duration: OxMotion.base,
            width: 108,
            height: 108,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(begin: const Alignment(-0.6, -1), end: const Alignment(0.6, 1), colors: g),
              boxShadow: [
                if (selected || s.focused) ...[
                  BoxShadow(color: s.focused ? OxColors.text1 : OxColors.ember, spreadRadius: 5),
                  const BoxShadow(color: OxColors.ink1, spreadRadius: 3),
                  if (!s.focused) const BoxShadow(color: Color(0xB3FF7A3D), blurRadius: 36, spreadRadius: -12, offset: Offset(0, 18)),
                ] else
                  const BoxShadow(color: Color(0xCC000000), blurRadius: 30, spreadRadius: -14, offset: Offset(0, 14)),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -30,
                  width: 90,
                  height: 90,
                  child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x47FFFFFF), width: 1.5))),
                ),
                const Positioned(
                  right: 26,
                  top: 8,
                  width: 10,
                  height: 10,
                  child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xD9FFFFFF))),
                ),
                Center(
                  child: Text(
                    mono,
                    textDirection: TextDirection.ltr,
                    style: OxTypography.en.h1.copyWith(fontSize: 30, color: const Color(0xFFFFFFFF), letterSpacing: -0.9, fontFamilyFallback: const [OxFonts.arabic]),
                  ),
                ),
                PositionedDirectional(
                  end: 8,
                  bottom: 8,
                  child: Container(
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: const Color(0x73000000), borderRadius: BorderRadius.circular(6)),
                    child: Text(kind, style: TextStyle(fontFamily: OxFonts.ui, fontWeight: FontWeight.w800, fontSize: 9.5, letterSpacing: t.isArabic ? 0 : 0.57, color: const Color(0xFFFFFFFF), height: 1)),
                  ),
                ),
                if (account.isDefault)
                  PositionedDirectional(
                    start: 8,
                    bottom: 8,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(color: const Color(0x73000000), borderRadius: BorderRadius.circular(9)),
                      child: const Center(child: OxIcon(OxIcons.star, size: OxIconSize.xs, color: OxColors.warn)),
                    ),
                  ),
                if (editing)
                  const Positioned.fill(
                    child: ColoredBox(color: Color(0x66000000), child: Center(child: OxIcon(OxIcons.more, color: Color(0xFFFFFFFF)))),
                  ),
              ],
            ),
          ),
          Column(
            spacing: 2,
            children: [
              OxContentText(account.name, align: TextAlign.center, style: t.title.copyWith(fontSize: 14)),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.caption.copyWith(color: account.status == AccountStatus.expired ? OxColors.warn : null)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    return OxPressable(
      onTap: onTap,
      semanticLabel: l.addAccount,
      child: Column(
        spacing: 10,
        children: [
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0x38FFFFFF), width: 1.5)),
            child: const Center(child: OxIcon(OxIcons.plus, size: OxIconSize.xl, color: OxColors.text2)),
          ),
          Column(
            spacing: 2,
            children: [
              Text(l.addAccount, style: t.title.copyWith(fontSize: 14, color: OxColors.text2)),
              Text(l.addAccountTypes, style: t.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _DangerOption extends StatelessWidget {
  const _DangerOption({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OxPressable(
        onTap: onTap,
        pressedScale: 0.985,
        child: Container(
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0x14FF6B6B), borderRadius: BorderRadius.circular(14)),
          child: Row(
            spacing: 14,
            children: [
              const OxIcon(OxIcons.trash, size: OxIconSize.sm, color: OxColors.errText),
              Expanded(child: Text(label, style: context.oxText.title.copyWith(fontSize: 14, color: OxColors.errText))),
            ],
          ),
        ),
      );
}
