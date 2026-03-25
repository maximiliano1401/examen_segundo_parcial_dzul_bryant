import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game.dart';

class DatabaseHelper {
  static const _dbName = 'games.db';
  static const _dbVersion = 1;
  static const _tableName = 'games';

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        platform TEXT NOT NULL,
        status TEXT NOT NULL,
        rating REAL NOT NULL,
        genre TEXT,
        imageUrl TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // CREATE
  Future<int> insertGame(Game game) async {
    final db = await database;
    final map = game.toMap()..remove('id');
    return db.insert(
      _tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ ALL
  Future<List<Game>> getAllGames() async {
    final db = await database;
    final rows = await db.query(_tableName, orderBy: 'createdAt DESC');
    return rows.map(Game.fromMap).toList();
  }

  // READ BY ID
  Future<Game?> getGameById(int id) async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Game.fromMap(rows.first);
  }

  // UPDATE
  Future<int> updateGame(Game game) async {
    final db = await database;
    return db.update(
      _tableName,
      game.toMap(),
      where: 'id = ?',
      whereArgs: [game.id],
    );
  }

  // DELETE
  Future<int> deleteGame(int id) async {
    final db = await database;
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // QUERY BY STATUS
  Future<List<Game>> getGamesByStatus(String status) async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'createdAt DESC',
    );
    return rows.map(Game.fromMap).toList();
  }

  // QUERY BY PLATFORM
  Future<List<Game>> getGamesByPlatform(String platform) async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'platform = ?',
      whereArgs: [platform],
      orderBy: 'createdAt DESC',
    );
    return rows.map(Game.fromMap).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
