import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/catalog.dart';
import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Channels,
    Movies,
    SeriesTable,
    Episodes,
    Favorites,
    WatchProgressEntries,
    EpgProgrammes,
    ContentLocks,
  ],
)
class OrbixDatabase extends _$OrbixDatabase {
  /// Opens `orbix.sqlite` in app support storage. Queries run on a background
  /// isolate (drift_flutter), so large catalog writes never block the UI.
  OrbixDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'orbix'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.addColumn(epgProgrammes, epgProgrammes.image);
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          // Readers (UI) keep working while a sync writes.
          if (executor.dialect == SqlDialect.sqlite) {
            await customSelect('PRAGMA journal_mode = WAL').get();
          }
        },
      );

  /// Rough on-disk size of cached data, for Settings › Storage.
  Future<int> sizeInBytes() async {
    final pages = await customSelect('PRAGMA page_count').getSingle();
    final size = await customSelect('PRAGMA page_size').getSingle();
    return (pages.data.values.first as int) * (size.data.values.first as int);
  }
}
