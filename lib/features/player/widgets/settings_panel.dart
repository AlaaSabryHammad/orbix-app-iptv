import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/settings/app_settings.dart';
import '../../../shared/widgets/widgets.dart';
import '../../common/languages.dart';
import '../engine.dart';
import '../playback_controller.dart';

/// How the picture fills the screen.
enum AspectMode { fit, fill, zoom, wide }

extension AspectModeX on AspectMode {
  String label(AppLocalizations l) => switch (this) {
        AspectMode.fit => l.aspectFit,
        AspectMode.fill => l.aspectFill,
        AspectMode.zoom => l.aspectZoom,
        AspectMode.wide => l.aspect169,
      };

  BoxFit get fit => switch (this) { AspectMode.fill => BoxFit.fill, AspectMode.zoom => BoxFit.cover, _ => BoxFit.contain };

  double? get ratio => this == AspectMode.wide ? 16 / 9 : null;
}

const playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

/// Isolated left-to-right: in Arabic «2×» would read «×2» and «.75» «75.».
String speedLabel(double r) => '\u2066${switch (r) {
      1.0 => '1×',
      2.0 => '2×',
      0.75 => '.75',
      _ => r.toString(),
    }}\u2069';

/// Display name of an audio / subtitle track.
String trackName(AppLocalizations l, Object track, int index, {bool endonym = false}) {
  final code = trackLanguage(track);
  if (code != null) return endonym ? languageEndonym(code) : languageName(l, code);
  final title = switch (track) { AudioTrack(:final title) => title, SubtitleTrack(:final title) => title, _ => null };
  if (title != null && title.trim().isNotEmpty) return title.trim();
  return l.trackN(index + 1);
}

String? _audioLayout(AppLocalizations l, AudioTrack t) {
  final n = t.audiochannels ?? t.channelscount;
  return switch (n) {
    null => null,
    1 => l.audioMono,
    2 => l.audioStereo,
    6 => l.audioSurround('5.1'),
    8 => l.audioSurround('7.1'),
    _ => l.audioSurround('$n ch'),
  };
}

/// 21 PlayerSettings — audio, subtitles, speed, quality, aspect.
class PlayerSettingsPanel extends ConsumerStatefulWidget {
  const PlayerSettingsPanel({super.key, required this.controller, required this.aspect, required this.onAspect, required this.onClose});

  final PlaybackController controller;
  final AspectMode aspect;
  final ValueChanged<AspectMode> onAspect;
  final VoidCallback onClose;

  @override
  ConsumerState<PlayerSettingsPanel> createState() => _PlayerSettingsPanelState();
}

class _PlayerSettingsPanelState extends ConsumerState<PlayerSettingsPanel> {
  bool _style = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final engine = widget.controller.engine;
    final live = widget.controller.item.value?.isLive ?? false;
    final settings = ref.watch(appSettingsProvider);

    Widget heading(OxIcons icon, String text) => Row(
          spacing: 6,
          children: [
            OxIcon(icon, size: OxIconSize.xs, color: OxColors.text3),
            Text(t.overlineText(text), style: t.overline.copyWith(fontSize: t.isArabic ? 12 : 10)),
          ],
        );

    return ValueListenableBuilder(
      valueListenable: engine.state,
      builder: (context, s, _) {
        final audio = realTracks(s.tracks.audio);
        final subs = realTracks(s.tracks.subtitle);
        final video = realTracks(s.tracks.video).where((v) => (v.h ?? 0) > 0).toList()..sort((a, b) => (b.h ?? 0).compareTo(a.h ?? 0));
        final current = qualityLabel(s.height);

        final audioSection = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            heading(OxIcons.audio, l.audioTrackTitle),
            if (audio.isEmpty) _Option(label: l.qualityAuto, selected: true, onTap: () {}),
            for (final (i, a) in audio.indexed)
              _Option(
                label: trackName(l, a, i),
                caption: _audioLayout(l, a),
                selected: s.track.audio.id == a.id,
                onTap: () => widget.controller.chooseAudio(a),
              ),
          ],
        );

