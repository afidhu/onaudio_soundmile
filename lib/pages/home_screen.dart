import 'package:android_intent_plus/android_intent.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:sound_mile/controllers/player_controller.dart';
import 'package:sound_mile/pages/tab/search/search_screen.dart';
import 'package:sound_mile/pages/tab/library_tab/tab_library.dart';

import '../controllers/audio_controller.dart';
import '../controllers/home_conroller.dart';
import '../intro/my_audioHandler.dart';
import '../model/bottom_model.dart';
import '../util/color_category.dart';
import '../util/constant.dart';
import '../util/constant_widget.dart';
import 'player/music_player.dart';
import 'tab/tab_home.dart';
import '../dataFile/data_file.dart';


class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  final user = Get.arguments;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final bottomLists = DataFile.bottomList;
  final SongController audioController = Get.put(SongController());
  final PlayerController playerController = Get.put(PlayerController());

  final HomeController homeController = Get.put(HomeController());

  // int selectedIndex = 0;
  PageController _pageController = PageController();

  static final List<Widget> _widgetOptions = <Widget>[
    const TabHome(),
    const SearchScreen(),
    const TabLibrary(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      homeController.selectedIndex.value = index;
    });
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initAudioService();
  }
  late AudioHandler audioHandler;
  Future<void> _initAudioService() async {
    audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config:  AudioServiceConfig(
        androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
        androidNotificationChannelName: 'Music Playback',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: false,
        androidNotificationClickStartsActivity: true,
        androidShowNotificationBadge: true,
        androidResumeOnClick: true,
      ),
    );
    // Optional: start playing automatically
    await audioHandler.play();
  }




  @override
  Widget build(BuildContext context) {
    setStatusBarColor(bgDark);
    Constant.setupSize(context);

    return Obx(() {
      // Update the status bar color and icon brightness
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: playerController.secondColor.value ??
              bg, // assuming bgDark is Rx<Color>
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );

      return WillPopScope(
        onWillPop: () async {
          if (homeController.selectedIndex.value != 0) {
            setState(() {
              homeController.selectedIndex.value = 0;
            });
            _pageController.jumpToPage(0);
            return false;
          } else {
            SystemNavigator.pop();
            return false;
          }
        },
        child: Scaffold(
          backgroundColor: bgDark,
          bottomNavigationBar: buildBottomNavigation(),
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Obx(() => IndexedStack(
                    index: homeController.selectedIndex.value,
                    children: _widgetOptions,
                  )),
            ),
          ),
        ),
      );
    });
  }

  buildBottomNavigation() {
    return Obx(
      () => SizedBox(
        height: (homeController.isShowPlayingSong.value) ? 130.h : 61.h,
        child: Stack(
          children: [
            if (homeController.isShowPlayingSong.value)
              Positioned(
                top: 0,
                left: 0,
                right: 1,
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      MusicPlayer(),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: secondaryColor,
                        width: 0.3.w,
                      ),
                    ),
                    color: (playerController.secondColor.value ?? accentColor),
                    child: Row(
                      children: [
                        Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.horizontal,
                          confirmDismiss: (direction) async {
                            bool isNext =
                                direction == DismissDirection.endToStart;
                            bool noNext = !playerController
                                    .audioPlayer.hasNext &&
                                playerController.loopMode.value == LoopMode.one;
                            bool noPrevious =
                                !playerController.audioPlayer.hasPrevious;

                            if ((isNext && noNext) || (!isNext && noPrevious)) {
                              showToast('Repeat', context);
                              playerController.audioPlayer.seek(Duration.zero);
                              playerController.audioPlayer.play();
                              return false;
                            }

                            isNext
                                ? playerController.playNextSong()
                                : playerController.playPreviousSong();
                            return null;
                          },
                          background: Container(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Icon(
                                (playerController.audioPlayer.hasNext &&
                                        playerController.loopMode.value !=
                                            LoopMode.one)
                                    ? Icons.arrow_back
                                    : Icons.loop,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Icon(
                                (playerController.audioPlayer.hasNext &&
                                        playerController.loopMode.value !=
                                            LoopMode.one)
                                    ? Icons.arrow_forward
                                    : Icons.loop,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              getHorSpace(12.h),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                height: 50.h,
                                width: 50.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11.h),
                                ),
                                child: QueryArtworkWidget(
                                  artworkBorder: BorderRadius.circular(22.h),
                                  id: playerController.playingSong.value?.id ??
                                      0,
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
                              getHorSpace(20.w),
                              SizedBox(
                                width: 250.w,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    getCustomFont(
                                      playerController
                                              .playingSong.value?.title ??
                                          '',
                                      10.sp,
                                      Colors.white,
                                      1,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    getVerSpace(6.h),
                                    getCustomFont(
                                      "${playerController.playingSong.value?.artist ?? ''}  ",
                                      8.sp,
                                      searchHint,
                                      1,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Obx(
                          () => IconButton(
                            icon: Icon(
                              (playerController.isPlaying.value)
                                  ? CupertinoIcons.pause_circle
                                  : CupertinoIcons.play_circle,
                              color: textColor,
                            ),
                            onPressed: () async {
                              playerController.togglePlayPause();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0.h,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 60.h,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(bottomLists.length, (index) {
                    ModelBottom modelBottom = bottomLists[index];
                    return IconButton(
                      onPressed: () {
                        _onTabTapped(index);
                      },
                      icon: Column(
                        children: [
                          Icon(
                            homeController.selectedIndex.value == index
                                ? modelBottom.selectImage
                                : modelBottom.image,
                            size: 25.h,
                            color: homeController.selectedIndex.value == index
                                ? secondaryColor
                                : Colors.white,
                          ),
                          getCustomFont(
                            modelBottom.title,
                            10.sp,
                            homeController.selectedIndex.value == index
                                ? secondaryColor
                                : Colors.white,
                            1,
                            fontWeight: FontWeight.w700,
                            txtHeight: 1.5.h,
                          ),
                        ],
                      ),
                    );
                  }),
                ).paddingSymmetric(horizontal: 30.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
