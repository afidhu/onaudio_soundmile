import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/audio_controller.dart';
import '../../controllers/player_controller.dart';
import '../../model/extended_song_model.dart';
import '../../util/color_category.dart';
import '../../util/constant.dart';
import '../../util/constant_widget.dart';
import '../player/music_player.dart';

class AllRecentMusicPage extends StatefulWidget {
  const AllRecentMusicPage({super.key});

  @override
  State<AllRecentMusicPage> createState() => _AllRecentMusicPageState();
}

class _AllRecentMusicPageState extends State<AllRecentMusicPage> {
  SongController songController = Get.find<SongController>();
  PlayerController playerController = Get.put(PlayerController());
  void backClick() {
    Constant.backToPrev(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgDark,
        bottomNavigationBar: buildBottomMusicBar(context),
        body: Column(
          children: [
            getVerSpace(10.h),
            getAppBar(() {
              backClick();
            }, 'Recent Music'),
            Expanded(child: buildRecentMusicList()),
          ],
        ),
      ),
    );
  }

  Column buildRecentMusicList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getVerSpace(20.h),
        Expanded(
          child: Obx(
            () {
              if (playerController.allSongs.isEmpty) {
                return const Text('No Songs available');
              } else {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns
                    crossAxisSpacing: 10.w, // Horizontal spacing between items
                    mainAxisSpacing: 10.h, // Vertical spacing between items
                    childAspectRatio: 0.8, // Aspect ratio of each item
                  ),
                  itemCount: playerController.recentSongs.length > 20
                      ? 20
                      : playerController.recentSongs.length,
                  itemBuilder: (context, index) {
                    // sor the sond according to their date of Modification
                    List<ExtendedSongModel> recentSongs =
                        playerController.recentSongs;

                    // Get the song at the current index
                    ExtendedSongModel recentSong = recentSongs[index];
                    return GestureDetector(
                      onTap: () async {
                        playerController.setPlaylistAndPlaySong(
                            recentSongs, index);
                        Get.to(() => MusicPlayer());
                      },
                      child: GridTile(
                        // The main content of the grid tile (e.g., the song image)
                        footer: Container(
                          height: 40.h,
                          padding: EdgeInsets.only(
                            left: 5.w,
                            right: 20.w,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(
                                0.6), // Semi-transparent background
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Song title and artist
                              SizedBox(
                                width: 90.w,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    getCustomFont(
                                      recentSong.title,
                                      10.sp,
                                      textColor,
                                      1,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    getVerSpace(1.h),
                                    getCustomFont(
                                      recentSong.artist ?? "Unknown Artist",
                                      8.sp,
                                      Colors.white,
                                      1,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                              ),
                              // More options icon
                              Expanded(
                                child:
                                    buildMoreVertButton(context, recentSong.id),
                              ),
                            ],
                          ),
                        ),
                        // The main content of the grid tile (e.g., the song image)
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: secondaryColor,
                          ),
                          child: buildRecentImage(context, recentSong.id),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        )
      ],
    );
  }
}
