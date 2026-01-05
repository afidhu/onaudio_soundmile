import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_mile/model/extended_song_model.dart';
import 'player_controller.dart';

class RecentSongController extends GetxController {
  final PlayerController playerController = Get.find<PlayerController>();
  var recentPlayedSongs = <ExtendedSongModel>[].obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   // loadRecentPlayedSongs();
  // }

  /// Add song and persist
  Future<void> addSongToRecent(ExtendedSongModel song) async {
    recentPlayedSongs.removeWhere((s) => s.id == song.id);
    recentPlayedSongs.insert(0, song);

    if (recentPlayedSongs.length > 10) {
      recentPlayedSongs.removeLast();
    }

    await _saveRecentPlayedSongIds();
  }

  /// Save song IDs
  Future<void> _saveRecentPlayedSongIds() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> ids =
        recentPlayedSongs.map((song) => song.id.toString()).toList();
    await prefs.setStringList('recent_played_song_ids', ids);
  }

  /// Load recent songs using allSongs from PlayerController
  Future<void> loadRecentPlayedSongs() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String>? ids = prefs.getStringList('recent_played_song_ids');

    if (ids != null) {
      final List<int> songIds = ids.map((e) => int.parse(e)).toList();
      final List<ExtendedSongModel> matchedSongs = songIds
          .map((id) =>
              playerController.allSongs.firstWhereOrNull((s) => s.id == id))
          .whereType<ExtendedSongModel>()
          .toList();
      if (matchedSongs.isNotEmpty) {
        playerController.playingSong.value = matchedSongs.first;
      }
      recentPlayedSongs.assignAll(matchedSongs);

      // Clear and rebuild the songList for the audio player
      playerController.playList.value = matchedSongs;
      playerController.songList.clear();
      playerController.songList = matchedSongs
          .map((song) => AudioSource.uri(
                Uri.parse(song.uri!),
                tag: MediaItem(
                  id: song.id.toString(),
                  album: song.album ?? "Unknown Album",
                  title: song.displayNameWOExt,
                  artUri: song.artworkUri,
                ),
              ))
          .toList();

      // Set the audio source for the audio player
      await playerController.audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: playerController.songList),
        initialIndex: 0, // Start with the first song
      );
    }
  }
}
