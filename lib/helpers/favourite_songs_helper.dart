import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:on_audio_query/on_audio_query.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'music_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY,
            title TEXT,
            data TEXT,
            artist TEXT,
            album TEXT,
            duration INTEGER
          )
        ''');
      },
    );
  }

  Future<void> addToFavorites(SongModel song) async {
    final db = await database;
    await db.insert(
      'favorites',
      {
        'id': song.id,
        'title': song.title,
        'data': song.data,
        'artist': song.artist,
        'album': song.album,
        'duration': song.duration
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFromFavorites(int songId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [songId],
    );
  }

  Future<bool> isFavorite(int songId) async {
    final db = await database;
    final res = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [songId],
    );
    return res.isNotEmpty;
  }

  Future<List<SongModel>> getFavoriteSongs() async {
    final db = await database;
    final maps = await db.query('favorites');

    return maps.map((map) {
      return SongModel({
        '_id': map['id'],
        'title': map['title'],
        'data': map['data'],
        'artist': map['artist'],
        'album': map['album'],
        'duration': map['duration'],
      });
    }).toList();
  }
}
