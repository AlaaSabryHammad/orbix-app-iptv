import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:orbix/features/player/engine.dart';

/// A [PlayerEngine] without libmpv: `open` "loads" a 60 s, 960×540 clip
/// with English + Arabic audio and subtitles, like the demo clips.
class FakeEngine implements PlayerEngine {
  FakeEngine({required this.hardwareDecoding}) {
    created.add(this);
  }

  /// Every engine made since the last [reset], newest last.
  static final created = <FakeEngine>[];
  static void reset() => created.clear();
  static FakeEngine get last => created.last;

  final bool hardwareDecoding;
  final opened = <({String url, Duration? start, bool loop})>[];
  final calls = <String>[];
  bool disposed = false;

  final _state = ValueNotifier(const EngineState());
  final _position = ValueNotifier(Duration.zero);

  static const audio = [
    AudioTrack('auto', null, null),
    AudioTrack('no', null, null),
    AudioTrack('1', 'English', 'eng', channelscount: 2),
    AudioTrack('2', 'Arabic', 'ara', channelscount: 6),
  ];
  static const subtitles = [
    SubtitleTrack('auto', null, null),
    SubtitleTrack('no', null, null),
    SubtitleTrack('3', 'English', 'eng'),
    SubtitleTrack('4', 'العربية', 'ara'),
  ];

  @override
  ValueListenable<EngineState> get state => _state;

  @override
  ValueListenable<Duration> get position => _position;

  /// Pushes a state change, as the real engine's streams would.
  void emit(EngineState Function(EngineState) f) => _state.value = f(_state.value);

  void moveTo(Duration p) => _position.value = p;

  @override
  Future<void> open(String url, {Map<String, String> headers = const {}, Duration? start, bool loop = false}) async {
    opened.add((url: url, start: start, loop: loop));
    _position.value = start ?? Duration.zero;
    _state.value = EngineState(
      playing: true,
      buffering: false,
      duration: const Duration(seconds: 60),
      buffer: const Duration(seconds: 60),
      width: 960,
      height: 540,
      tracks: const Tracks(audio: audio, subtitle: subtitles, video: [VideoTrack('auto', null, null), VideoTrack('no', null, null), VideoTrack('1', null, null, w: 960, h: 540)]),
      track: Track(audio: audio[2], subtitle: SubtitleTrack.no()),
    );
  }

  @override
  Future<void> play() async {
    calls.add('play');
    emit((s) => s.copyWith(playing: true));
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
    emit((s) => s.copyWith(playing: false));
  }

  @override
  Future<void> seek(Duration to) async {
    calls.add('seek ${to.inSeconds}');
    _position.value = to;
  }

  @override
  Future<void> setRate(double rate) async => emit((s) => s.copyWith(rate: rate));

  @override
  Future<void> setVolume(double volume) async => emit((s) => s.copyWith(volume: volume));

  @override
  Future<void> setAudioTrack(AudioTrack track) async {
    calls.add('audio ${track.language}');
    emit((s) => s.copyWith(track: Track(audio: track, video: s.track.video, subtitle: s.track.subtitle)));
  }

  @override
  Future<void> setSubtitleTrack(SubtitleTrack track) async {
    calls.add('subtitle ${track.id}');
    emit((s) => s.copyWith(track: Track(audio: s.track.audio, video: s.track.video, subtitle: track)));
  }

  @override
  Future<void> setVideoTrack(VideoTrack track) async => emit((s) => s.copyWith(track: Track(audio: s.track.audio, video: track, subtitle: s.track.subtitle)));

  @override
  Future<void> dispose() async => disposed = true;

  @override
  Widget video({BoxFit fit = BoxFit.contain, double? aspectRatio}) => const ColoredBox(color: Color(0xFF101018));
}
