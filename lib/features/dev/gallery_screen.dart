import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/routes.dart';
import '../../shared/widgets/widgets.dart';
import 'dev_locale_toggle.dart';

/// Dev-only widget gallery — mirrors `Components.dc.html` (C1–C10) with the
/// real, interactive components. Sample copy is the spec's English demo data.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  static const _p = 'assets/demo';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cols = width >= 1200 ? 3 : (width >= 600 ? 2 : 1);
    final gutter = OxWindowSize.of(context).gutter;

    const c1 = _Kit(n: 'C1', title: 'Buttons', note: '50 / 38 / 56 dp', child: _Buttons());
    const c2 = _Kit(n: 'C2', title: 'Chips, badges & meta', child: _ChipsBadges());
    const c3 = _Kit(n: 'C3', title: 'Inputs & selection', child: _Inputs());
    const c4 = _Kit(n: 'C4', title: 'Posters & media cards', note: '2:3 · 16:9', child: _Media());
    const c5 = _Kit(n: 'C5', title: 'Progress & loaders', child: _Loaders());
    const c6 = _Kit(n: 'C6', title: 'Micro-interactions', note: 'Tap them', child: _Micro());
    const c7 = _Kit(n: 'C7', title: 'Navigation', note: 'Phone · tablet', child: _Navigation());
    const c8 = _Kit(n: 'C8', title: 'Dialog', child: _Dialogs());
    const c9 = _Kit(n: 'C9', title: 'Bottom sheet', child: _Sheets());
    const c10 = _Kit(n: 'C10', title: 'Snackbars', note: '4 s · above nav', child: _Snacks());

    // Column assignment follows the HTML board (3 columns), folded for 2 / 1.
    final columns = switch (cols) {
      3 => const [
        [c1, c2, c3],
        [c4, c5, c6],
        [c7, c8, c9, c10],
      ],
      2 => const [
        [c1, c2, c3, c7],
        [c4, c5, c6, c8, c9, c10],
      ],
      _ => const [
        [c1, c2, c3, c4, c5, c6, c7, c8, c9, c10],
      ],
    };

    return Scaffold(
      backgroundColor: OxColors.ink0,
      appBar: AppBar(
        leading: OxIconButton(
          icon: OxIcons.back,
          semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home),
        ),
        title: Text(context.l10n.devGallery),
        actions: [
          OxIconButton(
            icon: OxIcons.database,
            semanticLabel: 'Data layer check',
            onPressed: () => context.push(Routes.dataCheck),
          ),
          OxIconButton(
            icon: OxIcons.palette,
            semanticLabel: context.l10n.devFoundations,
            onPressed: () => context.push(Routes.foundations),
          ),
          const DevLocaleToggle(),
          const SizedBox(width: OxSpace.s8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(gutter, OxSpace.s16, gutter, OxSpace.s56 + MediaQuery.paddingOf(context).bottom),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            for (final col in columns)
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 24, children: col),
              ),
          ],
        ),
      ),
    );
  }
}

// --- scaffolding -------------------------------------------------------------

class _Kit extends StatelessWidget {
  const _Kit({required this.n, required this.title, required this.child, this.note});

  final String n;
  final String title;
  final String? note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OxSpace.s24),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0F),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x12FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 18,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 10,
            children: [
              Text(n, style: OxTypography.en.h1.copyWith(fontSize: 12, color: OxColors.emberHi)),
              Expanded(child: Text(title, style: OxTypography.en.h1.copyWith(fontSize: 17))),
              if (note != null) Text(note!, style: OxTypography.en.small.copyWith(fontSize: 12, color: OxColors.text3)),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _Lab extends StatelessWidget {
  const _Lab(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: OxTypography.en.overline.copyWith(fontSize: 10.5, letterSpacing: 10.5 * 0.14));
}

class _Wrap extends StatelessWidget {
  const _Wrap(this.children, {this.spacing = 10});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: spacing, runSpacing: spacing, crossAxisAlignment: WrapCrossAlignment.center, children: children);
}

void _toast(BuildContext context, String message) => showOxSnack(context, message: message, tone: OxSnackTone.info, icon: OxIcons.info);

// --- C1 Buttons ----------------------------------------------------------------

class _Buttons extends StatelessWidget {
  const _Buttons();

