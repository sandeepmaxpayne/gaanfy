import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/playback_checkpoint.dart';

class LocalDatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final databasesPath = await getDatabasesPath();
    final databasePath = path.join(databasesPath, 'gaanfy_playback.db');

    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE playback_checkpoints(
            type TEXT PRIMARY KEY,
            queue_json TEXT NOT NULL,
            current_index INTEGER NOT NULL,
            position_ms INTEGER NOT NULL,
            is_shuffle INTEGER NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<void> saveCheckpoint(PlaybackCheckpoint checkpoint) async {
    final db = await database;
    await db.insert(
      'playback_checkpoints',
      checkpoint.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PlaybackCheckpoint?> loadCheckpoint(String type) async {
    final db = await database;
    final rows = await db.query(
      'playback_checkpoints',
      where: 'type = ?',
      whereArgs: [type],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }
    return PlaybackCheckpoint.fromMap(rows.first);
  }
}
