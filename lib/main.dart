import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:get/get.dart';
import 'package:sound_mile/intro/splash_screen.dart';
import 'package:sound_mile/util/color_category.dart';
import 'package:sound_mile/util/pref_data.dart';
import 'controllers/player_controller.dart';
import 'controllers/recent_song_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefData.initializeDefaults();

  // Initialize and register controllers only once
  Get.put(PlayerController());
  Get.put(RecentSongController());

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'drawable/ic_notification',
    androidResumeOnClick: true,
    androidShowNotificationBadge: true,
    androidNotificationClickStartsActivity: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final RecentSongController recentSongController;
  late final PlayerController playerController;

  @override
  void initState() {
    super.initState();

    // Use Get.find() to retrieve the already registered controllers
    recentSongController = Get.find<RecentSongController>();
    playerController = Get.find<PlayerController>();

    // Load recent songs after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      recentSongController.loadRecentPlayedSongs();
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      final songs = recentSongController.recentPlayedSongs;

      if (songs.isEmpty) {
      } else if (state == AppLifecycleState.resumed) {
        // Restore media session and notification if needed
        playerController.restoreMediaSessionIfNeeded();
      } else {
        playerController.saveLastPlayedSong(songs);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          // theme: ThemeData(
          //   colorScheme: ColorScheme.fromSeed(seedColor: accentColor),
          //   useMaterial3: true,
          // ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
