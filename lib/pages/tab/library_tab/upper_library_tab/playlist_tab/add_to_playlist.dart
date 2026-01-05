import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:sound_mile/helpers/playlist_helper.dart';
import 'package:sound_mile/model/extended_song_model.dart';
import '../../../../../controllers/audio_controller.dart';
import '../../../../../controllers/player_controller.dart';
import '../../../../../controllers/playlist_controller.dart'
    show PlayListController;
import '../../../../../util/color_category.dart';
import '../../../../../util/constant.dart';
import '../../../../../util/constant_widget.dart';

// ignore: must_be_immutable
class AddToPlaylist extends StatefulWidget {
  int playlistId;
  AddToPlaylist({super.key, required this.playlistId});

  @override
  State<AddToPlaylist> createState() => _AddToPlaylistState();
}

class _AddToPlaylistState extends State<AddToPlaylist> {
  SongController songController = Get.find<SongController>();
  PlayerController playerController = Get.put(PlayerController());
  final PlayListController playListController = Get.find<PlayListController>();

  // Set to store selected song IDs
  final Set<int> selectedSongs = {};

  void backClick() {
    Constant.backToPrev(context);
  }

  void addToPlaylist() async {
    for (int songId in selectedSongs) {
      await PlaylistHelper.PlaylistHelper()
          .addSongToPlaylist(widget.playlistId, songId);
    }

    // Refresh playlist if it's already opened

    await playListController.fetchSongsInPlaylist(widget.playlistId);
    await playListController.getPlaylistsWithSongCount();

    Get.back();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Added ${selectedSongs.length} songs to the playlist"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: buildBottomMusicBar(context),
        backgroundColor: bgDark,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            getVerSpace(10.h),
            getAppBar(() {
              backClick();
            }, 'All Music'),
            Expanded(
                child: Stack(
              children: [
                buildAllMusicList(),
                if (selectedSongs.isNotEmpty)
                  Positioned(
                    right: 0,
                    bottom: 10,
                    child: FloatingActionButton(
                      onPressed: addToPlaylist,
                      child: Text("Add"),
                    ),
                  ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Column buildAllMusicList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getVerSpace(10.h),
        Expanded(
          child: Obx(
            () {
              if (playerController.allSongs.isEmpty) {
                return const Text('No Songs available');
              } else {
                return ListView.builder(
                  itemCount: playerController.allSongs.length,
                  itemBuilder: (context, index) {
                    ExtendedSongModel song = playerController.allSongs[index];
                    final isSelected = selectedSongs.contains(song.id);

                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedSongs.remove(song.id);
                          } else {
                            selectedSongs.add(song.id);
                          }
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15.h),
                        padding: EdgeInsets.only(
                          left: 12.h,
                          top: 12.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 60.h,
                              width: 60.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22.h),
                              ),
                              child: QueryArtworkWidget(
                                artworkBorder: BorderRadius.circular(22.h),
                                id: song.id,
                                type: ArtworkType.AUDIO,
                                nullArtworkWidget: ClipRRect(
                                  borderRadius: BorderRadius.circular(22.h),
                                  child: Image.asset(
                                    'assets/images/headphones.png',
                                    fit: BoxFit.cover,
                                    height: 60.h,
                                    width: 60.w,
                                  ),
                                ),
                              ),
                            ),
                            getHorSpace(12.h),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  getCustomFont(song.title, 15.sp, textColor, 1,
                                      fontWeight: FontWeight.w700),
                                  getVerSpace(6.h),
                                  getCustomFont(
                                    "${song.artist}  ",
                                    10.sp,
                                    searchHint,
                                    1,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedSongs.add(song.id);
                                  } else {
                                    selectedSongs.remove(song.id);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
