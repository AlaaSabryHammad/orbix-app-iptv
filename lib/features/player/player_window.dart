import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android window features for the player (MainActivity.kt): picture-in-
/// picture and the brightness gesture. Calls are no-ops where unsupported.
abstract final class PlayerWindow {
  static const _channel = MethodChannel('app.orbix.player/window');

  /// True while the activity is in picture-in-picture.
  static final inPip = ValueNotifier(false);
  static bool _listening = false;

  static void _listen() {
    if (_listening) return;
    _listening = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'pipChanged') inPip.value = call.arguments == true;
    });
  }

  static Future<T?> _call<T>(String method, [Map<String, Object?>? args]) async {
    if (defaultTargetPlatform != TargetPlatform.android || kIsWeb) return null;
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

  /// Full-screen player: system bars hidden until swiped.
  static Future<void> enterImmersive() => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  static Future<void> exitImmersive() => SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  static Future<void> setOrientations(List<DeviceOrientation> o) => SystemChrome.setPreferredOrientations(o);

  static const landscape = [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight];
  static const portrait = [DeviceOrientation.portraitUp];
  static const any = <DeviceOrientation>[];
}
