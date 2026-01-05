import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:sound_mile/controllers/audio_controller.dart';
import 'package:sound_mile/controllers/player_controller.dart';
import 'package:sound_mile/model/extended_song_model.dart';
import 'package:sound_mile/pages/view%20all/all_recent_music.dart';
import '../../controllers/home_conroller.dart';
import '../../util/color_category.dart';
import '../../util/constant_widget.dart';
import '../view all/all_music.dart';

class TabHome extends StatefulWidget {
  const TabHome({
    Key? key,
  });

  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  HomeScreenController controller = Get.put(HomeScreenController());
  SongController songController = Get.find<SongController>();
  PlayerController playerController = Get.put(PlayerController());
  HomeController homeController = Get.put(HomeController());

  bool isGranted = false;

  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        getVerSpace(50.h),
        buildAppBar(),
        // getVerSpace(30.h),
        // buildSearchWidget(context),
        // getVerSpace(30.h),
        Expanded(
          flex: 1,
          child: ListView(
            primary: true,
            shrinkWrap: false,
            children: [
              // buildSliderWidget(),
              getVerSpace(10.h),
              buildRecentMusicList(),
              getVerSpace(10.h),
              buildAllMusicList(),
              // getVerSpace(5.h),ssss
              // buildArtistList(),
              getVerSpace(5.h),
            ],
          ),
        )
      ],
    );
  }

  Column buildAllMusicList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getCustomFont("All Music", 18.sp, textColor, 1,
                fontWeight: FontWeight.w700),
            IconButton(
              onPressed: () {
                Get.to(
                  AllMusicPage(),
                  transition: Transition.rightToLeftWithFade,
                );
              },
              icon: Row(
                children: [
                  getCustomFont("View All", 12.sp, textColor, 1,
                      fontWeight: FontWeight.w700),
                  getHorSpace(8.h),
                  Icon(
                    CupertinoIcons.arrow_right,
                    color: textColor,
                  ),
                ],
              ),
            )
          ],
        ).paddingSymmetric(horizontal: 20.h),
        getVerSpace(10.h),
        Obx(
          () {
            if (playerController.allSongs.isEmpty) {
              return const Text('No Songs available');
            } else {
              return ListView.builder(
                padding: EdgeInsets.only(right: 0.h, left: 6.h),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                primary: false,
                itemCount: playerController.allSongs.length > 40
                    ? 40
                    : playerController.allSongs.length,
                itemBuilder: (context, index) {
                  final allSongs = playerController.allSongs;
                  SongModel song = playerController.allSongs[index];

                  return GestureDetector(
                    onTap: () async {
                      playerController.setPlaylistAndPlaySong(allSongs, index);
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
                          buildMoreVertButton(context, song.id),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
        const SizedBox(height: 25),
        Center(
          child: SizedBox(
            height: 50, // Set the desired height
            width: 150, // Set the desired width
            child: MaterialButton(
              onPressed: () {
                Get.to(
                  AllMusicPage(),
                  transition: Transition.rightToLeftWithFade,
                );
              },
              child: Text(
                'View All',
                style: TextStyle(color: textColor),
              ),
              color: secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8), // Set the desired border radius
              ),
            ),
          ),
        )
      ],
    );
  }

  Column buildRecentMusicList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getCustomFont("Recent Added Music", 18.sp, textColor, 1,
                fontWeight: FontWeight.w700),
            Row(
              children: [
                getCustomFont("View All", 12.sp, textColor, 1,
                    fontWeight: FontWeight.w700),
                getHorSpace(8.h),
                IconButton(
                  onPressed: () {
                    Get.to(
                      AllRecentMusicPage(),
                      transition: Transition.rightToLeftWithFade,
                    );
                  },
                  icon: Icon(
                    CupertinoIcons.arrow_right,
                    color: textColor,
                  ),
                ),
              ],
            )
          ],
        ).paddingSymmetric(horizontal: 20.h),
        getVerSpace(10.h),
        SizedBox(
          height: 160.h,
          child: Obx(
            () {
              if (playerController.recentSongs.isEmpty) {
                return const Text('No Songs available');
              } else {
                return ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: playerController.recentSongs.length > 21
                      ? 21
                      : playerController.recentSongs.length,
                  itemBuilder: (context, index) {
                    final recentSongs = playerController.recentSongs;
                    ExtendedSongModel recentSong = recentSongs[index];

                    return GestureDetector(
                      onTap: () async {
                        playerController.setPlaylistAndPlaySong(
                            recentSongs, index);
                        homeController.setIsShowPlayingData(true);
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 10.h),
                        width: 120.w, // Set a fixed width for each tile
                        child: GridTile(
                          footer: Container(
                            height: 40.h,
                            padding: EdgeInsets.only(left: 8.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8.r),
                                bottomRight: Radius.circular(8.r),
                              ),
                            ),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 85.w,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      getCustomFont(
                                        recentSong.title,
                                        10.sp,
                                        textColor,
                                        1,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      // getVerSpace(1.h),
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
                                Expanded(
                                    child: buildMoreVertButton(
                                        context, recentSong.id)),
                              ],
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              color: secondaryColor,
                            ),
                            child: buildRecentImage(context, recentSong.id),
                          ),
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

  Widget buildSearchWidget(BuildContext context) {
    return getSearchWidget(context, "Search...", searchController,
            isEnable: false,
            isprefix: true,
            prefix: Row(
              children: [
                getHorSpace(18.h),
                getSvgImage("search.svg", height: 24.h, width: 24.h),
              ],
            ),
            constraint: BoxConstraints(maxHeight: 24.h, maxWidth: 55.h),
            withSufix: true,
            suffiximage: "filter.svg", imagefunction: () {
      // Get.bottomSheet(const FilterDialog(), isScrollControlled: true);
    }, onTap: () {
      // Constant.sendToNext(context, Routes.searchScreenRoute);
    }, isReadonly: true)
        .paddingSymmetric(horizontal: 20.h);
  }

  Widget buildAppBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Center(
          child: getTwoRichText(
            "",
            accentColor,
            FontWeight.w700,
            22.sp,
            "Sound Mile",
            textColor,
            FontWeight.w700,
            22.sp,
          ),
        ),
        IconButton(
          onPressed: () async {
            _refreshController.forward(from: 0); // Start animation
            await playerController.fetchSongs();
          },
          icon: RotationTransition(
            turns: _refreshController,
            child: Icon(
              CupertinoIcons.refresh,
              color: textColor,
            ),
          ),
        ),
      ],
    ).paddingSymmetric(horizontal: 20.h);
  }
}
