import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:sound_mile/controllers/player_controller.dart';
import 'package:sound_mile/model/extended_song_model.dart';

import '../../../controllers/home_conroller.dart';
import '../../../util/color_category.dart';
import '../../../util/constant.dart';
import '../../../util/constant_widget.dart';
import '../../player/music_player.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _HomeState();
}

class _HomeState extends State<SearchScreen> {
  PlayerController playerController = Get.put(PlayerController());
  HomeController homeController = Get.put(HomeController());
  List<ExtendedSongModel> songs = PlayerController().allSongs;

  List<ExtendedSongModel> filteredSongs = [];

  void filterItems(String query) {
    setState(() {
      filteredSongs = songs
          .where(
              (item) => item.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void backClick() {
    final homeController = Get.find<HomeController>();
    homeController.selectedIndex.value = 0; // Navigates back to TabHome
  }

  @override
  void initState() {
    filteredSongs = songs; // Initialize filteredSongs with all songs
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_typing_uninitialized_variables
    var suffiximage;
    return SafeArea(
      child: Scaffold(
        // bottomNavigationBar: buildBottomMusicBar(),
        backgroundColor: bgDark,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            getVerSpace(20.h),
            getAppBar(() {
              backClick();
            }, 'Sound Mile')
                .paddingSymmetric(horizontal: 10.h),
            getVerSpace(30.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CupertinoTextField(
                onChanged: filterItems,
                placeholder: "Search",
                maxLines: 1,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    fontFamily: Constant.fontsFamily),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.h), color: lightBg),
                padding: EdgeInsets.symmetric(vertical: 17.h, horizontal: 20.h),
                suffix: getSvgImage(suffiximage.toString(),
                        width: 24.w, height: 24.h)
                    .paddingOnly(right: 18.h),
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Icon(
                    CupertinoIcons.search,
                    color: textColor,
                    size: 20,
                  ),
                ),
                placeholderStyle: TextStyle(
                    color: searchHint,
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    fontFamily: Constant.fontsFamily),
              ),
            ),
            getVerSpace(25.h),
            Expanded(
                child: ListView.builder(
              padding: EdgeInsets.only(right: 0.h, left: 6.h),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              primary: false,
              itemCount: filteredSongs.length > 40 ? 40 : filteredSongs.length,
              itemBuilder: (context, index) {
                ExtendedSongModel song = filteredSongs[index];
                return GestureDetector(
                  onTap: () async {
                    List<ExtendedSongModel> searchedSong = [song];
                    playerController.setPlaylistAndPlaySong(
                        searchedSong, index);
                    ;
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
                                'assets/images/headphones.png', // Path to your asset image
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
                        getHorSpace(12.h),
                        buildMoreVertButton(context, song.id),
                      ],
                    ),
                  ),
                );
              },
            ))
          ],
        ),
      ),
    );
  }

  Widget getAppBar(Function function, String title) {
    return Container(
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              function();
            },
            icon: Icon(
              CupertinoIcons.arrow_left,
              color: textColor,
            ),
          ),
          getHorSpace(20.h),
          SizedBox(
            // width: 7.w,
            child: getCustomFont(title, 20.sp, textColor, 1,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
