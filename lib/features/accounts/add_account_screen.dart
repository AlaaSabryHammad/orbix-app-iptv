import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/build_flavor.dart';
import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/routes.dart';
import '../../core/session/session.dart';
import '../../core/settings/app_settings.dart';
import '../../data/core/ids.dart';
import '../../data/data.dart';
import '../../shared/format/format.dart';
import '../../shared/widgets/widgets.dart';
import '../dev/demo/demo_server.dart';
import 'sync_controller.dart';

enum SourceMode { xtream, m3u, file }

/// 05–06 Add IPTV account (Xtream / M3U / File) with the step-by-step
/// connection test. `?edit=<id>` edits an existing account.
class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key, this.editId});

  final String? editId;

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  SourceMode _mode = SourceMode.xtream;
  final _name = TextEditingController();
  final _server = TextEditingController();
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _epg = TextEditingController();
  final _m3uName = TextEditingController();
  final _m3uUrl = TextEditingController();
  final _m3uEpg = TextEditingController();
  String? _filePath;
  String? _fileName;
  bool _saveProfile = true;
  bool _epgOpen = false;
  final _errors = <String, String>{};

  ConnectionTest? _test;
  AccountCredentials? _testedFor;
  StreamSubscription<ConnectionTest>? _testSub;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    if (widget.editId != null) unawaited(_loadForEdit(widget.editId!));
  }

  Future<void> _loadForEdit(String id) async {
    final repo = ref.read(accountRepositoryProvider);
    final account = await repo.byId(id);
    final creds = await repo.credentials(id);
    if (!mounted || account == null) return;
    setState(() {
      switch (creds) {
        case XtreamCredentials():
          _mode = SourceMode.xtream;
          _name.text = account.name;
          _server.text = creds.serverUrl;
          _user.text = creds.username;
          _pass.text = creds.password;
          _epg.text = creds.epgUrl ?? '';
          _epgOpen = creds.epgUrl != null;
        case PlaylistCredentials():
          _mode = creds.filePath != null ? SourceMode.file : SourceMode.m3u;
          _m3uName.text = account.name;
          _m3uUrl.text = creds.playlistUrl ?? '';
          _m3uEpg.text = creds.epgUrl ?? '';
          _filePath = creds.filePath;
          _fileName = creds.filePath?.split(Platform.pathSeparator).last;
        case null:
          _name.text = account.name;
      }
    });
  }

  @override
  void dispose() {
    unawaited(_testSub?.cancel());
    for (final c in [_name, _server, _user, _pass, _epg, _m3uName, _m3uUrl, _m3uEpg]) {
      c.dispose();
    }
    super.dispose();
  }

  // --- Input → credentials ------------------------------------------------------------

  static bool _isUrl(String s) {
    final u = Uri.tryParse(s.contains('://') ? s : 'http://$s');
    return u != null && u.host.isNotEmpty;
  }

  /// Validates the form; returns credentials and the account name, or null.
  (AccountCredentials, String)? _collect() {
    final l = context.l10n;
    _errors.clear();
    String? opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    switch (_mode) {
      case SourceMode.xtream:
        if (!_isUrl(_server.text.trim())) _errors['server'] = _server.text.trim().isEmpty ? l.requiredField : l.invalidUrl;
        if (_user.text.trim().isEmpty) _errors['user'] = l.requiredField;
        if (_pass.text.isEmpty) _errors['pass'] = l.requiredField;
        final epg = opt(_epg);
        if (epg != null && !_isUrl(epg)) _errors['epg'] = l.invalidUrl;
        setState(() {});
        if (_errors.isNotEmpty) return null;
        final creds = XtreamCredentials(serverUrl: _server.text, username: _user.text.trim(), password: _pass.text, epgUrl: epg);
        return (creds, opt(_name) ?? creds.displayHost);
      case SourceMode.m3u:
      case SourceMode.file:
        final file = _mode == SourceMode.file;
        if (file && _filePath == null) _errors['file'] = l.requiredField;
        if (!file && !_isUrl(_m3uUrl.text.trim())) _errors['url'] = _m3uUrl.text.trim().isEmpty ? l.requiredField : l.invalidUrl;
        final epg = opt(_m3uEpg);
        if (epg != null && !_isUrl(epg)) _errors['m3uEpg'] = l.invalidUrl;
        setState(() {});
        if (_errors.isNotEmpty) return null;
        if (!file) {
          // An Xtream M3U link → use the Xtream API (details, short EPG…).
          final x = XtreamCredentials.tryFromPlaylistUrl(_m3uUrl.text.trim());
          if (x != null) {
            final creds = XtreamCredentials(serverUrl: x.serverUrl, username: x.username, password: x.password, epgUrl: epg);
            return (creds, opt(_m3uName) ?? creds.displayHost);
          }
        }
        final creds = PlaylistCredentials(playlistUrl: file ? null : _m3uUrl.text.trim(), filePath: file ? _filePath : null, epgUrl: epg);
        return (creds, opt(_m3uName) ?? creds.displayHost ?? _fileName ?? 'Playlist');
    }
  }

  static bool _same(AccountCredentials? a, AccountCredentials? b) => a != null && b != null && a.encode() == b.encode();

  // --- Test & connect --------------------------------------------------------------------

  Future<ConnectionTest?> _runTest(AccountCredentials creds) async {
    await _testSub?.cancel();
    final tester = ref.read(connectionTesterProvider);
    final done = Completer<ConnectionTest?>();
    setState(() {
      _test = null;
      _testedFor = creds;
    });
    final stream = switch (creds) {
      XtreamCredentials() => tester.testXtream(creds),
      PlaylistCredentials() => tester.testPlaylist(creds),
    };
    _testSub = stream.listen(
      (t) {
        if (!mounted) return;
        setState(() {
          _test = t;
          // States 09: the server answered, so its field is fine — the login isn't.
          if (t.failure is InvalidCredentialsFailure) {
            _errors['user'] = '';
            _errors['pass'] = context.l10n.passwordsCaseSensitive;
          }
        });
        if (t.done && !done.isCompleted) done.complete(t);
      },
      onDone: () {
        if (!done.isCompleted) done.complete(null);
      },
    );
    return done.future;
  }

  /// States 10 — "Couldn't connect" sheet: what happened, the technical
  /// line, and Edit details / Retry.
  Future<void> _showConnectFailure(OrbixFailure f) async {
    final retry = await showOxSheet<bool>(context, builder: (s) => _ConnectFailureSheet(failure: f));
    // "Edit details" just closes the sheet: the form is right behind it.
    if (mounted && (retry ?? false)) unawaited(_onConnect());
  }

  Future<void> _onTest() async {
    final input = _collect();
    if (input != null) await _runTest(input.$1);
  }

  Future<void> _onConnect() async {
    final input = _collect();
    if (input == null || _connecting) return;
    final (creds, name) = input;
    setState(() => _connecting = true);
    try {
      var test = _test;
      if (!(test?.succeeded ?? false) || !_same(_testedFor, creds)) test = await _runTest(creds);
      if (test == null || !test.succeeded || !mounted) {
        final f = test?.failure;
        // States 10: anything but a wrong login (shown inline, States 09).
        if (mounted && f != null && f is! InvalidCredentialsFailure) unawaited(_showConnectFailure(f));
        return;
      }

      final repo = ref.read(accountRepositoryProvider);
      final kind = switch (creds) {
        XtreamCredentials() => AccountKind.xtream,
        PlaylistCredentials(:final isFile) => isFile ? AccountKind.file : AccountKind.m3u,
      };
      Account account;
      if (widget.editId != null) {
        await repo.rename(widget.editId!, name);
        await repo.updateCredentials(widget.editId!, creds);
        if (test.accountInfo != null) await repo.updateStatus(widget.editId!, test.accountInfo!);
        account = (await repo.byId(widget.editId!))!;
      } else {
        account = await repo.create(name: name, kind: kind, credentials: creds, info: test.accountInfo);
        if (!_saveProfile) {
          await ref.read(appSettingsProvider.notifier).update((s) => s.copyWith(temporaryAccountIds: [...s.temporaryAccountIds, account.id]));
        }
      }
      unawaited(ref.read(syncControllerProvider.notifier).start(account, prefetched: test.catalog));
      await ref.read(sessionProvider).select(account.id);
      if (mounted) context.go(Routes.accountSetup(account.id));
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _pickFile() async {
    final picked = await FilePicker.pickFile();
    if (picked == null) return;
    // Android hands out content:// URIs — read the bytes, keep our own copy.
    final stored = await PlaylistFiles.importBytes(await picked.xFile.readAsBytes(), name: newId());
    if (!mounted) return;
    setState(() {
      _mode = SourceMode.file;
      _filePath = stored;
      _fileName = picked.name;
      _errors.remove('file');
      if (_m3uName.text.isEmpty) _m3uName.text = _fileName!.replaceAll(RegExp(r'\.m3u8?$', caseSensitive: false), '');
    });
  }

  void _fillDemo() => setState(() {
    _mode = SourceMode.xtream;
    _name.text = 'Living Room';
    _server.text = DemoServer.serverUrl;
    _user.text = DemoServer.username;
    _pass.text = DemoServer.password;
    _errors.clear();
  });

  void _closeTest() {
    unawaited(_testSub?.cancel());
    setState(() {
      _test = null;
      _testedFor = null;
    });
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      final hasAccounts = (ref.read(accountsProvider).value ?? const []).isNotEmpty;
      context.go(hasAccounts ? Routes.accounts : Routes.welcome);
    }
  }

  // --- UI ----------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final saved = ref.watch(accountsProvider).value?.length ?? 0;
    final test = _test;
    final credError = test?.failure is InvalidCredentialsFailure;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          OxAmbient(
            color: _mode == SourceMode.xtream ? OxColors.ember : OxColors.halo,
            size: const Size(300, 220),
            opacity: _mode == SourceMode.xtream ? 0.16 : 0.1,
            right: _mode == SourceMode.xtream ? -48 : null,
            left: _mode == SourceMode.xtream ? null : -60,
            top: _mode == SourceMode.xtream ? -60 : 560,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 16, 0),
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        OxIconButton(icon: OxIcons.back, semanticLabel: l.actionBack, onPressed: _back),
                        const Spacer(),
                        if (saved > 0) SizedBox(height: 26, child: OxBadge(l.savedProfiles(saved))),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                        children: [
                          Semantics(header: true, child: Text(l.addAccountTitle, style: t.h1.copyWith(fontSize: 26))),
                          const SizedBox(height: 8),
                          Text(l.addAccountIntro, style: t.body),
                          if (isDevFlavor && widget.editId == null) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: OxChip(label: l.useDemoProvider, icon: OxIcons.play, small: true, tone: OxChipTone.ember, onTap: _fillDemo),
                            ),
                          ],
                          const SizedBox(height: 22),
                          OxSegmented<SourceMode>(
                            segments: [
                              OxSegment(SourceMode.xtream, l.sourceXtream, icon: OxIcons.server),
                              OxSegment(SourceMode.m3u, l.sourceM3u, icon: OxIcons.playlist),
                              OxSegment(SourceMode.file, l.sourceFile, icon: OxIcons.file),
                            ],
                            selected: _mode,
                            onChanged: (m) => setState(() {
                              _mode = m;
                              _errors.clear();
                            }),
                          ),
                          const SizedBox(height: 22),
                          if (credError) ...[_ErrorCallout(text: l.errorCredentials), const SizedBox(height: 16)],
                          ..._mode == SourceMode.xtream ? _xtreamFields(l, t) : _playlistFields(l, t),
                        ],
                      ),
                    ),
                  ),
                ),
                if (test == null)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                        child: Row(
                          spacing: 12,
                          children: [
                            Expanded(
                              child: OxButton(label: l.actionTest, icon: OxIcons.signal, variant: OxButtonVariant.tonal, expand: true, onPressed: _onTest),
                            ),
                            Expanded(
                              child: OxButton(label: l.actionConnect, expand: true, onPressed: _connecting ? null : _onConnect),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (test != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.viewPaddingOf(context).bottom,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: _TestPanel(test: test, connecting: _connecting, onCancel: _closeTest, onRetry: _onTest, onConnect: _onConnect),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _xtreamFields(AppLocalizations l, OxTypography t) => [
    OxTextField(label: l.fieldAccountName, hint: 'Living Room', controller: _name, leadingIcon: OxIcons.user, textInputAction: TextInputAction.next),
    const SizedBox(height: 16),
    OxTextField(
      label: l.fieldServerUrl,
      hint: 'http://line.yourprovider.tv:8080',
      controller: _server,
      leadingIcon: OxIcons.link,
      ltr: true,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.next,
      status: _errors.containsKey('server') ? OxFieldStatus.error : (_test?.failure is InvalidCredentialsFailure ? OxFieldStatus.valid : OxFieldStatus.none),
      message: _errors['server'],
    ),
    const SizedBox(height: 16),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Expanded(
          child: OxTextField(
            label: l.fieldUsername,
            controller: _user,
            ltr: true,
            autofillHints: const [AutofillHints.username],
            textInputAction: TextInputAction.next,
            status: _errors.containsKey('user') ? OxFieldStatus.error : OxFieldStatus.none,
            message: (_errors['user']?.isEmpty ?? true) ? null : _errors['user'],
          ),
        ),
        Expanded(
          child: OxTextField(
            label: l.fieldPassword,
            controller: _pass,
            obscure: true,
            ltr: true,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _onConnect(),
            status: _errors.containsKey('pass') ? OxFieldStatus.error : OxFieldStatus.none,
            message: _errors['pass'],
          ),
        ),
      ],
    ),
    const SizedBox(height: 16),
    _EpgCard(
      open: _epgOpen,
      onToggle: () => setState(() => _epgOpen = !_epgOpen),
      child: OxTextField(
        hint: 'https://epg.yourprovider.tv/guide.xml',
        controller: _epg,
        leadingIcon: OxIcons.epg,
        ltr: true,
        keyboardType: TextInputType.url,
        status: _errors.containsKey('epg') ? OxFieldStatus.error : OxFieldStatus.none,
        message: _errors['epg'],
      ),
    ),
    if (widget.editId == null) ...[
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          spacing: 12,
          children: [
            const OxIcon(OxIcons.shield, size: OxIconSize.sm, color: OxColors.ok),
            Expanded(child: Text(l.saveProfileEncrypted, style: t.small)),
            OxSwitch(value: _saveProfile, onChanged: (v) => setState(() => _saveProfile = v), semanticLabel: l.saveProfileEncrypted),
          ],
        ),
      ),
    ],
  ];

  List<Widget> _playlistFields(AppLocalizations l, OxTypography t) {
    final file = _mode == SourceMode.file;
    return [
      OxTextField(label: l.fieldPlaylistName, hint: 'Travel Pack', controller: _m3uName, textInputAction: TextInputAction.next),
      const SizedBox(height: 18),
      if (!file) ...[
        OxTextField(
          label: l.fieldM3uUrl,
          hint: 'https://lists.yourprovider.tv/get.php?type=m3u_plus',
          controller: _m3uUrl,
          leadingIcon: OxIcons.link,
          ltr: true,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          status: _errors.containsKey('url') ? OxFieldStatus.error : OxFieldStatus.none,
          message: _errors['url'],
        ),
        const SizedBox(height: 18),
      ],
      OxTextField(
        label: l.fieldEpgUrlXmltv,
        hint: 'https://epg.yourprovider.tv/guide.xml',
        controller: _m3uEpg,
        leadingIcon: OxIcons.epg,
        ltr: true,
        keyboardType: TextInputType.url,
        status: _errors.containsKey('m3uEpg') ? OxFieldStatus.error : OxFieldStatus.none,
        message: _errors['m3uEpg'],
      ),
      const SizedBox(height: 18),
      if (!file)
        Row(
          spacing: 12,
          children: [
            const Expanded(child: Divider()),
            Text(l.or, style: t.caption),
            const Expanded(child: Divider()),
          ],
        ),
      if (!file) const SizedBox(height: 18),
      _FileButton(title: _fileName ?? l.chooseLocalFile, subtitle: l.chooseLocalFileHint, picked: _fileName != null, error: _errors['file'], onTap: _pickFile),
    ];
  }
}

