import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the device has a network (Wi‑Fi, mobile, ethernet…). States 06:
/// the "No connection" banner and the offline screen. Overridden in tests.
final onlineProvider = StreamProvider<bool>((ref) async* {
  final c = Connectivity();
  bool up(List<ConnectivityResult> r) => r.any((x) => x != ConnectivityResult.none);
  try {
    yield up(await c.checkConnectivity());
  } on Object {
    yield true; // Unknown: assume online rather than block the app.
  }
  var last = true;
  await for (final r in c.onConnectivityChanged) {
    final now = up(r);
    if (now != last) yield last = now;
  }
});

/// Opens Android's network settings (offline screen › "Network settings").
Future<void> openNetworkSettings() async {
  try {
    await const MethodChannel('app.orbix.player/window').invokeMethod<void>('openNetworkSettings');
  } on MissingPluginException {
    // Not on Android.
  } on PlatformException {
    // No settings activity available.
  }
}
