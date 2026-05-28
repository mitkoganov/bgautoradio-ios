import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/radio_station.dart';
import '../models/radio_category.dart';

class RadioDatabase {
  static RadioDatabase? _instance;
  static Database? _db;

  RadioDatabase._();

  static RadioDatabase get instance {
    _instance ??= RadioDatabase._();
    return _instance!;
  }

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'bg_auto_radio.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE radio_stations (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            stream_url TEXT NOT NULL,
            logo_url TEXT,
            country TEXT NOT NULL DEFAULT 'Bulgaria',
            city TEXT,
            category TEXT NOT NULL DEFAULT 'other',
            tags TEXT NOT NULL DEFAULT '',
            website_url TEXT,
            bitrate INTEGER,
            codec TEXT,
            is_favorite INTEGER NOT NULL DEFAULT 0,
            is_verified INTEGER NOT NULL DEFAULT 0,
            last_checked TEXT,
            source TEXT,
            sort_order INTEGER NOT NULL DEFAULT 999
          )
        ''');
      },
    );
  }

  Future<void> upsertAll(List<RadioStation> stations) async {
    final db = await database;
    final batch = db.batch();
    for (final s in stations) {
      batch.insert(
        'radio_stations',
        _toRow(s),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> setFavorite(String id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'radio_stations',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<RadioStation>> getAll() async {
    final db = await database;
    final rows = await db.query('radio_stations', orderBy: 'sort_order ASC, name ASC');
    return rows.map(_fromRow).toList();
  }

  Future<List<RadioStation>> getFavorites() async {
    final db = await database;
    final rows = await db.query(
      'radio_stations',
      where: 'is_favorite = 1',
      orderBy: 'sort_order ASC, name ASC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<List<RadioStation>> getByCategory(RadioCategory category) async {
    final db = await database;
    final rows = await db.query(
      'radio_stations',
      where: 'category = ?',
      whereArgs: [category.name],
      orderBy: 'sort_order ASC, name ASC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<List<RadioStation>> search(String query) async {
    final db = await database;
    final q = '%${query.toLowerCase()}%';
    final rows = await db.query(
      'radio_stations',
      where: 'LOWER(name) LIKE ? OR LOWER(city) LIKE ? OR LOWER(tags) LIKE ?',
      whereArgs: [q, q, q],
      orderBy: 'sort_order ASC, name ASC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<RadioStation?> getById(String id) async {
    final db = await database;
    final rows = await db.query('radio_stations', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  Future<int> count() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM radio_stations');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Set<String>> getFavoriteIds() async {
    final db = await database;
    final rows = await db.query('radio_stations', columns: ['id'], where: 'is_favorite = 1');
    return rows.map((r) => r['id'] as String).toSet();
  }

  Future<void> pruneNonFavorites(Set<String> keepIds) async {
    if (keepIds.isEmpty) return;
    final db = await database;
    final placeholders = keepIds.map((_) => '?').join(',');
    await db.delete(
      'radio_stations',
      where: 'is_favorite = 0 AND id NOT IN ($placeholders)',
      whereArgs: keepIds.toList(),
    );
  }

  Map<String, dynamic> _toRow(RadioStation s) => {
    'id': s.id,
    'name': s.name,
    'stream_url': s.streamUrl,
    'logo_url': s.logoUrl,
    'country': s.country,
    'city': s.city,
    'category': s.category.name,
    'tags': s.tags.join(','),
    'website_url': s.websiteUrl,
    'bitrate': s.bitrate,
    'codec': s.codec,
    'is_favorite': s.isFavorite ? 1 : 0,
    'is_verified': s.isVerified ? 1 : 0,
    'last_checked': s.lastChecked,
    'source': s.source,
    'sort_order': s.sortOrder,
  };

  RadioStation _fromRow(Map<String, dynamic> row) => RadioStation(
    id: row['id'] as String,
    name: row['name'] as String,
    streamUrl: row['stream_url'] as String,
    logoUrl: row['logo_url'] as String?,
    country: row['country'] as String,
    city: row['city'] as String?,
    category: RadioCategory.fromString(row['category'] as String),
    tags: (row['tags'] as String).isEmpty ? [] : (row['tags'] as String).split(','),
    websiteUrl: row['website_url'] as String?,
    bitrate: row['bitrate'] as int?,
    codec: row['codec'] as String?,
    isFavorite: (row['is_favorite'] as int) == 1,
    isVerified: (row['is_verified'] as int) == 1,
    lastChecked: row['last_checked'] as String?,
    source: row['source'] as String?,
    sortOrder: row['sort_order'] as int,
  );
}
