import 'package:flutter/services.dart' show appFlavor;

/// The dev flavor (`--flavor dev`): includes the demo provider and its
/// bundled artwork and clips. Store builds use `--flavor prod`, where this is
/// false and `assets/demo/` isn't packaged at all.
const bool isDevFlavor = appFlavor == 'dev';
