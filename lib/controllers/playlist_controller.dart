import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sound_mile/controllers/audio_controller.dart';
import 'package:sound_mile/model/extended_song_model.dart';
import 'package:sound_mile/util/constant_widget.dart';

import '../helpers/playlist_helper.dart';
import '../model/playlist.dart';

class PlayListController extends GetxController {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final PlaylistHelper playlistHelper = PlaylistHelper.PlaylistHelper();
  SongController songController = Get.put(SongController());
  var playlists = <PlayList>[].obs;

  var isLoading = false.obs;
  var playlistSongs = <ExtendedSongModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getPlaylistsWithSongCount();
    fetchSongsInPlaylist(1);
  }

  Future<List<ExtendedSongModel>> fetchSongsInPlaylist(int playlistId) async {
    playlistSongs.clear(); // Clear old data before fetching new
    playlistSongs.value = await playlistHelper.getSongsInPlaylist(playlistId);

    return playlistSongs;
  }

  Future<List<PlayList>> getPlaylistsWithSongCount() async {
    var returnValue = await playlistHelper.getPlaylistsWithSongCount();
    playlists.value = returnValue;
    return returnValue;
  }

  /// Remove a song from a playlist
  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    await playlistHelper.removeSongFromPlaylist(playlistId, songId);
    // Refresh the playlist songs after removal
    await fetchSongsInPlaylist(playlistId);
    await getPlaylistsWithSongCount();
  }
}
