import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sound_mile/controllers/playlist_controller.dart';
import 'package:sound_mile/pages/tab/library_tab/upper_library_tab/playlist_tab/Add_playlist_dialog.dart';
import 'package:sound_mile/pages/tab/library_tab/upper_library_tab/playlist_tab/playlist_details_page.dart';
import 'package:sound_mile/util/color_category.dart';
import '../../../../../model/extended_song_model.dart';
import '../../../../../util/constant_widget.dart';

class PlaylistTab extends StatefulWidget {
  const PlaylistTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PlaylistTabState createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<PlaylistTab> {
  final PlayListController playListController = Get.put(PlayListController());
  Future<List<ExtendedSongModel>> fetchSongsInPlaylist(int playlistId) async {
    List<ExtendedSongModel> songs =
        await playListController.fetchSongsInPlaylist(playlistId);
    return songs;
  }

  @override
  void initState()  {
    super.initState();
    playListController.getPlaylistsWithSongCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: secondaryColor,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.all(
                  Radius.elliptical(10.0.r, 20.0.r),
                ),
              ),
              child: MaterialButton(
                onPressed: () {
                  showNewPlaylistModal(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.add, color: textColor, size: 40),
                    getHorSpace(10.w),
                    getCustomFont("New Playlist", 12, textColor, 1)
                  ],
                ),
              )).marginOnly(top: 10.h, left: 18.w, right: 18.w),
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: ScrollController(),
                itemCount: playListController.playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playListController.playlists[index];
                  return ListTile(
                    onTap: () async {
                      // Fetch songs in the playlist when tapped
                      await fetchSongsInPlaylist(playlist.id!);
                      Get.to(
                        () => PlaylistDetails(
                          playlistId: playlist.id!,
                          playlistName: playlist.name!,
                        ),
                        transition: Transition.fadeIn,
                        duration: const Duration(milliseconds: 200),
                      );
                    },
                    leading: Icon((playlist.id ==1)? CupertinoIcons.heart_circle_fill: Icons.playlist_play_rounded,
                        size: 40.h, color: textColor),

                    title: Obx(
                        () => getCustomFont(playListController.playlists[index].name!, 12, textColor, 1)),
                    subtitle: Obx(
                      () => getCustomFont(
                          playListController.playlists[index].songsCount.toString(), 10, textColor, 1),
                    ),
                    trailing:
                        buildPlaylistMoreVertButton(context, playlist.id!),
                    // onTap: () => _showPlaylistDialog(context, playlist),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => showAddPlaylistModal(context, int ),
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
