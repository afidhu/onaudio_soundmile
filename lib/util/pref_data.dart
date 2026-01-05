import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/extended_song_model.dart';

class PrefData {
  final AudioPlayer audioPlayer = AudioPlayer();
  static const String _usernameKey = "username";
  static const String _idKey = "id";
  static const String _permission = "isPrermitted";
  static const String _isShowPlayingKey = "isShowPlaying";
  static const String _email = "";
  static const String _playingSongKey = "playingSong";

  /// Save a list of song IDs in SharedPreferences
  Future<void> saveRecentPlayedSongIds(List<int> songIds) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the list of integers to a list of strings
    List<String> songIdStrings = songIds.map((id) => id.toString()).toList();
    await prefs.setStringList('recent_played_song_ids', songIdStrings);
  }
/// Load a list of song IDs from SharedPreferences
Future<List<int>> loadRecentPlayedSongIds() async {
  final prefs = await SharedPreferences.getInstance();
  // Retrieve the list of strings and convert it back to a list of integers
  List<String>? songIdStrings = prefs.getStringList('recent_played_song_ids');
  if (songIdStrings != null) {
    return songIdStrings.map((id) => int.parse(id)).toList();
  }
  return []; // Return an empty list if no data is found
}
  static Future<void> initializeDefaults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_permission) == null) {
      await prefs.setBool(_permission, false);
    }
    if (prefs.getBool(_isShowPlayingKey) == null) {
      await prefs.setBool(_isShowPlayingKey, false);
    }
  }

  static Future<void> setIsShowPlaying(bool sizes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isShowPlayingKey, sizes);
  }

  static Future<bool> getIsShowPlaying() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool intValue = prefs.getBool(_isShowPlayingKey) ?? true;
    return intValue;
  }

  // Store the username
  static Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  // Retrieve the username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  static Future<void> setEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_email, email);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_email);
  }

  // Store the user ID
  static Future<void> setUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_idKey, id);
  }

  // Retrieve the user ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_idKey);
  }

  // Store login status as a boolean
  static Future<void> setIsPermitted(bool isPermitted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permission, isPermitted);
  }

  // Retrieve login status as a boolean
  static Future<bool?> getIsPermitted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permission);
  }

  // Clear all session data (e.g., on logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.remove(_idKey);
    await prefs.remove(_permission);
    await prefs.remove(_isShowPlayingKey);
    await prefs.remove(_email);
    await prefs.remove(_playingSongKey);
  }

  static Future<String> getUsernameText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? "No Username"; // Fallback if null
  }

  static Future<String> getEmailText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_email) ?? "No Email"; // Fallback if null
  }

  static Future<int> getIdText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_idKey) ?? 0;
  }

  // Save the current playing song to SharedPreferences
  static Future<void> savePlayingSong(ExtendedSongModel? playingSong) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (playingSong != null) {
      String songJson = jsonEncode(playingSong.toJson());
      await prefs.setString(_playingSongKey, songJson);
    }
  }

  // Load the playing song from SharedPreferences
  static Future<ExtendedSongModel?> loadPlayingSong() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? songJson = prefs.getString(_playingSongKey);
    if (songJson != null) {
      Map<String, dynamic> songMap = jsonDecode(songJson);
      return ExtendedSongModel.fromJson(songMap);
    }
    return null;
  }
}

PrefData prefData = PrefData();