  @override
  Widget build(BuildContext context) {
    void tap(String s) => _toast(context, '$s pressed');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 18,
      children: [
        const _Lab('Variants'),
        _Wrap([
          OxButton(label: 'Play', icon: OxIcons.play, onPressed: () => tap('Play')),
          OxButton(label: 'Continue', variant: OxButtonVariant.light, onPressed: () => tap('Continue')),
          OxButton(label: 'More info', icon: OxIcons.info, variant: OxButtonVariant.glass, onPressed: () => tap('More info')),
          OxButton(label: 'Test', icon: OxIcons.signal, variant: OxButtonVariant.tonal, onPressed: () => tap('Test')),
          OxButton(label: 'Skip', variant: OxButtonVariant.ghost, onPressed: () => tap('Skip')),
          OxButton(label: 'Delete', icon: OxIcons.trash, variant: OxButtonVariant.danger, onPressed: () => tap('Delete')),
        ]),
        const _Lab('Sizes & states'),
        _Wrap([
          OxButton(label: 'Small', size: OxButtonSize.sm, onPressed: () {}),
          OxButton(label: 'Medium', onPressed: () {}),
          OxButton(label: 'Large', size: OxButtonSize.lg, onPressed: () {}),
        ]),
        _Wrap([
          OxButton(label: 'Press me', onPressed: () {}),
          OxButton(label: 'Tab to focus', onPressed: () {}),
          const OxButton(label: 'Disabled', onPressed: null),
        ]),
        OxButton(label: 'Block button', expand: true, onPressed: () {}),
        const _Lab('Icon buttons'),
        _Wrap([
          OxIconButton(icon: OxIcons.search, semanticLabel: 'Search', onPressed: () {}),
          OxIconButton(icon: OxIcons.filter, semanticLabel: 'Filter', variant: OxIconButtonVariant.tonal, onPressed: () {}),
          OxIconButton(icon: OxIcons.back, semanticLabel: 'Back', variant: OxIconButtonVariant.glass, onPressed: () {}),
          OxIconButton(
            icon: OxIcons.heartFill,
            semanticLabel: 'Favorite',
            variant: OxIconButtonVariant.tonal,
            round: true,
            color: OxColors.ember,
            onPressed: () {},
          ),
          OxIconButton(
            icon: OxIcons.play,
            semanticLabel: 'Play',
            variant: OxIconButtonVariant.accent,
            size: OxIconButtonSize.lg,
            round: true,
            onPressed: () {},
          ),
          OxIconButton(
            icon: OxIcons.pause,
            semanticLabel: 'Pause',
            variant: OxIconButtonVariant.scrim,
            size: OxIconButtonSize.xl,
            onPressed: () {},
          ),
        ]),
      ],
    );
  }
}

// --- C2 Chips, badges & meta ---------------------------------------------------

class _ChipsBadges extends StatefulWidget {
  const _ChipsBadges();

  @override
  State<_ChipsBadges> createState() => _ChipsBadgesState();
}

class _ChipsBadgesState extends State<_ChipsBadges> {
  int _chip = 0;
  bool _year = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 18,
      children: [
        const _Lab('Filter chips'),
        _Wrap(spacing: 8, [
          OxChip(label: 'All', selected: _chip == 0, onTap: () => setState(() => _chip = 0)),
          OxChip(label: 'Movies', selected: _chip == 1, onTap: () => setState(() => _chip = 1)),
          OxChip(label: 'Channels', icon: OxIcons.live, selected: _chip == 2, onTap: () => setState(() => _chip = 2)),
          OxChip(label: 'Genre', trailingIcon: OxIcons.chevD, onTap: () {}),
          if (_year)
            OxChip(label: '2026', tone: OxChipTone.ember, trailingIcon: OxIcons.close, onTap: () => setState(() => _year = false))
          else
            OxChip(label: '+ Year', onTap: () => setState(() => _year = true)),
          OxChip(label: 'Sports', icon: OxIcons.trending, count: '142', small: true, onTap: () {}),
        ]),
        const _Lab('Badges'),
        _Wrap(spacing: 8, [
          OxBadge.live(context),
          OxBadge.quality('4K'),
          OxBadge.quality('4K HDR'),
          OxBadge.quality('FHD'),
          OxBadge.quality('HD'),
          OxBadge.fresh(context),
          const OxBadge('16+'),
          OxBadge.pin(context),
        ]),
        _Wrap(spacing: 8, [OxBadge.live(context, dense: true), OxBadge.quality('FHD', dense: true), OxBadge.pin(context, dense: true)]),
        const _Lab('Metadata line'),
        const OxMetaLine([OxRating('8.6'), '2026', 'Sci-Fi · Drama', '2h 18m']),
      ],
    );
  }
}

