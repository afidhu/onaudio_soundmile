import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../../../controllers/home_conroller.dart';
import '../../../../controllers/player_controller.dart';
import '../../../../controllers/recent_song_controller.dart';
import '../../../../util/color_category.dart';
import '../../../../util/constant_widget.dart';

class RecentTab extends StatefulWidget {
  const RecentTab({super.key});

  @override
  State<RecentTab> createState() => _RecentTabState();
}

class _RecentTabState extends State<RecentTab>
    with AutomaticKeepAliveClientMixin {
  final RecentSongController recentSongController = Get.put(RecentSongController());
  final PlayerController playerController = Get.find<PlayerController>();
  final HomeController homeController = Get.find<HomeController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(
      () {
        final songs = recentSongController.recentPlayedSongs;

        if (songs.isEmpty) {
          return Center(
            child: Text(
              'No recent songs',
              style: TextStyle(fontSize: 18.sp, color: textColor),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 70.h),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];

              return GestureDetector(
                onTap: () {
                  playerController.setPlaylistAndPlaySong(songs, index);
                  homeController.setIsShowPlayingData(true);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 15.h),
                  padding: EdgeInsets.all(10.h),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.black12.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20.h),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.h),
                        child: QueryArtworkWidget(
                          artworkBorder: BorderRadius.zero,
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: Image.asset(
                            'assets/images/headphones.png',
                            height: 60.h,
                            width: 60.h,
                            fit: BoxFit.cover,
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
                              song.artist ?? 'Unknown Artist',
                              10.sp,
                              searchHint,
                              1,
                            ),
                          ],
                        ),
                      ),
                      getHorSpace(10.h),
                      IconButton(
                        icon:
                            Icon(Icons.more_vert, color: textColor, size: 25.h),
                        onPressed: () {
                          // Optional: Implement modal
                          // showAddPlaylistModal(context, song.id);
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
