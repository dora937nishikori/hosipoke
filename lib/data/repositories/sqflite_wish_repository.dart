import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../../domain/repositories/wish_repository.dart';
import '../../domain/wish.dart';

class SqfliteWishRepository implements WishRepository {
  static const _tableName = 'wishes';
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'hosipoke.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            note TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            imagePath TEXT NOT NULL,
            priority INTEGER NOT NULL,
            aspectRatio REAL NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<List<Wish>> fetchAll() async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Wish.fromMap(map)).toList();
  }

  @override
  Future<void> save(Wish wish) async {
    final db = await database;
    await db.insert(_tableName, wish.toMap());
  }

  @override
  Future<void> update(Wish wish) async {
    final db = await database;
    await db.update(
      _tableName,
      wish.toMap(),
      where: 'id = ?',
      whereArgs: [wish.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