        final subtitleSection = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            heading(OxIcons.cc, l.subtitlesTitle),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                OxChip(label: l.subtitlesOff, small: true, selected: s.track.subtitle.id == 'no' || subs.isEmpty, onTap: () => widget.controller.chooseSubtitle(SubtitleTrack.no())),
                for (final (i, sub) in subs.indexed)
                  OxChip(
                    label: trackName(l, sub, i, endonym: true),
                    small: true,
                    selected: s.track.subtitle.id == sub.id,
                    onTap: () => widget.controller.chooseSubtitle(sub),
                  ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => setState(() => _style = !_style),
                style: TextButton.styleFrom(foregroundColor: OxColors.text2, padding: const EdgeInsets.symmetric(horizontal: 4)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Text(l.sizeAndStyle, style: t.small.copyWith(fontWeight: FontWeight.w800, color: OxColors.text2)),
                    OxIcon(_style ? OxIcons.chevD : OxIcons.chevR, size: OxIconSize.xs, color: OxColors.text2),
                  ],
                ),
              ),
            ),
            if (_style) ...[
              OxSegmented<SubtitleSize>(
                segments: [OxSegment(SubtitleSize.small, l.sizeSmall), OxSegment(SubtitleSize.medium, l.sizeMedium), OxSegment(SubtitleSize.large, l.sizeLarge)],
                selected: settings.subtitleSize,
                onChanged: (v) => ref.read(appSettingsProvider.notifier).update((x) => x.copyWith(subtitleSize: v)),
              ),
              OxSegmented<SubtitleStyle>(
                segments: [
                  OxSegment(SubtitleStyle.outline, l.styleOutline),
                  OxSegment(SubtitleStyle.shadow, l.styleShadow),
                  OxSegment(SubtitleStyle.box, l.styleBox),
                ],
                selected: settings.subtitleStyle,
                onChanged: (v) => ref.read(appSettingsProvider.notifier).update((x) => x.copyWith(subtitleStyle: v)),
              ),
            ],
          ],
        );

        final speedSection = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            heading(OxIcons.speed, l.playbackSpeed),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFF17171E), borderRadius: BorderRadius.circular(14)),
              child: Row(
                spacing: 4,
                children: [
                  for (final r in playbackSpeeds)
                    Expanded(
                      child: OxPressable(
                        onTap: () => engine.setRate(r),
                        selected: s.rate == r,
                        semanticLabel: '${l.playbackSpeed} ${speedLabel(r)}',
                        child: AnimatedContainer(
                          duration: OxMotion.fast,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: s.rate == r ? OxColors.ember : null, borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            speedLabel(r),
                            style: OxTypography.en.small.copyWith(fontSize: 12, fontWeight: FontWeight.w800, color: s.rate == r ? OxColors.emberInk : OxColors.text2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );

        final qualitySection = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            heading(OxIcons.hd, l.videoQuality),
            _Option(
              label: l.qualityAuto,
              selected: s.track.video.id == 'auto' || video.length < 2,
              trailing: current == null ? null : OxBadge(l.qualityNow(current), tone: OxBadgeTone.uhd, dense: true),
              onTap: () => engine.setVideoTrack(VideoTrack.auto()),
            ),
            if (video.length > 1)
              for (final v in video)
                _Option(label: qualityLabel(v.h) ?? '${v.h}p', selected: s.track.video.id == v.id, onTap: () => engine.setVideoTrack(v)),
          ],
        );

        final aspectSection = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            heading(OxIcons.aspect, l.aspectRatio),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final a in AspectMode.values) OxChip(label: a.label(l), small: true, selected: widget.aspect == a, onTap: () => widget.onAspect(a)),
              ],
            ),
          ],
        );

        final left = [audioSection, subtitleSection];
        final right = [if (!live) speedSection, qualitySection, aspectSection];

        return LayoutBuilder(
          builder: (context, c) {
            final twoColumns = c.maxWidth >= 520;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(l.playbackSettings, style: t.h2.copyWith(fontSize: 17))),
                    OxIconButton(icon: OxIcons.close, semanticLabel: l.actionDone, dimension: 36, iconSize: OxIconSize.sm, onPressed: widget.onClose),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: twoColumns
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 22,
                            children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: left)),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: right)),
                            ],
                          )
                        : Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 16, children: [...left, ...right]),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// `.opt` — radio row.
class _Option extends StatelessWidget {
  const _Option({required this.label, required this.selected, required this.onTap, this.caption, this.trailing});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? caption;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    return OxPressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: OxMotion.fast,
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: selected ? const Color(0x1FFF7A3D) : null, borderRadius: BorderRadius.circular(12)),
        child: Row(
          spacing: 10,
          children: [
            Container(
              width: 18,
              height: 18,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? OxColors.ember : const Color(0x4DFFFFFF), width: 2)),
              child: selected ? const DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: OxColors.ember)) : null,
            ),
            Expanded(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.small.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? OxColors.text1 : const Color(0xFFD2CED8))),
            ),
            if (caption != null) Text(caption!, style: t.caption),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
