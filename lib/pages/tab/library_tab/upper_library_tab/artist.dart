import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../controllers/player_controller.dart';
import '../../../../controllers/Llibrary_controller.dart';
import '../../../../model/extended_song_model.dart';
import '../../../../util/constant_widget.dart';
import 'playlist_tab/category_songs.dart';

class ArtistTab extends StatefulWidget {
  const ArtistTab({super.key});

  @override
  State<ArtistTab> createState() => _ArtistTabState();
}

class _ArtistTabState extends State<ArtistTab>
    with AutomaticKeepAliveClientMixin {
  final PlayerController playerController = Get.find<PlayerController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GetBuilder<LibraryController>(
      init: LibraryController(),
      builder: (controller) {
        // Group songs by artist
        Map<String, List<ExtendedSongModel>> artistMap = {};
        for (var song in playerController.allSongs) {
          String artist = song.artist ?? 'Unknown';
          if (!artistMap.containsKey(artist)) {
            artistMap[artist] = [];
          }
          artistMap[artist]!.add(song);
        }

        // Sort artists alphabetically
        var sortedArtists = artistMap.keys.toList()..sort();

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          itemCount: sortedArtists.length,
          itemBuilder: (context, index) {
            String artist = sortedArtists[index];
            List<ExtendedSongModel> releases = artistMap[artist]!;

            return InkWell(

              onTap: () {
                Get.to(
                  () => CategorySongs(
                    title: artist,
                    songs: releases,
                  
                  ),
                  transition: Transition.fadeIn,duration: const Duration(milliseconds: 200),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30.h),
                      child: FutureBuilder<Uint8List?>(
                        future: getArtwork(releases.first.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              height: 60.h,
                              width: 60.h,
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/images/headphones.png',
                                height: 60.h,
                                width: 60.h,
                                fit: BoxFit.cover,
                              ),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data != null) {
                            return Image.memory(
                              snapshot.data!,
                              height: 60.h,
                              width: 60.h,
                              fit: BoxFit.cover,
                            );
                          } else {
                            return Image.asset(
                              'assets/images/headphones.png',
                              height: 60.h,
                              width: 60.h,
                              fit: BoxFit.cover,
                            );
                          }
                        },
                      ),
                    ),
                    getHorSpace(12.h),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getCustomFont(
                            artist,
                            12.sp,
                            Colors.white,
                            1,
                            fontWeight: FontWeight.w700,
                          ),
                          getVerSpace(6.h),
                          getCustomFont(
                            '${releases.length} songs',
                            10.sp,
                            Colors.grey,
                            1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
