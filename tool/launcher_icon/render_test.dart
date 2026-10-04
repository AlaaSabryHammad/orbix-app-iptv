// Renders the Android launcher icons from OxLogoMark.
//   flutter test tool/launcher_icon/render_test.dart
// Writes mipmap-*/ic_launcher.png (legacy), ic_launcher_foreground.png and
// ic_launcher_monochrome.png (adaptive, Android 8+ / themed icons 13+).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/design/design.dart';
import 'package:orbix/shared/widgets/widgets.dart';

const _res = 'android/app/src/main/res';
const _densities = {'mdpi': 1.0, 'hdpi': 1.5, 'xhdpi': 2.0, 'xxhdpi': 3.0, 'xxxhdpi': 4.0};

Future<void> _render(WidgetTester tester, Widget child, double size, String path) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: RepaintBoundary(key: key, child: SizedBox.square(dimension: size, child: child))),
    ),
  );
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('launcher icons', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(600, 600);
    addTearDown(tester.view.reset);

    for (final MapEntry(key: density, value: scale) in _densities.entries) {
      // Legacy: 48 dp rounded square, mark at 62 %.
      final legacy = 48 * scale;
      await _render(
        tester,
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(legacy * 0.24),
            gradient: const RadialGradient(center: Alignment(0, -0.3), radius: 0.9, colors: [Color(0xFF1A1218), OxColors.ink1]),
          ),
          child: Center(child: OxLogoMark(size: legacy * 0.62, glow: true)),
        ),
        legacy,
        '$_res/mipmap-$density/ic_launcher.png',
      );

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
}
