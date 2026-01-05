import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_mile/controllers/player_controller.dart';
import 'package:sound_mile/controllers/recent_song_controller.dart';

final RecentSongController recentSongController =
    Get.put(RecentSongController());
final PlayerController playerController = Get.put(PlayerController());

class SongController extends GetxController {
  final audioQuery = OnAudioQuery();
  var isGranted = false.obs;
  @override
  void onInit() {
    super.onInit();
  }

  Future<List<SongModel>> checkPermission() async {
    var permision = await Permission.storage.request();
    if (permision.isGranted) {
      return await PlayerController().fetchSongs();
    } else {
      return checkPermission();
    }
  }

  Future<void> deleteSong(int songId) async {
    playerController.allSongs.removeWhere(
        (s) => s.id == songId); // removingd song in thr all songs List
    playerController.recentSongs.removeWhere(
        (s) => s.id == songId); // removing songe in recent Song list
    playerController.playList
        .removeWhere((s) => s.id == songId); // removing song in the playlist
    playerController.update();
    recentSongController.recentPlayedSongs.removeWhere(
        (s) => s.id == songId); // removing song in the recent songs
    recentSongController.update();
  }
}
