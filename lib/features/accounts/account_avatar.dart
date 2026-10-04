import 'package:flutter/material.dart';

import '../../core/design/design.dart';
import '../../data/data.dart';
import '../../shared/widgets/widgets.dart';

/// The five avatar gradients from the Profiles spec, picked by account id.
const accountGradients = <List<Color>>[
  [Color(0xFFFF8A4C), Color(0xFFB43A12)],
  [Color(0xFF2FBF91), Color(0xFF0D4A44)],
  [Color(0xFFFFC65C), Color(0xFFC2457A)],
  [Color(0xFF6C8CFF), Color(0xFF2B1A6B)],
  [Color(0xFF5A5A6E), Color(0xFF1E1E28)],
];

List<Color> accountGradient(String accountId) => accountGradients[accountId.codeUnits.fold<int>(0, (a, c) => a + c) % accountGradients.length];

/// Small account initials tile (top bar "Switch account").
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({super.key, required this.account, this.size = 30});

  final Account account;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 3),
        gradient: LinearGradient(begin: const Alignment(-0.6, -1), end: const Alignment(0.6, 1), colors: accountGradient(account.id)),
      ),
      alignment: Alignment.center,
      child: Text(
        OxChannelLogo.initialsOf(account.name),
        textDirection: TextDirection.ltr,
        style: OxTypography.en.h1.copyWith(fontSize: size * 0.36, color: const Color(0xFFFFFFFF), height: 1, fontFamilyFallback: const [OxFonts.arabic]),
      ),
    );
  }
}
