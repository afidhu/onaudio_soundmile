import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:sound_mile/model/extended_song_model.dart';

import '../../../../../controllers/audio_controller.dart';
import '../../../../../controllers/player_controller.dart';
import '../../../../../util/color_category.dart';
import '../../../../../util/constant.dart';
import '../../../../../util/constant_widget.dart';
import '../../../../player/music_player.dart';

class CategorySongs extends StatefulWidget {
  final String title;
  final List<ExtendedSongModel> songs;
  const CategorySongs({super.key, required this.title, required this.songs});

  @override
  State<CategorySongs> createState() => _CategorySongsState();
}

class _CategorySongsState extends State<CategorySongs> {
  SongController songController = Get.find<SongController>();
  PlayerController playerController = Get.put(PlayerController());
  void backClick() {
    Constant.backToPrev(context);
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
            }, widget.title),
            Expanded(child: buildAllMusicList()),
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
                  padding: EdgeInsets.only(right: 0.h, left: 6.h),
                  itemCount: widget.songs.length,
                  itemBuilder: (context, index) {
                    final allSongs = widget.songs;
                    ExtendedSongModel song = allSongs[index];
                    return GestureDetector(
                      onTap: () async {
                        playerController.setPlaylistAndPlaySong(
                            allSongs, index);

                        homeController.setIsShowPlayingData(true);
                        Get.to(() => MusicPlayer());
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
                                    'assets/images/headphones.png', // Path to your asset imageA
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
                            buildMoreVertButton(context, song.id)
                            // getHorSpace(12.h),
                            // Icon(
                            //   Icons.play_arrow,
                            //   color: textColor,
                            //   size: 30,
                            // ),
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
