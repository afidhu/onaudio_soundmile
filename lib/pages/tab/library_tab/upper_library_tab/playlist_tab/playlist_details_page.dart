import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:sound_mile/pages/tab/library_tab/upper_library_tab/playlist_tab/add_to_playlist.dart';
import 'package:sound_mile/util/color_category.dart';

import '../../../../../controllers/home_conroller.dart';
import '../../../../../controllers/player_controller.dart';
import '../../../../../controllers/playlist_controller.dart'
    show PlayListController;
import '../../../../../util/constant_widget.dart';

class PlaylistDetails extends StatefulWidget {
  final int playlistId;
  final String playlistName;

  const PlaylistDetails(
      {super.key, required this.playlistName, required this.playlistId});

  // @override
  State<PlaylistDetails> createState() => _PlaylistDetailsState();
}

class _PlaylistDetailsState extends State<PlaylistDetails> {
  PlayerController playerController = Get.put(PlayerController());
  PlayListController playListController = Get.put(PlayListController());
  HomeController homeController = Get.put(HomeController());

  @override
  initState() {
    super.initState();
    fetchSongsInPlaylist(widget.playlistId);
  }

  fetchSongsInPlaylist(int playlistId) async {
    await playListController.fetchSongsInPlaylist(playlistId);
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      bottomNavigationBar: buildBottomMusicBar(context),
      body: Column(
        children: [
          // SizedBox(
          //   height: 100.h,
          // ),
          Container(
            height: 150,
            color: hintColor,
            padding: const EdgeInsets.only(top: 30),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30.h,
                  backgroundColor: secondaryColor,
                  child: Text(
                    widget.playlistName.substring(0, 1),
                    style: TextStyle(color: textColor, fontSize: 25.sp),
                  ),
                ),
                getHorSpace(20.w),
                Expanded(
                  child: Obx(
                    () => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getCustomFont(widget.playlistName, 20.sp, textColor, 1,
                            fontWeight: FontWeight.w700),
                        getVerSpace(5.h),
                        getCustomFont(
                            "${playListController.playlistSongs.length} Songs",
                            15.sp,
                            searchHint,
                            1,
                            fontWeight: FontWeight.w400),
                      ],
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Get.to(AddToPlaylist(
                        playlistId: widget.playlistId,
                      ));
                    },
                    icon: Icon(
                      Icons.add,
                      color: textColor,
                    ))
              ],
            ).paddingSymmetric(horizontal: 10),
          ),

          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: playListController.playlistSongs.length,
                itemBuilder: (context, index) {
                  final song = playListController.playlistSongs[index];
                  return GestureDetector(
                    onTap: () {
                      playerController.setPlaylistAndPlaySong(
                          playListController.playlistSongs, index);
                      homeController.setIsShowPlayingData(true);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 15.h),
                      padding: EdgeInsets.only(
                        left: 12.h,
                        top: 12.h,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22.h)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 60.h,
                            width: 60.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22.h),
                            ),
                            child: QueryArtworkWidget(
                              artworkBorder: BorderRadius.circular(20.h),
                              id: song.id,
                              type: ArtworkType.AUDIO,
                              nullArtworkWidget: ClipRRect(
                                borderRadius: BorderRadius.circular(20.h),
                                child: Image.asset(
                                  'assets/images/headphones.png', // Path to your asset imageA
                                  fit: BoxFit.cover,
                                  height: 60.h,
                                  width: 60.h,
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
                          getHorSpace(10.h),
                          IconButton(
                            icon: Icon(
                              CupertinoIcons.xmark,
                              color: Colors.red,
                              size: 20.h,
                            ),
                            onPressed: () {
                              // Add your onPressed code here!
                              int songId = song.id;
                              playListController.removeSongFromPlaylist(
                                  widget.playlistId, songId);
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
