import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/design/tokens.dart';

/// Guards the Dart tokens against drift from the design source of truth.
void main() {
  final css = File('orbix-design-handoff/design/orbix.css').readAsStringSync();
  final root = css.substring(css.indexOf(':root {'), css.indexOf('}', css.indexOf(':root {')));

  String v(String name) {
    final m = RegExp('--$name:\\s*([^;]+);').firstMatch(root);
    expect(m, isNotNull, reason: '--$name missing from :root');
    return m!.group(1)!.trim();
  }

  Color parse(String value) {
    if (value.startsWith('#')) return Color(int.parse('FF${value.substring(1)}', radix: 16));
    final m = RegExp(r'rgba\(\s*(\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\s*\)').firstMatch(value)!;
    return Color.fromARGB(
      (double.parse(m.group(4)!) * 255).round(),
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    );
  }

  test('colors match :root', () {
    final expected = <String, Color>{
      'ink-0': OxColors.ink0,
      'ink-1': OxColors.ink1,
      'ink-2': OxColors.ink2,
      'ink-3': OxColors.ink3,
      'ink-4': OxColors.ink4,
      'ink-5': OxColors.ink5,
      'line': OxColors.line,
      'line-2': OxColors.line2,
      'tx-1': OxColors.text1,
      'tx-2': OxColors.text2,
      'tx-3': OxColors.text3,
      'ember': OxColors.ember,
      'ember-hi': OxColors.emberHi,
      'ember-ink': OxColors.emberInk,
      'ember-soft': OxColors.emberSoft,
      'halo': OxColors.halo,
      'halo-soft': OxColors.haloSoft,
      'ok': OxColors.ok,
      'warn': OxColors.warn,
      'err': OxColors.err,
    };
    for (final e in expected.entries) {
      expect(e.value.toARGB32(), parse(v(e.key)).toARGB32(), reason: '--${e.key}');
    }
  });

  test('radii match :root', () {
    expect(OxRadius.xs, double.parse(v('r-xs').replaceAll('px', '')));
    expect(OxRadius.sm, double.parse(v('r-sm').replaceAll('px', '')));
    expect(OxRadius.md, double.parse(v('r-md').replaceAll('px', '')));
    expect(OxRadius.lg, double.parse(v('r-lg').replaceAll('px', '')));
    expect(OxRadius.xl, double.parse(v('r-xl').replaceAll('px', '')));
    expect(OxRadius.pill, double.parse(v('r-pill').replaceAll('px', '')));
  });

  test('motion matches :root', () {
    expect(OxMotion.fast.inMilliseconds, int.parse(v('t-fast').replaceAll('ms', '')));
    expect(OxMotion.base.inMilliseconds, int.parse(v('t-base').replaceAll('ms', '')));
    expect(OxMotion.slow.inMilliseconds, int.parse(v('t-slow').replaceAll('ms', '')));
    expect(v('ease-out'), 'cubic-bezier(.2, .8, .2, 1)');
    expect([OxMotion.easeOut.a, OxMotion.easeOut.b, OxMotion.easeOut.c, OxMotion.easeOut.d], [.2, .8, .2, 1]);
    expect(v('ease-spring'), 'cubic-bezier(.34, 1.56, .64, 1)');
    expect([OxMotion.spring.a, OxMotion.spring.b, OxMotion.spring.c, OxMotion.spring.d], [.34, 1.56, .64, 1]);
  });

  test('live badge colour matches .b-live', () {
    expect(css, contains('.b-live { color: #fff; background: #C93F0E; }'));
    expect(OxColors.live, const Color(0xFFC93F0E));
  });
}
