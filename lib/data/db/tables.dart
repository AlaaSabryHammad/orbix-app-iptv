import 'package:drift/drift.dart';

import '../models/catalog.dart';

enum AccountKind { xtream, m3u, file }

enum AccountStatus { active, expired, disabled, unknown }

enum ProgressKind { movie, episode, live }

enum LockKind { liveCategory, movieCategory, seriesCategory, channel }

/// A saved IPTV account. Secrets (password, playlist URL) are NOT here —
/// they live in the encrypted CredentialStore, keyed by [id].
@DataClassName('Account')
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => textEnum<AccountKind>()();

  /// `host:port` for display only.
  TextColumn get displayHost => text().nullable()();
  TextColumn get status => textEnum<AccountStatus>().withDefault(Constant(AccountStatus.unknown.name))();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  IntColumn get maxConnections => integer().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get guideUpdatedAt => dateTime().nullable()();
  IntColumn get guideSourceCount => integer().withDefault(const Constant(0))();
  IntColumn get liveCount => integer().withDefault(const Constant(0))();
  IntColumn get movieCount => integer().withDefault(const Constant(0))();
  IntColumn get seriesCount => integer().withDefault(const Constant(0))();

  /// Settings › Guide time shift, applied when reading programmes.
  IntColumn get guideShiftMinutes => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MediaCategory')
class Categories extends Table {
  TextColumn get accountId => text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<ContentKind>()();
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get sortIndex => integer()();
  BoolColumn get isAdult => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {accountId, kind, id};
}

@DataClassName('Channel')
@TableIndex(name: 'channels_by_category', columns: {#accountId, #categoryId, #sortIndex})
@TableIndex(name: 'channels_by_epg', columns: {#accountId, #epgId})
class Channels extends Table {
  TextColumn get accountId => text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get number => integer().nullable()();
  TextColumn get logo => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get epgId => text().nullable()();
  TextColumn get streamUrl => text().nullable()();

  /// JSON object of per-stream HTTP headers.
  TextColumn get headers => text().nullable()();
  IntColumn get catchupDays => integer().withDefault(const Constant(0))();
  IntColumn get sortIndex => integer()();
  DateTimeColumn get addedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {accountId, id};
}

@DataClassName('Movie')
@TableIndex(name: 'movies_by_category', columns: {#accountId, #categoryId, #sortIndex})
@TableIndex(name: 'movies_by_added', columns: {#accountId, #addedAt})
class Movies extends Table {
  TextColumn get accountId => text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get poster => text().nullable()();
  RealColumn get rating => real().nullable()();
  IntColumn get year => integer().nullable()();
  DateTimeColumn get addedAt => dateTime().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get containerExt => text().nullable()();
  TextColumn get streamUrl => text().nullable()();
  IntColumn get sortIndex => integer()();

  @override
  Set<Column<Object>> get primaryKey => {accountId, id};
}

@DataClassName('Show')
@TableIndex(name: 'series_by_category', columns: {#accountId, #categoryId, #sortIndex})
@TableIndex(name: 'series_by_updated', columns: {#accountId, #updatedAt})
class SeriesTable extends Table {
  @override
  String get tableName => 'series';

  TextColumn get accountId => text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get cover => text().nullable()();
  TextColumn get backdrop => text().nullable()();
  TextColumn get plot => text().nullable()();
  RealColumn get rating => real().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get genre => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get categoryId => text().nullable()();
  IntColumn get sortIndex => integer()();

  @override
  Set<Column<Object>> get primaryKey => {accountId, id};
}

@DataClassName('Episode')
@TableIndex(name: 'episodes_by_series', columns: {#accountId, #seriesId, #season, #episode})
class Episodes extends Table {
  TextColumn get accountId => text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get id => text()();
  TextColumn get seriesId => text()();
  IntColumn get season => integer()();
  IntColumn get episode => integer()();
  TextColumn get title => text()();
  TextColumn get containerExt => text().nullable()();
  TextColumn get streamUrl => text().nullable()();
  IntColumn get durationSecs => integer().nullable()();
  TextColumn get plot => text().nullable()();
  TextColumn get still => text().nullable()();
  DateTimeColumn get airDate => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {accountId, id};
}

/// Favorites per account and kind, in user order (drag-to-reorder).
@DataClassName('Favorite')
class Favorites extends Table {
  TextColumn get accountId => text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<ContentKind>()();
  TextColumn get itemId => text()();
  IntColumn get position => integer()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {accountId, kind, itemId};
}

/// Resume points, per account and item, to the second. Live entries record
/// "recently watched" channels (no position).
@DataClassName('WatchProgress')
@TableIndex(name: 'progress_by_recent', columns: {#accountId, #updatedAt})
class WatchProgressEntries extends Table {
  @override
  String get tableName => 'watch_progress';

  TextColumn get accountId => text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<ProgressKind>()();
  TextColumn get itemId => text()();
  TextColumn get seriesId => text().nullable()();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {accountId, kind, itemId};
}

/// Cached guide. Times are UTC; channel ids normalised lower-case.
@DataClassName('EpgProgramme')
@TableIndex(name: 'epg_by_stop', columns: {#accountId, #stop})
class EpgProgrammes extends Table {
  TextColumn get accountId => text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get channelId => text()();
  DateTimeColumn get start => dateTime()();
  DateTimeColumn get stop => dateTime()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().nullable()();

  /// Programme artwork (`<programme><icon src>`), schema v2.
  TextColumn get image => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {accountId, channelId, start};
}

/// Parental locks on categories and channels.
@DataClassName('ContentLock')
class ContentLocks extends Table {
  TextColumn get accountId => text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<LockKind>()();
  TextColumn get itemId => text()();

  @override
  Set<Column<Object>> get primaryKey => {accountId, kind, itemId};
}
