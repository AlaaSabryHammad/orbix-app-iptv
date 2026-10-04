import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';

/// App-bar action on the dev screens: flips the whole app between EN and AR.
class DevLocaleToggle extends ConsumerWidget {
  const DevLocaleToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextButton.icon(
      onPressed: () => ref.read(appLocaleProvider.notifier).set(Locale(isAr ? 'en' : 'ar')),
      icon: const OxIcon(OxIcons.translate, size: OxIconSize.md, color: OxColors.emberHi),
      label: Text(isAr ? 'EN' : 'عربي', style: context.oxText.title.copyWith(color: OxColors.emberHi)),
    );
  }
}
