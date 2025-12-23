import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SeraDatabase {
  static final SeraDatabase _instance = SeraDatabase._internal();
  factory SeraDatabase() => _instance;
  SeraDatabase._internal();

  static SeraDatabase get instance => _instance;

  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'sera.db');

    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sos_history (
            id TEXT PRIMARY KEY,
            latitude REAL,
            longitude REAL,
            message TEXT,
            timestamp TEXT,
            status TEXT,
            evidence TEXT,
            synced INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            phone TEXT,
            blood_type TEXT,
            medical_history TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Migration for v2: Add evidence and synced columns
          try {
            await db
                .execute('ALTER TABLE sos_history ADD COLUMN evidence TEXT');
          } catch (e) {/* ignore if exists */}
          try {
            await db
                .execute('ALTER TABLE sos_history ADD COLUMN synced INTEGER');
          } catch (e) {/* ignore if exists */}
        }
      },
    );
  }

  Future<void> insertSos(Map<String, dynamic> data) async {
    if (_db == null) await init();
    try {
      await _db!.insert('sos_history', data,
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      // swallow - higher level can log
    }
  }

  Future<List<Map<String, dynamic>>> getSosHistory({int limit = 100}) async {
    if (_db == null) await init();
    final rows = await _db!
        .query('sos_history', orderBy: 'timestamp DESC', limit: limit);
    return rows;
  }

  Future<void> clearSosHistory() async {
    if (_db == null) await init();
    await _db!.delete('sos_history');
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
