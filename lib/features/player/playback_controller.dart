import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/session/session.dart';
import '../../core/settings/app_settings.dart';
import '../../data/data.dart';
import '../common/providers.dart';
import 'engine.dart';

enum PlayKind { live, movie, episode }

/// What to play: a channel, a movie, or an episode of [seriesId].
@immutable
class PlayTarget {
  const PlayTarget(this.kind, this.id, {this.seriesId});

  final PlayKind kind;
  final String id;
  final String? seriesId;
}

/// Metadata of what's playing (top bar, info, artwork while loading).
@immutable
class NowPlaying {
  const NowPlaying({
    required this.target,
    required this.title,
    this.genre,
    this.year,
    this.artwork,
    this.channel,
    this.categoryName,
    this.episode,
    this.previous,
    this.next,
    this.guide,
  });

  final PlayTarget target;
  final String title;
  final String? genre;
  final int? year;
  final String? artwork;
  final Channel? channel;
  final String? categoryName;
  final CatalogEpisode? episode;

  /// Episodes either side (prev / next buttons, up-next).
  final CatalogEpisode? previous;
  final CatalogEpisode? next;

  /// Live: now / next programmes.
  final NowNext? guide;

  bool get isLive => target.kind == PlayKind.live;

  NowPlaying withGuide(NowNext? g) => NowPlaying(
        target: target,
        title: title,
        genre: genre,
        year: year,
        artwork: artwork,
        channel: channel,
        categoryName: categoryName,
        episode: episode,
        previous: previous,
        next: next,
        guide: g,
      );
}

/// Loads and runs playback for the player screen: resolves the stream,
/// resumes, applies the track preferences from Settings, saves progress,
/// zaps channels and counts down to the next episode.
class PlaybackController {
  PlaybackController(this._c, PlayTarget target) : engine = _c.read(playerEngineFactoryProvider)(hardwareDecoding: _c.read(appSettingsProvider).hardwareDecoding) {
    engine.state.addListener(_onEngine);
    unawaited(load(target));
  }

  /// The app's container (not a WidgetRef: progress is saved after the screen is gone).
  final ProviderContainer _c;
  final PlayerEngine engine;

  final item = ValueNotifier<NowPlaying?>(null);

  /// A resolve / playback failure (shown with Retry).
  final failure = ValueNotifier<Object?>(null);

  /// Seconds left before the next episode starts; null = no countdown.
  final upNext = ValueNotifier<int?>(null);

  Timer? _progressTimer;
  Timer? _guideTimer;
  Timer? _upNextTimer;
  bool _tracksApplied = false;
  bool _completedHandled = false;
  int _loadId = 0;

  String get _account => _c.read(activeAccountIdProvider) ?? '';
  CatalogRepository get _catalog => _c.read(catalogRepositoryProvider);

  PlayTarget? get target => item.value?.target ?? _pending;
  PlayTarget? _pending;

  /// Opens [t] in place (also used to zap channels / move between episodes).
  Future<void> load(PlayTarget t) async {
    final id = ++_loadId;
    await _saveProgress();
    _pending = t;
    _tracksApplied = false;
    _completedHandled = false;
    _timeShifted = false;
    cancelUpNext();
    failure.value = null;
    _progressTimer?.cancel();
    _guideTimer?.cancel();
    try {
      final (info, stream, start) = await _resolve(t);
      if (id != _loadId) return;
      item.value = info;
      final url = _c.read(streamUrlRewriterProvider)(stream.url);
      await engine.open(url, headers: stream.headers, start: start, loop: t.kind == PlayKind.live);
      if (t.kind == PlayKind.live) {
        unawaited(_c.read(libraryRepositoryProvider).recordLiveWatch(_account, t.id));
        _guideTimer = Timer.periodic(const Duration(seconds: 30), (_) => _refreshGuide());
      } else {
        _progressTimer = Timer.periodic(const Duration(seconds: 15), (_) => _saveProgress());
      }
    } on Object catch (e) {
      if (id == _loadId) failure.value = e;
    }
  }

  Future<void> retry() async {
    final t = target;
    if (t != null) await load(t);
  }

