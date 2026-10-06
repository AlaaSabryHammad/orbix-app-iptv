// Renders the Android launcher icons and the Windows app icon from OxLogoMark.
//   flutter test tool/launcher_icon/render_test.dart
// Writes mipmap-*/ic_launcher.png (legacy), ic_launcher_foreground.png and
// ic_launcher_monochrome.png (adaptive, Android 8+ / themed icons 13+), and
// windows/runner/resources/app_icon.ico (exe, taskbar, Start menu, installer).
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/design/design.dart';
import 'package:orbix/shared/widgets/widgets.dart';

const _res = 'android/app/src/main/res';
const _densities = {'mdpi': 1.0, 'hdpi': 1.5, 'xhdpi': 2.0, 'xxhdpi': 3.0, 'xxxhdpi': 4.0};

Future<Uint8List> _png(WidgetTester tester, Widget child, double size) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: RepaintBoundary(key: key, child: SizedBox.square(dimension: size, child: child))),
    ),
  );
  return (await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }))!;
}

Future<void> _render(WidgetTester tester, Widget child, double size, String path) async {
  final bytes = await _png(tester, child, size);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);
}

/// The legacy launcher icon: rounded square, mark at 62 %.
Widget _tile(double size) => DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.24),
        gradient: const RadialGradient(center: Alignment(0, -0.3), radius: 0.9, colors: [Color(0xFF1A1218), OxColors.ink1]),
      ),
      child: Center(child: OxLogoMark(size: size * 0.62, glow: size >= 32)),
    );

/// An .ico of PNG frames (Windows Vista+), smallest first.
Uint8List _ico(List<(int, Uint8List)> frames) {
  final out = BytesBuilder();
  final header = ByteData(6 + 16 * frames.length)
    ..setUint16(2, 1, Endian.little) // type: icon
    ..setUint16(4, frames.length, Endian.little);
  var offset = header.lengthInBytes;
  for (final (i, (size, png)) in frames.indexed) {
    final e = 6 + 16 * i;
    header
      ..setUint8(e, size >= 256 ? 0 : size) // 0 = 256
      ..setUint8(e + 1, size >= 256 ? 0 : size)
      ..setUint16(e + 4, 1, Endian.little) // planes
      ..setUint16(e + 6, 32, Endian.little) // bits per pixel
      ..setUint32(e + 8, png.length, Endian.little)
      ..setUint32(e + 12, offset, Endian.little);
    offset += png.length;
  }
  out.add(header.buffer.asUint8List());
  for (final (_, png) in frames) {
    out.add(png);
  }
  return out.takeBytes();
}

void main() {
  testWidgets('launcher icons', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(600, 600);
    addTearDown(tester.view.reset);

    for (final MapEntry(key: density, value: scale) in _densities.entries) {
      // Legacy: 48 dp rounded square, mark at 62 %.
      final legacy = 48 * scale;
      await _render(tester, _tile(legacy), legacy, '$_res/mipmap-$density/ic_launcher.png');

      // Adaptive: 108 dp canvas, safe zone 66 dp — mark at 56 dp.
      final adaptive = 108 * scale;
      await _render(tester, Center(child: OxLogoMark(size: 56 * scale, glow: true)), adaptive, '$_res/mipmap-$density/ic_launcher_foreground.png');
      await _render(
        tester,
        Center(
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
            child: OxLogoMark(size: 56 * scale),
          ),
        ),
        adaptive,
        '$_res/mipmap-$density/ic_launcher_monochrome.png',
      );
    }
  });

  testWidgets('windows icon', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(600, 600);
    addTearDown(tester.view.reset);

    final frames = <(int, Uint8List)>[];
    for (final size in const [16, 20, 24, 32, 40, 48, 64, 128, 256]) {
      frames.add((size, await _png(tester, _tile(size.toDouble()), size.toDouble())));
    }
    File('windows/runner/resources/app_icon.ico').writeAsBytesSync(_ico(frames));
  });
}
