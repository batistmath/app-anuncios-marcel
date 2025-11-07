import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import '../models/anuncio.dart';

class DBHelper {
  static sql.Database? _database;

  static const String _tableName = 'anuncios';

  static Future<sql.Database> _initDB() async {
    final dbPath = await sql.getDatabasesPath();
    final dbFile = path.join(dbPath, 'anuncios.db');

    return await sql.openDatabase(
      dbFile,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            titulo TEXT,
            descricao TEXT,
            preco REAL,
            imagePath TEXT
          )
        ''');
      },
    );
  }

  static Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<void> insert(Anuncio anuncio) async {
    final db = await database;
    await db.insert(
      _tableName,
      anuncio.toMap(),
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  static Future<void> update(Anuncio anuncio) async {
    final db = await database;
    await db.update(
      _tableName,
      anuncio.toMap(),
      where: 'id = ?',
      whereArgs: [anuncio.id],
    );
  }

  static Future<List<Anuncio>> getAll() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    return List.generate(maps.length, (i) {
      return Anuncio.fromMap(maps[i]);
    });
  }

  static Future<void> delete(String id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}