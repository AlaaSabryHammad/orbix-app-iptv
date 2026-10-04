import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import '../../../core/l10n/l10n.dart';
import '../../../data/data.dart';
import '../../../shared/widgets/widgets.dart';
import '../../live/live_providers.dart';
import 'player_chrome.dart';

/// PlayerLive › Channels: the playing channel's category, now on each.
class ChannelPanel extends ConsumerStatefulWidget {
  const ChannelPanel({super.key, required this.current, required this.categoryName, required this.onSelect, required this.onClose});

  final Channel current;
  final String? categoryName;
  final ValueChanged<Channel> onSelect;
  final VoidCallback onClose;

  @override
  ConsumerState<ChannelPanel> createState() => _ChannelPanelState();
}

class _ChannelPanelState extends ConsumerState<ChannelPanel> {
  static const _rowH = 60.0;
  late final _scroll = ScrollController();
  bool _scrolled = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final key = widget.current.categoryId ?? LiveKey.all;
    final channels = ref.watch(liveChannelsProvider(key)).value ?? const <Channel>[];
    final guide = ref.watch(liveNowNextProvider(key)).value ?? const {};
    final locks = ref.watch(locksProvider).value ?? const {};

    // Open with the playing channel in view.
    if (!_scrolled && channels.isNotEmpty) {
      _scrolled = true;
      final i = channels.indexWhere((c) => c.id == widget.current.id);
      if (i > 2) WidgetsBinding.instance.addPostFrameCallback((_) => _scroll.hasClients ? _scroll.jumpTo(((i - 2) * _rowH).clamp(0, _scroll.position.maxScrollExtent)) : null);
    }

    return VideoGlass(
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 10, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OxContentText(widget.categoryName ?? l.allChannels, style: t.title.copyWith(fontSize: 14)),
                      Text(l.channelsCount(channels.length), style: t.caption),
                    ],
                  ),
                ),
                OxIconButton(icon: OxIcons.close, semanticLabel: l.a11yCloseChannels, dimension: 36, iconSize: OxIconSize.sm, onPressed: widget.onClose),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
              itemExtent: _rowH,
              itemCount: channels.length,
              itemBuilder: (context, i) {
                final c = channels[i];
                final playing = c.id == widget.current.id;
                final now = guide[EpgRepository.guideIdOf(c)]?.now;
                return OxPressable(
                  onTap: () => playing ? widget.onClose() : widget.onSelect(c),
                  selected: playing,
                  semanticLabel: c.name,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: playing ? const Color(0x24FF7A3D) : null, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      spacing: 10,
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(c.number?.toString() ?? '', textDirection: TextDirection.ltr, style: OxTypography.en.time.copyWith(fontSize: 10.5, color: OxColors.text3)),
                        ),
                        OxChannelLogo(name: c.name, logoUrl: c.logo, size: 36),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 6,
                                children: [
                                  Flexible(child: OxContentText(c.name, style: t.title.copyWith(fontSize: 13, fontWeight: FontWeight.w800))),
                                  if (playing) const OxEqualizer(),
                                  if (isChannelLocked(c, locks)) const OxIcon(OxIcons.lock, size: 12, color: OxColors.warn),
                                ],
                              ),
                              if (now != null) OxContentText(now.title, style: t.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