  Future<(NowPlaying, ResolvedStream, Duration?)> _resolve(PlayTarget t) async {
    final lib = _c.read(libraryRepositoryProvider);
    switch (t.kind) {
      case PlayKind.live:
        final c = await _catalog.channel(_account, t.id);
        if (c == null) throw const InvalidPlaylistFailure('Channel not found');
        final cats = await _catalog.watchCategories(_account, ContentKind.live).first;
        final guide = await _guideFor(c);
        final info = NowPlaying(
          target: t,
          title: c.name,
          channel: c,
          categoryName: cats.where((k) => k.id == c.categoryId).firstOrNull?.name,
          artwork: guide?.now?.image,
          guide: guide,
        );
        return (info, await _catalog.channelStream(_account, c), null);
      case PlayKind.movie:
        final m = await _catalog.movie(_account, t.id);
        if (m == null) throw const InvalidPlaylistFailure('Movie not found');
        MovieDetails? d;
        try {
          d = await _c.read(movieDetailsProvider(t.id).future).timeout(const Duration(seconds: 6));
        } on Object {
          d = null;
        }
        final info = NowPlaying(target: t, title: m.name, genre: d?.genre, year: m.year, artwork: d?.backdrop ?? m.poster);
        return (info, await _catalog.movieStream(_account, m), await lib.resumePosition(_account, ProgressKind.movie, m.id));
      case PlayKind.episode:
        final details = await _c.read(seriesDetailsProvider(t.seriesId!).future);
        if (details == null) throw const InvalidPlaylistFailure('Series not found');
        final eps = [...details.episodes]..sort((a, b) => a.season != b.season ? a.season.compareTo(b.season) : a.episode.compareTo(b.episode));
        final i = eps.indexWhere((e) => e.id == t.id);
        if (i < 0) throw const InvalidPlaylistFailure('Episode not found');
        final e = eps[i];
        final info = NowPlaying(
          target: t,
          title: details.series.name,
          genre: details.series.genre,
          year: details.series.year,
          artwork: e.still ?? details.series.backdrop ?? details.series.cover,
          episode: e,
          previous: i > 0 ? eps[i - 1] : null,
          next: i + 1 < eps.length ? eps[i + 1] : null,
        );
        return (info, await _catalog.episodeStream(_account, e), await lib.resumePosition(_account, ProgressKind.episode, e.id));
    }
  }

  Future<NowNext?> _guideFor(Channel c) async {
    final map = await _c.read(epgRepositoryProvider).nowNext(_account, [EpgRepository.guideIdOf(c)]);
    return map[EpgRepository.guideIdOf(c)];
  }

  Future<void> _refreshGuide() async {
    final i = item.value;
    if (i?.channel == null) return;
    final g = await _guideFor(i!.channel!);
    if (item.value?.target == i.target) item.value = item.value!.withGuide(g);
  }

  void _onEngine() {
    final s = engine.state.value;
    if (s.error != null && failure.value == null && item.value != null) {
      // A live stream that drops is reopened by looping; anything else is shown.
      if (!(item.value!.isLive && s.playing)) failure.value = PlaybackFailure(s.error!);
    }
    if (!_tracksApplied && (s.tracks.audio.length > 2 || s.tracks.subtitle.length > 2 || s.tracks.video.length > 2)) {
      _tracksApplied = true;
      unawaited(_applyTrackPreferences(s.tracks));
    }
    if (s.completed && !_completedHandled && item.value != null && !item.value!.isLive) {
      _completedHandled = true;
      unawaited(_saveProgress(completed: true));
      final next = item.value!.next;
      if (next != null && _c.read(appSettingsProvider).autoplayNext) _startUpNext();
    }
  }

  /// Audio by Settings › Audio language order; quality by Default quality.
  Future<void> _applyTrackPreferences(Tracks tracks) async {
    final settings = _c.read(appSettingsProvider);
    final audio = realTracks(tracks.audio);
    for (final code in settings.audioLanguages) {
      final match = audio.where((a) => trackLanguage(a) == code).firstOrNull;
      if (match != null) {
        await engine.setAudioTrack(match);
        break;
      }
    }
    // Subtitles: the remembered language, otherwise off — files often flag
    // a "default" subtitle track that mpv would show unasked.
    final subLang = settings.subtitleLanguage;
    final sub = subLang == null ? null : realTracks(tracks.subtitle).where((t) => trackLanguage(t) == subLang).firstOrNull;
    await engine.setSubtitleTrack(sub ?? SubtitleTrack.no());
    final video = realTracks(tracks.video).where((v) => (v.h ?? 0) > 0).toList();
    final pref = int.tryParse(settings.defaultQuality);
    if (pref != null && video.length > 1) {
      video.sort((a, b) => (b.h ?? 0).compareTo(a.h ?? 0));
      await engine.setVideoTrack(video.firstWhere((v) => (v.h ?? 0) <= pref, orElse: () => video.last));
    }
  }

  /// Picking an audio track also makes its language the first preference.
  Future<void> chooseAudio(AudioTrack t) async {
    await engine.setAudioTrack(t);
    final code = trackLanguage(t);
    if (code == null) return;
    await _c.read(appSettingsProvider.notifier).update((s) => s.copyWith(audioLanguages: [code, ...s.audioLanguages.where((c) => c != code)]));
  }

  /// Picking subtitles (or Off) is remembered for the next title.
  Future<void> chooseSubtitle(SubtitleTrack t) async {
    await engine.setSubtitleTrack(t);
    final code = t.id == 'no' ? null : trackLanguage(t);
    if (t.id != 'no' && code == null) return;
    await _c.read(appSettingsProvider.notifier).update((s) => s.copyWith(subtitleLanguage: () => code));
  }