// --- C3 Inputs & selection -------------------------------------------------------

class _Inputs extends StatefulWidget {
  const _Inputs();

  @override
  State<_Inputs> createState() => _InputsState();
}

class _InputsState extends State<_Inputs> {
  bool _on = true;
  bool _off = false;
  String _seg = 'xtream';
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 18,
      children: [
        const OxTextField(
          label: 'Default',
          hint: 'http://server:port',
          leadingIcon: OxIcons.link,
          ltr: true,
          keyboardType: TextInputType.url,
        ),
        const OxTextField(label: 'Focus me', initialValue: 'Living Room', leadingIcon: OxIcons.user),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Expanded(
              child: OxTextField(label: 'Valid', initialValue: 'living_room', status: OxFieldStatus.valid, ltr: true),
            ),
            Expanded(
              child: OxTextField(
                label: 'Error',
                initialValue: 'wrongpass',
                obscure: true,
                status: OxFieldStatus.error,
                message: 'Incorrect password',
                ltr: true,
              ),
            ),
          ],
        ),
        OxSearchField(hint: 'Channels, movies, series', onVoice: () => _toast(context, 'Voice search')),
        Row(
          spacing: 22,
          children: [
            Row(
              spacing: 10,
              children: [
                OxSwitch(value: _on, onChanged: (v) => setState(() => _on = v), semanticLabel: 'Sample switch A'),
                Text(_on ? 'On' : 'Off', style: type.small),
              ],
            ),
            Row(
              spacing: 10,
              children: [
                OxSwitch(value: _off, onChanged: (v) => setState(() => _off = v), semanticLabel: 'Sample switch B'),
                Text(_off ? 'On' : 'Off', style: type.small),
              ],
            ),
          ],
        ),
        OxSegmented<String>(
          segments: const [OxSegment('xtream', 'Xtream'), OxSegment('m3u', 'M3U'), OxSegment('file', 'File')],
          selected: _seg,
          onChanged: (v) => setState(() => _seg = v),
        ),
        OxTabs(
          labels: const ['Channels', 'Movies', 'Series'],
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

// --- C4 Posters & media cards --------------------------------------------------

class _Media extends StatefulWidget {
  const _Media();

  @override
  State<_Media> createState() => _MediaState();
}

class _MediaState extends State<_Media> {
  final _fav = <String>{'101', '102', '104'};

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    const p = GalleryScreen._p;
    Widget caption(String s) => Text(s, style: type.caption);
    void open(String s) => _toast(context, 'Open $s');
    void fav(String n) => setState(() => _fav.contains(n) ? _fav.remove(n) : _fav.add(n));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 18,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                spacing: 6,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OxPoster(
                    image: '$p/p-meridian.jpg',
                    badges: [OxBadge.quality('4K')],
                    onTap: () => open('poster'),
                    semanticLabel: 'The Last Meridian',
                  ),
                  caption('Default'),
                ],
              ),
            ),
            Expanded(
              child: Column(
                spacing: 6,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OxPoster(
                    image: '$p/p-irontide.jpg',
                    title: 'Iron Tide',
                    titleSize: 10,
                    badges: [OxBadge.fresh(context)],
                    onTap: () => open('poster'),
                  ),
                  caption('Titled'),
                ],
              ),
            ),
            Expanded(
              child: Column(
                spacing: 6,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OxPoster(image: '$p/p-northbound.jpg', progress: 0.58, onTap: () => open('poster'), semanticLabel: 'Northbound'),
                  caption('In progress'),
                ],
              ),
            ),
            Expanded(
              child: Column(
                spacing: 6,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OxPoster(image: '$p/b-neon.jpg', locked: true, onTap: () => open('PIN entry'), semanticLabel: 'Locked title'),
                  caption('Locked'),
                ],
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OxThumb(image: '$p/e-1.jpg', progress: 0.64, onTap: () => open('episode'), semanticLabel: 'Continue S2 E4'),
                  Text('Continue card', style: type.title.copyWith(fontSize: 13)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OxThumb(
                    image: '$p/b-stadium.jpg',
                    topStart: OxBadge.live(context),
                    bottomStart: const OxChannelLogo(name: 'Pulse Sports 1', size: 30, colors: [Color(0xFF2FBF71), Color(0xFF0E4A2B)]),
                    onTap: () => open('live channel'),
                    semanticLabel: 'Pulse Sports 1, live',
                  ),
                  Text('Live card', style: type.title.copyWith(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        const _Lab('Channel rows'),
        Column(
          spacing: 2,
          children: [
            OxChannelRow(
              number: '101',
              name: 'Meridian News',
              logoColors: OxChannelLogo.palette[0],
              quality: 'HD',
              programme: 'The Evening Bulletin · 20:00–21:00',
              progress: 0.75,
              favorite: _fav.contains('101'),
              onTap: () => open('Meridian News'),
              onFavoriteTap: () => fav('101'),
            ),
            OxChannelRow(
              number: '102',
              name: 'Pulse Sports 1',
              logoColors: OxChannelLogo.palette[1],
              quality: 'FHD',
              programme: 'Coastal FC vs Northern United',
              progress: 0.12,
              nowPlaying: true,
              favorite: _fav.contains('102'),
              onTap: () => open('Pulse Sports 1'),
              onFavoriteTap: () => fav('102'),
            ),
            OxChannelRow(
              number: '190',
              name: 'Late Night Cinema',
              logoColors: const [Color(0xFF5A5A6E), Color(0xFF1E1E28)],
              quality: 'HD',
              programme: 'Locked by parental control',
              progress: 0,
              locked: true,
              favorite: _fav.contains('190'),
              onTap: () => open('PIN entry'),
              onFavoriteTap: () => fav('190'),
            ),
          ],
        ),
        const _Lab('Channel tiles'),
        _Wrap([
          OxChannelTile(name: 'Meridian', logoColors: OxChannelLogo.palette[0], onTap: () {}),
          OxChannelTile(name: 'Cine Prime', logoColors: OxChannelLogo.palette[3], onTap: () {}),
          OxChannelTile(name: 'Kitezoo', logoColors: OxChannelLogo.palette[5], onTap: () {}),
          OxChannelTile(name: 'Wave', logoColors: OxChannelLogo.palette[6], onTap: () {}),
          OxChannelTile(name: 'Atlas Docs', onTap: () {}),
        ]),
      ],
    );
  }
}

