import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data.dart';
import '../settings/app_settings.dart';

export '../../data/repositories/parental.dart' show ParentalService;

/// The account in use, live from the database (null when none is selected
/// or it was deleted).
final activeAccountProvider = StreamProvider<Account?>((ref) {
  final id = ref.watch(appSettingsProvider.select((s) => s.activeAccountId));
  if (id == null) return Stream.value(null);
  return ref.watch(accountRepositoryProvider).watch(id);
});

/// Id of the active account, synchronously.
final activeAccountIdProvider = Provider<String?>((ref) => ref.watch(appSettingsProvider.select((s) => s.activeAccountId)));

final sessionProvider = Provider<Session>(Session.new);

/// Switching accounts and the launch decision.
class Session {
  Session(this._ref);

  final Ref _ref;

  Future<void> select(String accountId) async {
    await _ref.read(accountRepositoryProvider).touch(accountId);
    await _ref.read(appSettingsProvider.notifier).update((s) => s.copyWith(activeAccountId: () => accountId));
    _ref.read(parentalProvider).lock();
  }

  Future<void> clear() => _ref.read(appSettingsProvider.notifier).update((s) => s.copyWith(activeAccountId: () => null));

  /// Where the splash goes: first run → onboarding; no accounts → add one;
  /// default account + "open on launch" → straight in; otherwise Profiles.
  Future<LaunchTarget> launchTarget() async {
    final repo = _ref.read(accountRepositoryProvider);
    // "Save as profile" was off: the account lasted one session.
    final temporary = _ref.read(appSettingsProvider).temporaryAccountIds;
    if (temporary.isNotEmpty) {
      for (final id in temporary) {
        await repo.delete(id);
      }
      await _ref.read(appSettingsProvider.notifier).update((s) => s.copyWith(
            temporaryAccountIds: const [],
            activeAccountId: () => temporary.contains(s.activeAccountId) ? null : s.activeAccountId,
          ));
    }
    final settings = _ref.read(appSettingsProvider);
    final accounts = await repo.all();
    if (accounts.isEmpty) return settings.onboardingDone ? LaunchTarget.addAccount : LaunchTarget.onboarding;
    if (settings.openDefaultOnLaunch) {
      final account = await repo.defaultAccount() ?? await repo.lastUsed();
      if (account != null) {
        await select(account.id);
        return LaunchTarget.home;
      }
    }
    return LaunchTarget.profiles;
  }
}

enum LaunchTarget { onboarding, addAccount, profiles, home }

/// Parental PIN + temporary unlock ("Re-lock after 5 minutes").
final parentalProvider = Provider<ParentalService>((ref) {
  return ParentalService(ref.watch(secretStoreProvider), () => ref.read(appSettingsProvider).relockMinutes);
});