  Future<void> _saveProgress({bool completed = false}) async {
    final i = item.value;
    if (i == null || i.isLive) return;
    final s = engine.state.value;
    final d = s.duration;
    if (d <= Duration.zero) return;
    final p = completed ? d : engine.position.value;
    if (p < const Duration(seconds: 5)) return;
    final kind = i.target.kind == PlayKind.movie ? ProgressKind.movie : ProgressKind.episode;
    await _c.read(libraryRepositoryProvider).saveProgress(_account, kind, i.target.id, position: p, duration: d, seriesId: i.target.seriesId);
  }

  void _startUpNext() {
    upNext.value = 10;
    _upNextTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final left = (upNext.value ?? 0) - 1;
      if (left <= 0) {
        t.cancel();
        playNextEpisode();
      } else {
        upNext.value = left;
      }
    });
  }

  void cancelUpNext() {
    _upNextTimer?.cancel();
    upNext.value = null;
  }

  Future<void> playNextEpisode() async {
    final n = item.value?.next;
    cancelUpNext();
    if (n != null) await load(PlayTarget(PlayKind.episode, n.id, seriesId: n.seriesId));
  }

  Future<void> playPreviousEpisode() async {
    final p = item.value?.previous;
    if (p != null) await load(PlayTarget(PlayKind.episode, p.id, seriesId: p.seriesId));
  }

  /// The channel above / below in the current channel's category.
  Future<Channel?> adjacentChannel({required bool next}) async {
    final c = item.value?.channel;
    if (c == null) return null;
    return _catalog.adjacentChannel(_account, c.id, next: next, categoryId: c.categoryId);
  }

  // Transport -----------------------------------------------------------------

  Future<void> togglePlay() {
    // Pausing live buffers, so playback is behind the edge from here on.
    if (engine.state.value.playing && (item.value?.isLive ?? false)) _timeShifted = true;
    return engine.state.value.playing ? engine.pause() : engine.play();
  }

  Future<void> seekBy(Duration d) {
    if ((item.value?.isLive ?? false) && d.isNegative) _timeShifted = true;
    final s = engine.state.value;
    var to = engine.position.value + d;
    if (to < Duration.zero) to = Duration.zero;
    final end = item.value?.isLive ?? false ? s.buffer : s.duration;
    if (end > Duration.zero && to > end) to = end;
    return engine.seek(to);
  }

  /// Live: back to the live edge.
  Future<void> goLive() async {
    _timeShifted = false;
    final s = engine.state.value;
    if (s.buffer > Duration.zero) await engine.seek(s.buffer);
    await engine.play();
  }

  /// Live: paused or rewound since tuning in. (mpv's cache always runs
  /// ahead of playback, so the buffer alone can't tell.)
  bool get behindLive => _timeShifted;
  bool _timeShifted = false;

  Future<void> dispose() async {
    _progressTimer?.cancel();
    _guideTimer?.cancel();
    _upNextTimer?.cancel();
    engine.state.removeListener(_onEngine);
    await _saveProgress();
    await engine.dispose();
    item.dispose();
    failure.dispose();
    upNext.dispose();
  }
}

/// A playback error from the engine (decoder, network mid-stream…).
class PlaybackFailure implements Exception {
  const PlaybackFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Tracks without mpv's "auto" / "no" pseudo-entries.
List<T> realTracks<T extends Object>(List<T> tracks) => tracks.where((t) {
      final id = switch (t) { AudioTrack(:final id) => id, SubtitleTrack(:final id) => id, VideoTrack(:final id) => id, _ => '' };
      return id != 'auto' && id != 'no';
    }).toList();

const _languageCodes = {
  'ar': ['ar', 'ara', 'arabic', 'العربية'],
  'en': ['en', 'eng', 'english'],
  'fr': ['fr', 'fre', 'fra', 'french', 'français'],
  'es': ['es', 'spa', 'spanish', 'español'],
  'de': ['de', 'ger', 'deu', 'german', 'deutsch'],
  'tr': ['tr', 'tur', 'turkish', 'türkçe'],
};

/// Two-letter language of a track from its tag or title, if recognisable.
String? trackLanguage(Object track) {
  final (lang, title) = switch (track) {
    AudioTrack(:final language, :final title) => (language, title),
    SubtitleTrack(:final language, :final title) => (language, title),
    _ => (null, null),
  };
  for (final raw in [lang, title]) {
    final v = raw?.trim().toLowerCase();
    if (v == null || v.isEmpty) continue;
    for (final MapEntry(:key, :value) in _languageCodes.entries) {
      if (value.contains(v)) return key;
    }
  }
  return null;
}

/// "4K", "1080p"… from a picture height.
String? qualityLabel(int? height) => switch (height) {
      null || <= 0 => null,
      >= 2000 => '4K',
      >= 1000 => '1080p',
      >= 700 => '720p',
      >= 470 => '480p',
      _ => 'SD',
    };
