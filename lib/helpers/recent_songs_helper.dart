import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'dart:async';

import '../controllers/player_controller.dart';
import '../model/extended_song_model.dart';

class RecentSongsHelper {
  static final RecentSongsHelper _instance = RecentSongsHelper._internal();
  factory RecentSongsHelper() => _instance;
  static Database? _database;
  final StreamController<List<ExtendedSongModel>> _recentSongsController = StreamController.broadcast();

  RecentSongsHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'music_app.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS recent_songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER NOT NULL
      )
      '''
    );
  }

  Future<void> addSongToRecent(int songId) async {
    final db = await database;
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS recent_songs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          song_id INTEGER NOT NULL
        )
      ''');
      
      await db.insert('recent_songs', {'song_id': songId});

      await db.execute(
        '''
        DELETE FROM recent_songs
        WHERE id NOT IN (
          SELECT id FROM recent_songs ORDER BY id DESC LIMIT 10
        )
        '''
      );
      fetchRecentSongs();  // Notify stream listeners
    } catch (e) {
    }
  }

  void fetchRecentSongs() async {
    final db = await database;
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS recent_songs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          song_id INTEGER NOT NULL
        )
      ''');

      final List<Map<String, dynamic>> maps = await db.query(
        'recent_songs',
        columns: ['song_id'],
        orderBy: 'id DESC',
        limit: 10,
      );

      List<int> songIds = maps.map((map) => map['song_id'] as int).toList();

      List<ExtendedSongModel> recentSongs = PlayerController().allSongs
          .where((song) => songIds.contains(song.id))
          .toList();

      _recentSongsController.add(recentSongs); // Emit new data to the stream
    } catch (e) {
    }
  }

  Stream<List<ExtendedSongModel>> get recentSongsStream async* {
    yield* _recentSongsController.stream;
  }

  void dispose() {
    _recentSongsController.close();
  }
}
