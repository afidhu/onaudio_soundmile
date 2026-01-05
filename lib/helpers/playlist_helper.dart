import 'package:sound_mile/util/constant_widget.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

import '../controllers/player_controller.dart';
import '../model/extended_song_model.dart';
import '../model/playlist.dart';

class PlaylistHelper {
  static final PlaylistHelper _instance = PlaylistHelper._internal();
  // ignore: non_constant_identifier_names
  factory PlaylistHelper.PlaylistHelper() => _instance;
  static Database? _database;

  PlaylistHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'music_app.db');
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );

    // Ensure "favourites" playlist exists
    final existing = await db.query(
      'playlists',
      where: 'name = ?',
      whereArgs: ['Favourites'],
    );

    if (existing.isEmpty) {
      await db.insert('playlists', {'name': 'Favourites'});
    }

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE playlist_songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlist_id INTEGER NOT NULL,
        song_id INTEGER NOT NULL,
        FOREIGN KEY (playlist_id) REFERENCES playlists (id)
      )
    ''');

    // Insert predefined "favourites" playlist
    await db.insert('playlists', {'name': 'Favourites'});
  }

  Future<int> createPlaylist(String name) async {
    final db = await database;
    return await db.insert('playlists', {'name': name});
  }

  Future<int> addSongToPlaylist(int playlistId, int songId) async {
    final db = await database;
    playlistId == 1 ? playerController.favouriteSongsIds.add(songId) : null;
    return await db.insert('playlist_songs', {
      'playlist_id': playlistId,
      'song_id': songId,
    });
  }

  Future<List<String>> getPlaylists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('playlists');
    return List.generate(maps.length, (i) {
      return maps[i]['name'];
    });
  }

  Future<int?> getPlaylistIdByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'playlists',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return maps.first['id'] as int?;
    } else {
      return null;
    }
  }

  Future<List<PlayList>> getPlaylistsWithSongCount() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT playlists.id, playlists.name, COUNT(playlist_songs.id) as song_count
      FROM playlists
      LEFT JOIN playlist_songs ON playlists.id = playlist_songs.playlist_id
      GROUP BY playlists.id, playlists.name
    ''');

    return List.generate(maps.length, (i) {
      return PlayList.fromMap(maps[i]);
    });
  }

  Future<List<int>> getSongIdsForPlaylist(int playlistId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'playlist_songs',
      columns: ['song_id'],
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );
    return maps.map((map) => map['song_id'] as int).toList();
  }

  Future<void> deletePlaylist(int playlistId) async {
    final db = await database;

    // Get the name of the playlist before deletion
    final List<Map<String, dynamic>> result = await db.query(
      'playlists',
      where: 'id = ?',
      whereArgs: [playlistId],
    );

    if (result.isNotEmpty && result.first['name'] == 'Favourites') {
      // Prevent deletion of "favourites"
      return;
    }

    await db.execute('DELETE FROM playlists WHERE id = ?', [playlistId]);
    await db.execute(
        'DELETE FROM playlist_songs WHERE playlist_id = ?', [playlistId]);
  }

  Future<List<ExtendedSongModel>> getSongsInPlaylist(int playlistId) async {
    final db = await database;

    // Query the playlist_songs table to get song IDs for the given playlist
    final List<Map<String, dynamic>> maps = await db.query(
      'playlist_songs',
      columns: ['song_id'],
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );

    // Extract song IDs from the query result
    List<int> songIds = maps.map((map) => map['song_id'] as int).toList();
    if (playlistId == 1) {
      playerController.favouriteSongsIds.value = songIds;
    }
    // Filter songs from allSongs and ensure no duplicates
    List<ExtendedSongModel> playlistSongs = PlayerController()
        .allSongs
        .where((song) => songIds.contains(song.id))
        .toSet() // Convert to a Set to remove duplicates
        .toList(); // Convert back to a List

    return playlistSongs;
  }

  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    final db = await database;
    playlistId == 1 ? playerController.favouriteSongsIds.remove(songId) : null;
    // Delete the song from the playlist_songs table
    await db.delete(
      'playlist_songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );
  }
}
