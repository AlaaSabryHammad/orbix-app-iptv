import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Debug builds: the latest framework errors, drawn over the app. Some test
/// devices (Honor) keep almost nothing in logcat, so errors would be invisible.
abstract final class DebugErrors {
  static final latest = ValueNotifier<List<String>>(const []);

  static void install() {
    if (!kDebugMode) return;
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      previous?.call(details);
      final line = details.exceptionAsString().split('\n').first;
      final where = details.context?.toDescription() ?? details.library ?? '';
      latest.value = ['$line — $where', ...latest.value].take(4).toList();
    };
  }
}

/// Shows [DebugErrors.latest] at the top of the screen (debug builds only).
class DebugErrorOverlay extends StatelessWidget {
  const DebugErrorOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        child,
        Positioned(
          left: 8,
          right: 8,
          top: 30,
          child: IgnorePointer(
            child: ValueListenableBuilder(
              valueListenable: DebugErrors.latest,
              builder: (context, errors, _) => errors.isEmpty
                  ? const SizedBox.shrink()
                  : Container(
                      padding: const EdgeInsets.all(6),
                      color: const Color(0xCC400000),
                      child: Text(errors.join('\n'), textDirection: TextDirection.ltr, style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 11)),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
