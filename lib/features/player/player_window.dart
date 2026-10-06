import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Window features for the player: picture-in-picture and the brightness
/// gesture on Android (MainActivity.kt), full screen on Windows
/// (flutter_window.cpp). Calls are no-ops where unsupported.
abstract final class PlayerWindow {
  static const _channel = MethodChannel('app.orbix.player/window');

  static bool get _android => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Windows: a resizable window driven by mouse and keyboard.
  static bool get isDesktop => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  /// Picture-in-picture and window brightness exist on Android only.
  static bool get hasPip => _android;
  static bool get hasBrightness => _android;

  /// True while the activity is in picture-in-picture.
  static final inPip = ValueNotifier(false);

  /// True while the desktop window covers the whole monitor.
  static final fullscreen = ValueNotifier(false);

  static bool _listening = false;

  static void _listen() {
    if (_listening) return;
    _listening = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'pipChanged') inPip.value = call.arguments == true;
    });
  }

  static Future<T?> _call<T>(String method, [Map<String, Object?>? args]) async {
    if (!_android && !isDesktop) return null;
    _listen();
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  static Future<bool> pipSupported() async => await _call<bool>('pipSupported') ?? false;

  static Future<bool> enterPip({int? width, int? height}) async => await _call<bool>('enterPip', {'w': width, 'h': height}) ?? false;

  /// Enter PiP automatically when the user leaves the app while playing.
  static Future<void> setAutoPip(bool enabled, {int? width, int? height}) => _call<void>('setAutoPip', {'enabled': enabled, 'w': width, 'h': height});

  /// Window brightness 0…1 (system brightness if not overridden).
  static Future<double> brightness() async => await _call<double>('getBrightness') ?? 0.5;

  /// Overrides the window brightness; null restores the system setting.
  static Future<void> setBrightness(double? value) => _call<void>('setBrightness', {'value': value ?? -1.0});

  /// Desktop: borderless over the whole monitor, or back to the window.
  static Future<void> setFullscreen(bool value) async {
    if (!isDesktop) return;
    fullscreen.value = await _call<bool>('setFullScreen', {'value': value}) ?? false;
  }

  /// Full-screen player: system bars hidden until swiped.
  static Future<void> enterImmersive() => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  /// Also leaves desktop full screen, so the app never stays borderless.
  static Future<void> exitImmersive() async {
    if (fullscreen.value) await setFullscreen(false);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  static Future<void> setOrientations(List<DeviceOrientation> o) => SystemChrome.setPreferredOrientations(o);

  static const landscape = [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight];
  static const portrait = [DeviceOrientation.portraitUp];
  static const any = <DeviceOrientation>[];
}
