import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../controllers/Llibrary_controller.dart';
import '../../../../controllers/player_controller.dart';
import '../../../../model/extended_song_model.dart';
import '../../../../util/constant_widget.dart';
import 'playlist_tab/category_songs.dart';

class AlbumTab extends StatefulWidget {
  const AlbumTab({Key? key}) : super(key: key);

  @override
  State<AlbumTab> createState() => _AlbumTabState();
}

class _AlbumTabState extends State<AlbumTab>
    with AutomaticKeepAliveClientMixin {
  final PlayerController playerController = Get.put(PlayerController());

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GetBuilder<LibraryController>(
      init: LibraryController(),
      builder: (controller) {
        // Group songs by album
        Map<String, List<ExtendedSongModel>> albumMap = {};
        for (var song in playerController.allSongs) {
          if (song.album == null) continue;
          albumMap.putIfAbsent(song.album!, () => []).add(song);
        }

        // Sort albums
        var sortedAlbums = albumMap.keys.toList()..sort();

        return Padding(
          padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 20.h),
          child: GridView.builder(
            // padding: EdgeInsets.only(, ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 5.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 0.75,
            ),
            itemCount: sortedAlbums.length,
            itemBuilder: (context, index) {
              final albumName = sortedAlbums[index];
              final releases = albumMap[albumName]!;

              return GestureDetector(
                onTap: () {
                  Get.to(
                    () => CategorySongs(
                      title: albumName,
                      songs: releases,
                    ),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 200),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<Uint8List?>(
                      future: getArtwork(releases.first.id),
                      builder: (context, snapshot) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10.h),
                          child: snapshot.hasData && snapshot.data != null
                              ? Image.memory(
                                  snapshot.data!,
                                  height: 180.h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/headphones.png',
                                  height: 180.h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        );
                      },
                    ),
                    getVerSpace(8.h),
                    getCustomFont(albumName, 14.sp, Colors.white, 1,
                        fontWeight: FontWeight.w600),
                    getCustomFont(
                        "${releases.length} songs", 11.sp, Colors.grey, 1),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
