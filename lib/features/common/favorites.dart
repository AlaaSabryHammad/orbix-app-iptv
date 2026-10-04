import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/session/session.dart';
import '../../data/data.dart';
import '../../shared/widgets/widgets.dart';

/// Hearts a channel / movie / series (or un-hearts it). Adding confirms with
/// "Added to favorites · Undo" (States 12).
Future<void> toggleFavoriteWithFeedback(BuildContext context, WidgetRef ref, ContentKind kind, String id) async {
  final account = ref.read(activeAccountIdProvider) ?? '';
  final repo = ref.read(libraryRepositoryProvider);
  final l = context.l10n;
  final added = await repo.toggleFavorite(account, kind, id);
  if (!added || !context.mounted) return;
  showOxSnack(
    context,
    message: l.addedToFavorites,
    icon: OxIcons.heartFill,
    iconColor: OxColors.live,
    actionLabel: l.actionUndo,
    onAction: () => unawaited(repo.toggleFavorite(account, kind, id)),
  );
}