class _ErrorCallout extends StatelessWidget {
  const _ErrorCallout({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0x1AFF6B6B),
      borderRadius: BorderRadius.circular(OxRadius.md),
      border: Border.all(color: const Color(0x59FF6B6B)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        const OxIcon(OxIcons.alert, size: OxIconSize.md, color: OxColors.errText),
        Expanded(
          child: Text(text, style: context.oxText.small.copyWith(color: const Color(0xFFFFD6D6))),
        ),
      ],
    ),
  );
}

/// Collapsible "EPG URL · optional" card.
class _EpgCard extends StatelessWidget {
  const _EpgCard({required this.open, required this.onToggle, required this.child});

  final bool open;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    return Container(
      decoration: BoxDecoration(
        color: OxColors.ink2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OxColors.line),
      ),
      child: Column(
        children: [
          OxPressable(
            onTap: onToggle,
            pressedScale: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                spacing: 12,
                children: [
                  const OxIcon(OxIcons.epg, size: OxIconSize.md, color: OxColors.halo),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: '${l.epgOptionalTitle} '),
                              TextSpan(
                                text: l.epgOptionalTag,
                                style: const TextStyle(color: OxColors.text3, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          style: t.title.copyWith(fontSize: 14),
                        ),
                        Text(l.epgOptionalHint, style: t.caption),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: OxMotion.base,
                    child: const OxIcon(OxIcons.chevD, size: OxIconSize.sm, color: OxColors.text3),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: OxMotion.base,
            curve: OxMotion.easeOut,
            child: open ? Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 12), child: child) : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _FileButton extends StatelessWidget {
  const _FileButton({required this.title, required this.subtitle, required this.picked, required this.onTap, this.error});

  final String title;
  final String subtitle;
  final bool picked;
  final String? error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    return OxPressable.builder(
      onTap: onTap,
      builder: (context, s) => CustomPaint(
        painter: _DashedRect(color: error != null ? OxColors.errText : (picked ? OxColors.okBorder : const Color(0x2EFFFFFF))),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: const Color(0x05FFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: s.focused ? oxFocusRing : null),
          child: Row(
            spacing: 14,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: OxColors.ink4, borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: OxIcon(picked ? OxIcons.file : OxIcons.upload, size: OxIconSize.md, color: picked ? OxColors.ok : null),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OxContentText(title, style: t.title.copyWith(fontSize: 14)),
                    Text(error ?? subtitle, style: t.caption.copyWith(color: error != null ? OxColors.errText : null)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRect extends CustomPainter {
  _DashedRect({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 9) {
        canvas.drawPath(m.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRect old) => old.color != color;
}

/// The glass "Testing connection…" panel with its step list.
class _TestPanel extends StatelessWidget {
  const _TestPanel({required this.test, required this.connecting, required this.onCancel, required this.onRetry, required this.onConnect});

  final ConnectionTest test;
  final bool connecting;
  final VoidCallback onCancel;
  final VoidCallback onRetry;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final failed = test.failure != null;
    final ok = test.succeeded;

    final (String title, String caption, Widget lead) = failed
        ? (l.testFailed, describeFailure(context, test.failure!), const _StatusDot(state: TestStepState.failed, size: 40))
        : ok
        ? (l.testPassed, l.testPassedHint, const _StatusDot(state: TestStepState.done, size: 40))
        : (l.testingConnection, l.testingHint, const OxOrbitLoader(size: 40));

    return Semantics(
      liveRegion: true,
      child: OxGlass(
        borderRadius: BorderRadius.circular(26),
        shadows: OxShadows.e2,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Row(
              spacing: 14,
              children: [
                lead,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: t.title),
                      Text(caption, style: t.caption.copyWith(color: failed ? OxColors.errText : null)),
                    ],
                  ),
                ),
                if (!test.done) OxButton(label: l.actionCancel, variant: OxButtonVariant.ghost, size: OxButtonSize.sm, onPressed: onCancel),
              ],
            ),
            Column(spacing: 12, children: [for (final s in test.steps) _StepRow(step: s)]),
            if (failed && failureDetail(test.failure!) != null) Text(failureDetail(test.failure!)!, textDirection: TextDirection.ltr, style: t.caption),
            if (test.done)
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: OxButton(
                      label: failed ? l.actionEditDetails : l.actionCancel,
                      variant: OxButtonVariant.tonal,
                      size: OxButtonSize.sm,
                      expand: true,
                      onPressed: onCancel,
                    ),
                  ),
                  Expanded(
                    child: failed
                        ? OxButton(label: l.actionRetry, size: OxButtonSize.sm, expand: true, onPressed: onRetry)
                        : OxButton(label: l.actionConnect, size: OxButtonSize.sm, expand: true, onPressed: connecting ? null : onConnect),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step});

  final TestStep step;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final label = switch (step.id) {
      TestStepId.reach => l.stepReach,
      TestStepId.signIn => l.stepSignIn,
      TestStepId.download => l.stepDownload,
      TestStepId.read => l.stepRead,
      TestStepId.guide => l.stepGuide,
    };
    final running = step.state == TestStepState.running;
    final value = switch (step.state) {
      TestStepState.waiting => l.stepWaiting,
      TestStepState.skipped => l.stepSkipped,
      TestStepState.failed when step.id == TestStepId.guide => l.stepGuideBroken,
      _ => switch (step.id) {
        TestStepId.reach => step.latency == null ? '' : '${step.latency!.inMilliseconds} ms',
        TestStepId.download => step.bytes == null ? '' : Fmt.bytes(step.bytes!),
        TestStepId.read => step.count == null ? '' : Fmt.count(step.count!),
        _ => '',
      },
    };
    final dim = step.state == TestStepState.waiting || step.state == TestStepState.skipped;
    final total = step.total;
    final showBar = running && step.id == TestStepId.download && total != null && step.bytes != null;

    return Opacity(
      opacity: dim ? 0.55 : 1,
      child: Column(
        spacing: 8,
        children: [
          Row(
            spacing: 12,
            children: [
              _StatusDot(state: step.state),
              Expanded(
                child: Text(label, style: t.small.copyWith(color: dim ? null : OxColors.text1)),
              ),
              Text(
                value,
                textDirection: TextDirection.ltr,
                style: t.caption.copyWith(color: running ? OxColors.emberHi : null),
              ),
            ],
          ),
          if (showBar)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 34),
              child: OxProgressBar(value: step.bytes! / total),
            ),
        ],
      ),
    );
  }
}

/// 22 dp step status: green check, ember spinner, red alert, empty ring.
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.state, this.size = 22});

