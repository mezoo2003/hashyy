import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/hashtag.dart';

/// Everything here is 100% local — there is no network layer anywhere in
/// this app. Only hashtags and the (photoAssetId <-> hashtagId) relation
/// are stored; the original photo/video files are never touched, copied,
/// or moved.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hash_gallery.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hashtags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color_hex TEXT NOT NULL,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        is_locked INTEGER NOT NULL DEFAULT 0,
        password_hash TEXT,
        sort_preference TEXT NOT NULL DEFAULT 'newest',
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE photo_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        photo_asset_id TEXT NOT NULL,
        hashtag_id INTEGER NOT NULL,
        date_tagged INTEGER NOT NULL,
        manual_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (hashtag_id) REFERENCES hashtags (id) ON DELETE CASCADE,
        UNIQUE(photo_asset_id, hashtag_id)
      )
    ''');

    await db.execute('CREATE INDEX idx_photo_asset_id ON photo_tags (photo_asset_id)');
    await db.execute('CREATE INDEX idx_hashtag_id ON photo_tags (hashtag_id)');
  }

  // ---------------------------------------------------------------------
  // Hashtags
  // ---------------------------------------------------------------------

  Future<List<Hashtag>> getAllHashtags() async {
    final db = await database;
    final rows = await db.query('hashtags', orderBy: 'is_pinned DESC, created_at DESC');
    return rows.map(Hashtag.fromMap).toList();
  }

  Future<Hashtag?> getHashtagById(int id) async {
    final db = await database;
    final rows = await db.query('hashtags', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Hashtag.fromMap(rows.first);
  }

  Future<int> insertHashtag(Hashtag hashtag) async {
    final db = await database;
    return db.insert('hashtags', hashtag.toMap()..remove('id'));
  }

  Future<void> updateHashtag(Hashtag hashtag) async {
    final db = await database;
    await db.update('hashtags', hashtag.toMap(), where: 'id = ?', whereArgs: [hashtag.id]);
  }

  Future<void> deleteHashtag(int id) async {
    final db = await database;
    await db.delete('photo_tags', where: 'hashtag_id = ?', whereArgs: [id]);
    await db.delete('hashtags', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------
  // Photo <-> Hashtag relations
  // ---------------------------------------------------------------------

  Future<void> tagPhoto(String assetId, int hashtagId) async {
    final db = await database;
    await db.insert(
      'photo_tags',
      PhotoTag(
        photoAssetId: assetId,
        hashtagId: hashtagId,
        dateTagged: DateTime.now().millisecondsSinceEpoch,
      ).toMap()
        ..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> tagPhotos(List<String> assetIds, List<int> hashtagIds) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final assetId in assetIds) {
      for (final hashtagId in hashtagIds) {
        batch.insert(
          'photo_tags',
          PhotoTag(photoAssetId: assetId, hashtagId: hashtagId, dateTagged: now).toMap()
            ..remove('id'),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
    await batch.commit(noResult: true);
  }

  Future<void> untagPhoto(String assetId, int hashtagId) async {
    final db = await database;
    await db.delete(
      'photo_tags',
      where: 'photo_asset_id = ? AND hashtag_id = ?',
      whereArgs: [assetId, hashtagId],
    );
  }

  /// All hashtags currently attached to a given photo/video asset.
  Future<List<Hashtag>> getHashtagsForAsset(String assetId) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT h.* FROM hashtags h
      INNER JOIN photo_tags pt ON pt.hashtag_id = h.id
      WHERE pt.photo_asset_id = ?
      ORDER BY h.is_pinned DESC, pt.date_tagged ASC
    ''', [assetId]);
    return rows.map(Hashtag.fromMap).toList();
  }

  /// A quick lookup map of assetId -> list of hashtag ids, for many assets
  /// at once (used to badge the gallery grid without N queries).
  Future<Map<String, List<int>>> getHashtagIdsForAssets(List<String> assetIds) async {
    if (assetIds.isEmpty) return {};
    final db = await database;
    final placeholders = List.filled(assetIds.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT photo_asset_id, hashtag_id FROM photo_tags WHERE photo_asset_id IN ($placeholders)',
      assetIds,
    );
    final map = <String, List<int>>{};
    for (final row in rows) {
      final assetId = row['photo_asset_id'] as String;
      final hashtagId = row['hashtag_id'] as int;
      map.putIfAbsent(assetId, () => []).add(hashtagId);
    }
    return map;
  }

  /// Ordered list of asset ids tagged with [hashtagId].
  Future<List<String>> getAssetIdsForHashtag(int hashtagId, {String sort = 'newest'}) async {
    final db = await database;
    String orderBy = 'date_tagged DESC';
    if (sort == 'oldest') orderBy = 'date_tagged ASC';
    if (sort == 'manual') orderBy = 'manual_order ASC, date_tagged DESC';
    final rows = await db.query(
      'photo_tags',
      columns: ['photo_asset_id'],
      where: 'hashtag_id = ?',
      whereArgs: [hashtagId],
      orderBy: orderBy,
    );
    return rows.map((r) => r['photo_asset_id'] as String).toList();
  }

  Future<int> getPhotoCountForHashtag(int hashtagId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as c FROM photo_tags WHERE hashtag_id = ?',
      [hashtagId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<int, int>> getPhotoCountsForAllHashtags() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT hashtag_id, COUNT(*) as c FROM photo_tags GROUP BY hashtag_id',
    );
    return {for (final r in rows) r['hashtag_id'] as int: r['c'] as int};
  }

  Future<void> updateManualOrder(String assetId, int hashtagId, int order) async {
    final db = await database;
    await db.update(
      'photo_tags',
      {'manual_order': order},
      where: 'photo_asset_id = ? AND hashtag_id = ?',
      whereArgs: [assetId, hashtagId],
    );
  }

  /// Combines multiple hashtags with AND/OR logic and returns matching
  /// asset ids, newest-tagged first.
  Future<List<String>> searchByHashtags(List<int> hashtagIds, {required bool matchAll}) async {
    if (hashtagIds.isEmpty) return [];
    final db = await database;
    final placeholders = List.filled(hashtagIds.length, '?').join(',');

    if (!matchAll) {
      final rows = await db.rawQuery('''
        SELECT DISTINCT photo_asset_id, MAX(date_tagged) as latest FROM photo_tags
        WHERE hashtag_id IN ($placeholders)
        GROUP BY photo_asset_id
        ORDER BY latest DESC
      ''', hashtagIds);
      return rows.map((r) => r['photo_asset_id'] as String).toList();
    }

    final rows = await db.rawQuery('''
      SELECT photo_asset_id, MAX(date_tagged) as latest, COUNT(DISTINCT hashtag_id) as matched
      FROM photo_tags
      WHERE hashtag_id IN ($placeholders)
      GROUP BY photo_asset_id
      HAVING matched = ?
      ORDER BY latest DESC
    ''', [...hashtagIds, hashtagIds.length]);
    return rows.map((r) => r['photo_asset_id'] as String).toList();
  }

  /// The set of asset ids that carry at least one *locked* hashtag which
  /// hasn't been unlocked in this session — used to hide them from the
  /// general gallery/search views.
  Future<Set<String>> getAssetIdsUnderLockedHashtags(List<int> lockedHashtagIds) async {
    if (lockedHashtagIds.isEmpty) return {};
    final db = await database;
    final placeholders = List.filled(lockedHashtagIds.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT DISTINCT photo_asset_id FROM photo_tags WHERE hashtag_id IN ($placeholders)',
      lockedHashtagIds,
    );
    return rows.map((r) => r['photo_asset_id'] as String).toSet();
  }

  Future<int> getTaggedPhotoCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(DISTINCT photo_asset_id) as c FROM photo_tags');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
