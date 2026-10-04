import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../db/database.dart';

/// Settings › Storage: what the cache holds, in bytes.
class StorageUsage {
  const StorageUsage({required this.artwork, required this.guide, required this.lists});

  final int artwork;
  final int guide;
  final int lists;

  int get total => artwork + guide + lists;
}

/// Measures and clears re-downloadable data: artwork (image cache), the TV
/// guide and catalog lists. Accounts, favorites and progress are never touched.
class StorageRepository {
  StorageRepository(this._db, {this.images, Future<Directory> Function()? tempDir, Future<Directory> Function()? supportDir})
      : _tempDir = tempDir ?? getTemporaryDirectory,
        _supportDir = supportDir ?? getApplicationSupportDirectory;

  final OrbixDatabase _db;
  /// Image cache; [DefaultCacheManager] when null.
  final BaseCacheManager? images;
  final Future<Directory> Function() _tempDir;
  final Future<Directory> Function() _supportDir;

  Future<StorageUsage> usage() async {
    final artwork = await _dirSize(Directory('${(await _tempDir()).path}/${DefaultCacheManager.key}'));
    final pages = await _db.customSelect('SELECT page_count * page_size AS b FROM pragma_page_count(), pragma_page_size()').getSingle();
    final dbBytes = pages.read<int>('b');
    final guide = await _guideBytes(dbBytes);
    final playlists = await _dirSize(Directory('${(await _supportDir()).path}/playlists'));
    return StorageUsage(artwork: artwork, guide: guide, lists: (dbBytes - guide).clamp(0, dbBytes) + playlists);
  }

  /// Exact with SQLite's dbstat table; otherwise estimated from row share.
  Future<int> _guideBytes(int dbBytes) async {
    try {
      final r = await _db.customSelect("SELECT COALESCE(SUM(pgsize), 0) AS b FROM dbstat WHERE name LIKE '%epg_programmes%'").getSingle();
      return r.read<int>('b');
    } on Object {
      final count = _db.epgProgrammes.rowId.count();
      final rows = await (_db.selectOnly(_db.epgProgrammes)..addColumns([count])).map((r) => r.read(count) ?? 0).getSingle();
      return (rows * 180).clamp(0, dbBytes);
    }
  }

  /// Drops cached artwork and the guide; returns when the space is freed.
  Future<void> clear() async {
    await (images ?? DefaultCacheManager()).emptyCache();
    await _db.transaction(() async {
      await _db.delete(_db.epgProgrammes).go();
      await _db.update(_db.accounts).write(const AccountsCompanion(guideUpdatedAt: Value(null)));
    });
    await _db.customStatement('VACUUM');
  }

  static Future<int> _dirSize(Directory dir) async {
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final e in dir.list(recursive: true, followLinks: false)) {
      if (e is File) total += await e.length();
    }
    return total;
  }
}