// --- C5 Progress & loaders -------------------------------------------------------

class _Loaders extends StatelessWidget {
  const _Loaders();

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 18,
      children: [
        const Column(
          spacing: 12,
          children: [OxProgressBar(value: 0.64), OxProgressBar(value: 0.38, large: true), OxProgressBar(value: 0.75, halo: true)],
        ),
        _Wrap(spacing: 26, [
          const OxOrbitLoader(),
          const OxSpinner(),
          const OxEqualizer(height: 18),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              const OxLiveDot(),
              Text('Live now', style: type.title.copyWith(fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
        ]),
        const _Lab('Skeletons'),
        const Row(
          spacing: 12,
          children: [
            OxSkeleton(width: 84, height: 126, radius: OxRadius.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  OxSkeleton(height: 74, radius: OxRadius.md),
                  FractionallySizedBox(widthFactor: 0.7, child: OxSkeleton(height: 14)),
                  FractionallySizedBox(widthFactor: 0.45, child: OxSkeleton(height: 12)),
                ],
              ),
            ),
          ],
        ),
        const Row(
          spacing: 12,
          children: [
            OxSkeleton(width: 42, height: 42, radius: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  FractionallySizedBox(widthFactor: 0.5, child: OxSkeleton(height: 12)),
                  FractionallySizedBox(widthFactor: 0.8, child: OxSkeleton(height: 10)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --- C6 Micro-interactions -------------------------------------------------------

class _Micro extends StatefulWidget {
  const _Micro();

  @override
  State<_Micro> createState() => _MicroState();
}

class _MicroState extends State<_Micro> {
  bool _fav = false;

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    Widget cell(Widget child, String label) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(color: OxColors.ink2, borderRadius: BorderRadius.circular(18)),
        child: Column(
          spacing: 12,
          children: [
            SizedBox(height: 72, child: Center(child: child)),
            Text(label, textAlign: TextAlign.center, style: type.caption),
          ],
        ),
      ),
    );
    return Row(
      spacing: 12,
      children: [
        cell(
          OxFavoriteButton(value: _fav, onChanged: (v) => setState(() => _fav = v), size: OxIconSize.xl, dimension: 56),
          'Favorite pop\n900 ms spring',
        ),
        cell(
          OxPlayGlow(
            child: OxIconButton(
              icon: OxIcons.play,
              semanticLabel: 'Play',
              variant: OxIconButtonVariant.accent,
              round: true,
              dimension: 56,
              iconSize: OxIconSize.lg,
              onPressed: () {},
            ),
          ),
          'Play glow\n2.4 s loop',
        ),
        cell(
          SizedBox(
            width: 48,
            child: OxPoster(image: '${GalleryScreen._p}/p-avar.jpg', onTap: () {}, semanticLabel: 'Avar'),
          ),
          'Poster focus\nhover / Tab',
        ),
      ],
    );
  }
}

// --- C7 Navigation ---------------------------------------------------------------

class _Navigation extends StatefulWidget {
  const _Navigation();

  @override
  State<_Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<_Navigation> {
  int _bottom = 0;
  int _compact = 0;
  int _rail = 0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = [
      OxNavItem(icon: OxIcons.home, label: l.navHome),
      OxNavItem(icon: OxIcons.live, label: l.navLive),
      OxNavItem(icon: OxIcons.film, label: l.navMovies),
      OxNavItem(icon: OxIcons.series, label: l.navSeries),
      OxNavItem(icon: OxIcons.heart, label: l.navFavorites),
      OxNavItem(icon: OxIcons.user, label: l.navProfile),
    ];

    Widget overArt(bool compact, int index, ValueChanged<int> onTap) => ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: compact ? 90 : 100,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const OxImage('${GalleryScreen._p}/b-signal.jpg'),
            Positioned(
              left: 8,
              right: 8,
              bottom: compact ? 10 : 12,
              child: OxBottomNav(items: items, currentIndex: index, onTap: onTap, compact: compact),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 18,
      children: [
        overArt(false, _bottom, (i) => setState(() => _bottom = i)),
        const _Lab('Small phone (<380 dp)'),
        Center(child: SizedBox(width: 340, child: overArt(true, _compact, (i) => setState(() => _compact = i)))),
        const _Lab('Rail (≥600 dp) & top bar'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 420,
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  removeBottom: true,
                  removeLeft: true,
                  removeRight: true,
                  child: OxNavRail(
                    items: [
                      OxNavItem(icon: OxIcons.home, label: l.navHome),
                      OxNavItem(icon: OxIcons.live, label: l.navLive),
                      OxNavItem(icon: OxIcons.epg, label: l.navGuide),
                    ],
                    footer: [OxNavItem(icon: OxIcons.settings, label: l.navSettings)],
                    currentIndex: _rail,
                    onTap: (i) => setState(() => _rail = i),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: [
                  Container(
                    height: 56,
                    padding: const EdgeInsetsDirectional.only(start: 14, end: 6),
                    decoration: BoxDecoration(color: OxColors.ink2, borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      children: [
                        const OxLogoMark(size: 24),
                        // Sample sits in a narrow column on small phones — scale rather than overflow.
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerEnd,
                            child: Row(
                              children: [
                                OxIconButton(icon: OxIcons.search, semanticLabel: 'Search', dimension: 40, onPressed: () {}),
                                OxIconButton(icon: OxIcons.cast, semanticLabel: 'Cast', dimension: 40, onPressed: () {}),
                                OxIconButton(icon: OxIcons.bell, semanticLabel: 'Notifications', dimension: 40, onPressed: () {}),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Top bar sits on a scrim over artwork. Active destination: ember pill + orbit dot. '
                    'The rail replaces the bottom bar from 600 dp.',
                    style: context.oxText.caption.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        const _Lab('Top bar over artwork'),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const OxImage('${GalleryScreen._p}/b-neon.jpg'),
                Align(
                  alignment: Alignment.topCenter,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: OxTopBar(
                      scrim: true,
                      actions: [
                        OxIconButton(icon: OxIcons.search, semanticLabel: 'Search', onPressed: () {}),
                        OxIconButton(icon: OxIcons.bell, semanticLabel: 'Notifications', onPressed: () {}),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- C8 Dialog -------------------------------------------------------------------

class _Dialogs extends StatelessWidget {
  const _Dialogs();

  static Widget _sample(BuildContext context, {VoidCallback? onCancel, VoidCallback? onDelete}) => OxDialog(
    icon: OxIcons.trash,
    tone: OxDialogTone.danger,
    title: 'Delete “Sports Pack”?',
    message:
        'This removes the account, its favorites and watch progress from this device. '
        'Your subscription with the provider isn’t affected.',
    actions: [
      OxButton(label: 'Cancel', variant: OxButtonVariant.ghost, size: OxButtonSize.sm, onPressed: onCancel ?? () {}),
      OxButton(label: 'Delete', variant: OxButtonVariant.destructive, size: OxButtonSize.sm, onPressed: onDelete ?? () {}),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        _sample(context),
        OxButton(
          label: 'Open dialog',
          variant: OxButtonVariant.tonal,
          onPressed: () async {
            final deleted = await showOxDialog<bool>(
              context,
              builder: (d) => _sample(d, onCancel: () => Navigator.pop(d, false), onDelete: () => Navigator.pop(d, true)),
            );
            if (deleted == true && context.mounted) {
              showOxSnack(
                context,
                message: 'Account deleted',
                actionLabel: 'Undo',
                icon: OxIcons.trash,
                iconColor: OxColors.live,
                onAction: () {},
              );
            }
          },
        ),
      ],
    );
  }
}

// --- C9 Bottom sheet -------------------------------------------------------------

class _Sheets extends StatefulWidget {
  const _Sheets();

  @override
  State<_Sheets> createState() => _SheetsState();
}

class _SheetsState extends State<_Sheets> {
  int _sort = 0;

  static const _options = [
    (OxIcons.list, 'Channel number'),
    (OxIcons.translate, 'Name A–Z'),
    (OxIcons.history, 'Recently watched'),
    (OxIcons.heart, 'Favorites first'),
  ];

  List<Widget> _rows(int selected, void Function(int) onTap) => [
    for (var i = 0; i < _options.length; i++)
      OxSheetOption(icon: _options[i].$1, label: _options[i].$2, selected: i == selected, onTap: () => onTap(i)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        // Static preview of the sheet surface.
        Container(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          decoration: BoxDecoration(
            color: OxColors.sheet,
            borderRadius: BorderRadius.circular(OxRadius.xl),
            border: const Border(top: BorderSide(color: OxColors.line2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  decoration: BoxDecoration(color: const Color(0x38FFFFFF), borderRadius: BorderRadius.circular(4)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                child: Text('Sort channels', style: context.oxText.h2),
              ),
              ..._rows(_sort, (i) => setState(() => _sort = i)),
            ],
          ),
        ),
        OxButton(
          label: 'Open sheet',
          variant: OxButtonVariant.tonal,
          onPressed: () async {
            final picked = await showOxSheet<int>(
              context,
              title: 'Sort channels',
              builder: (s) => Column(mainAxisSize: MainAxisSize.min, children: _rows(_sort, (i) => Navigator.pop(s, i))),
            );
            if (picked != null) setState(() => _sort = picked);
          },
        ),
      ],
    );
  }
}

// --- C10 Snackbars ---------------------------------------------------------------

class _Snacks extends StatelessWidget {
  const _Snacks();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        OxSnack(message: 'Added to favorites', icon: OxIcons.heartFill, actionLabel: 'Undo', onAction: () {}),
        OxSnack(message: 'Stream unavailable', tone: OxSnackTone.error, icon: OxIcons.alert, actionLabel: 'Retry', onAction: () {}),
        const OxSnack(message: 'Account connected', tone: OxSnackTone.success, icon: OxIcons.check),
        const OxSnack(message: 'Guide data from 2 sources · 7 days', tone: OxSnackTone.info, icon: OxIcons.epg),
        _Wrap([
          OxButton(
            label: 'Show',
            size: OxButtonSize.sm,
            variant: OxButtonVariant.tonal,
            onPressed: () =>
                showOxSnack(context, message: 'Added to favorites', icon: OxIcons.heartFill, actionLabel: 'Undo', onAction: () {}),
          ),
          OxButton(
            label: 'Error',
            size: OxButtonSize.sm,
            variant: OxButtonVariant.tonal,
            onPressed: () => showOxSnack(
              context,
              message: 'Stream unavailable',
              tone: OxSnackTone.error,
              icon: OxIcons.alert,
              actionLabel: 'Retry',
              onAction: () {},
            ),
          ),
          OxButton(
            label: 'Success',
            size: OxButtonSize.sm,
            variant: OxButtonVariant.tonal,
            onPressed: () => showOxSnack(context, message: 'Cache cleared · 248 MB freed', tone: OxSnackTone.success, icon: OxIcons.check),
          ),
        ]),
      ],
    );
  }
}