  final TestStepState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final glyph = size > 30 ? OxIconSize.md : OxIconSize.xs;
    return SizedBox.square(
      dimension: size,
      child: switch (state) {
        TestStepState.done => DecoratedBox(
          decoration: const BoxDecoration(color: Color(0x295BD69B), shape: BoxShape.circle),
          child: Center(
            child: OxIcon(OxIcons.check, size: glyph, color: OxColors.ok),
          ),
        ),
        TestStepState.failed => DecoratedBox(
          decoration: const BoxDecoration(color: Color(0x29FF6B6B), shape: BoxShape.circle),
          child: Center(
            child: OxIcon(OxIcons.close, size: glyph, color: OxColors.errText),
          ),
        ),
        TestStepState.running => OxSpinner(size: size, strokeWidth: 2),
        TestStepState.waiting || TestStepState.skipped => DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x40FFFFFF), width: 2),
          ),
        ),
      },
    );
  }
}

class _ConnectFailureSheet extends StatelessWidget {
  const _ConnectFailureSheet({required this.failure});

  final OrbixFailure failure;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final detail = failureDetail(failure);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.only(top: 8),
              alignment: Alignment.center,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x1FFF6B6B)),
              child: const OxIcon(OxIcons.close, size: OxIconSize.xl, color: Color(0xFFFF8C8C)),
            ),
          ),
          Text(l.testFailed, textAlign: TextAlign.center, style: t.h1.copyWith(fontSize: 20)),
          Text(describeFailure(context, failure), textAlign: TextAlign.center, style: t.body.copyWith(fontSize: 13)),
          if (detail != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFF0B0B0F), borderRadius: BorderRadius.circular(12)),
              child: Text(
                detail,
                textDirection: TextDirection.ltr,
                style: OxTypography.en.time.copyWith(fontSize: 11.5, color: OxColors.text2),
              ),
            ),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: OxButton(label: l.actionEditDetails, variant: OxButtonVariant.tonal, expand: true, onPressed: () => Navigator.pop(context, false)),
              ),
              Expanded(
                child: OxButton(label: l.actionRetry, icon: OxIcons.refresh, expand: true, onPressed: () => Navigator.pop(context, true)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
