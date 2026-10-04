import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

export 'package:media_kit/media_kit.dart' show AudioTrack, SubtitleTrack, Track, Tracks, VideoTrack;

/// Everything the player UI shows except the position (which ticks often and
/// has its own listenable).
@immutable
class EngineState {
  const EngineState({
    this.playing = false,
    this.buffering = true,
    this.completed = false,
    this.duration = Duration.zero,
    this.buffer = Duration.zero,
    this.rate = 1,
    this.volume = 100,
    this.tracks = const Tracks(),
    this.track = const Track(),
    this.width,
    this.height,
    this.subtitle = const [],
    this.error,
  });

  final bool playing;
  final bool buffering;
  final bool completed;
  final Duration duration;

  /// How far the stream is cached (live: the live edge).
  final Duration buffer;
  final double rate;

  /// 0…100.
  final double volume;
  final Tracks tracks;
  final Track track;
  final int? width;
  final int? height;

  /// Current subtitle lines.
  final List<String> subtitle;
  final String? error;

  EngineState copyWith({
    bool? playing,
    bool? buffering,
    bool? completed,
    Duration? duration,
    Duration? buffer,
    double? rate,
    double? volume,
    Tracks? tracks,
    Track? track,
    int? Function()? width,
    int? Function()? height,
    List<String>? subtitle,
    String? Function()? error,
  }) =>
      EngineState(
        playing: playing ?? this.playing,
        buffering: buffering ?? this.buffering,
        completed: completed ?? this.completed,
        duration: duration ?? this.duration,
        buffer: buffer ?? this.buffer,
        rate: rate ?? this.rate,
        volume: volume ?? this.volume,
        tracks: tracks ?? this.tracks,
        track: track ?? this.track,
        width: width == null ? this.width : width(),
        height: height == null ? this.height : height(),
        subtitle: subtitle ?? this.subtitle,
        error: error == null ? this.error : error(),
      );
}

/// The playback backend behind the player screen — media_kit in the app,
/// a fake in widget tests (libmpv doesn't exist there).
abstract class PlayerEngine {
  ValueListenable<EngineState> get state;
  ValueListenable<Duration> get position;

  /// Opens [url]; [loop] repeats it (demo live streams).
  Future<void> open(String url, {Map<String, String> headers = const {}, Duration? start, bool loop = false});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration to);
  Future<void> setRate(double rate);
  Future<void> setVolume(double volume);
  Future<void> setAudioTrack(AudioTrack track);
  Future<void> setSubtitleTrack(SubtitleTrack track);
  Future<void> setVideoTrack(VideoTrack track);
  Future<void> dispose();

  /// The picture. Subtitles are drawn by the player screen, not here.
  Widget video({BoxFit fit = BoxFit.contain, double? aspectRatio});
}

/// Creates an engine; [hardwareDecoding] follows Settings.
typedef PlayerEngineFactory = PlayerEngine Function({required bool hardwareDecoding});

final playerEngineFactoryProvider = Provider<PlayerEngineFactory>((_) => MediaKitEngine.new);

/// Rewrites stream URLs before playback. Identity in release; debug builds
/// map the demo provider to bundled clips (see main.dart).
final streamUrlRewriterProvider = Provider<String Function(String)>((_) => (url) => url);

class MediaKitEngine implements PlayerEngine {
  MediaKitEngine({required bool hardwareDecoding})
      : _player = Player(configuration: const PlayerConfiguration(title: 'Orbix', bufferSize: 64 * 1024 * 1024)) {
    _video = VideoController(_player, configuration: VideoControllerConfiguration(enableHardwareAcceleration: hardwareDecoding));
    final s = _player.stream;
    void on<T>(Stream<T> stream, EngineState Function(EngineState, T) apply) => _subs.add(stream.listen((v) => _state.value = apply(_state.value, v)));
    on(s.playing, (e, v) => e.copyWith(playing: v));
    on(s.buffering, (e, v) => e.copyWith(buffering: v));
    on(s.completed, (e, v) => e.copyWith(completed: v));
    on(s.duration, (e, v) => e.copyWith(duration: v));
    on(s.buffer, (e, v) => e.copyWith(buffer: v));
    on(s.rate, (e, v) => e.copyWith(rate: v));
    on(s.volume, (e, v) => e.copyWith(volume: v));
    // media_kit publishes empty tracks at end of file (even with keep-open),
    // which would empty the settings panel and chips while the last frame is
    // still seekable. A new file resets state in open(), so keep the last set.
    bool real(List<Object> l) => l.length > 2;
    on(s.tracks, (e, v) => !real(v.audio) && !real(v.video) && !real(v.subtitle) && (real(e.tracks.audio) || real(e.tracks.video)) ? e : e.copyWith(tracks: v));
    on(s.track, (e, v) => v.audio.id == 'auto' && v.video.id == 'auto' && v.subtitle.id == 'auto' && e.completed ? e : e.copyWith(track: v));
    on(s.width, (e, v) => e.copyWith(width: () => v));
    on(s.height, (e, v) => e.copyWith(height: () => v));
    on(s.subtitle, (e, v) => e.copyWith(subtitle: v));
    on(s.error, (e, v) => e.copyWith(error: () => v));
    _subs.add(s.position.listen((p) => _position.value = p));
    // Keep the file loaded at the end so it can be sought back (mpv would
    // otherwise unload it and drop the track list).
    final native = _player.platform;
    if (native is NativePlayer) unawaited(native.setProperty('keep-open', 'yes'));
  }

  final Player _player;
  late final VideoController _video;
  final _subs = <StreamSubscription<Object?>>[];
  final _state = ValueNotifier(const EngineState());
  final _position = ValueNotifier(Duration.zero);

  @override
  ValueListenable<EngineState> get state => _state;

  @override
  ValueListenable<Duration> get position => _position;

  @override
  Future<void> open(String url, {Map<String, String> headers = const {}, Duration? start, bool loop = false}) async {
    _state.value = const EngineState();
    _position.value = start ?? Duration.zero;
    await _player.setPlaylistMode(loop ? PlaylistMode.single : PlaylistMode.none);
    await _player.open(Media(url, httpHeaders: headers.isEmpty ? null : headers, start: start));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration to) => _player.seek(to);

  @override
  Future<void> setRate(double rate) => _player.setRate(rate);

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> setAudioTrack(AudioTrack track) => _player.setAudioTrack(track);

  @override
  Future<void> setSubtitleTrack(SubtitleTrack track) => _player.setSubtitleTrack(track);

  @override
  Future<void> setVideoTrack(VideoTrack track) => _player.setVideoTrack(track);

  @override
  Future<void> dispose() async {
    for (final s in _subs) {
      await s.cancel();
    }
    await _player.dispose();
  }

  @override
  Widget video({BoxFit fit = BoxFit.contain, double? aspectRatio}) => Video(
        controller: _video,
        fit: fit,
        aspectRatio: aspectRatio,
        controls: null,
        // The player keeps playing in picture-in-picture.
        pauseUponEnteringBackgroundMode: false,
        subtitleViewConfiguration: const SubtitleViewConfiguration(visible: false),
      );
}
