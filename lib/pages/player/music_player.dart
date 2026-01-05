// ignore_for_file: must_be_immutable
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sound_mile/controllers/player_controller.dart';
import 'package:sound_mile/helpers/playlist_helper.dart';
import 'package:sound_mile/pages/player/music_que_page.dart';
import 'package:sound_mile/pages/tab/library_tab/upper_library_tab/playlist_tab/Add_playlist_dialog.dart';
import 'package:sound_mile/util/constant_widget.dart';
import '../../util/color_category.dart';

class MusicPlayer extends StatefulWidget {
  int? index;

  MusicPlayer({super.key, this.index});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  PlayerController playerController = Get.find<PlayerController>();

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final screenHeight = mediaQueryData.size.height;
    final screenWidth = mediaQueryData.size.width;

    return Obx(
      () => Scaffold(
        backgroundColor: bgDark,
        body: Container(
          height: screenHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                playerController.secondColor.value ?? bg,
                playerController.secondColor.value ?? bg,
                Colors.transparent,
              ],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: screenHeight * 0.045),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(
                      Icons.keyboard_arrow_down_outlined,
                      size: 40.sp,
                      color: textColor,
                    ),
                  ),
                  // Seek backward 10s
                  _buildIconButton(
                    icon: Icons.replay_10,
                    onTap: () {
                      final pos = playerController.audioPlayer.position;
                      final seekPos = pos - const Duration(seconds: 10);
                      playerController.audioPlayer.seek(
                          seekPos > Duration.zero ? seekPos : Duration.zero);
                    },
                  ),

                  // Seek forward 10s
                  _buildIconButton(
                    icon: Icons.forward_10,
                    onTap: () {
                      final pos = playerController.audioPlayer.position;
                      final dur = playerController.audioPlayer.duration ??
                          Duration.zero;
                      final seekPos = pos + const Duration(seconds: 10);
                      playerController.audioPlayer
                          .seek(seekPos < dur ? seekPos : dur);
                    },
                  ),

                  buildMoreVertButton(
                      context, playerController.playingSong.value!.id),
                ],
              ).paddingZero,
              ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  getVerSpace(screenHeight * 0.02),
                  buildMusicImage(context, 10)
                      .paddingSymmetric(horizontal: screenWidth * 0.05),
                  getVerSpace(screenHeight * 0.03),
                  buildMusicDetail(),
                  buildPlaybackControls(),
                  buildMusicControlButton(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMusicControlButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Loop mode
        Obx(() => _buildIconButton(
              icon: playerController.loopMode.value == LoopMode.one
                  ? Icons.repeat_one
                  : playerController.loopMode.value == LoopMode.all
                      ? Icons.repeat
                      : Icons.repeat,
              color: playerController.loopMode.value == LoopMode.off
                  ? textColor
                  : secondaryColor,
              onTap: playerController.toggleLoopMode,
            )),

        // Shuffle
        Obx(() => _buildIconButton(
              icon: playerController.isShuffle.value
                  ? Icons.shuffle
                  : Icons.shuffle,
              color:
                  playerController.isShuffle.value ? secondaryColor : textColor,
              onTap: () {
                playerController.toggleShuffleMode();
                showToast(
                  playerController.isShuffle.value
                      ? "Shuffle mode enabled"
                      : "Shuffle mode disabled",
                  context,
                );
              },
            )),
        // Favourite
        Obx(() {
          final isFavourite = playerController.favouriteSongsIds
              .contains(playerController.playingSong.value?.id);
          return _buildIconButton(
            icon: isFavourite
                ? Icons.favorite_outline_rounded
                : Icons.favorite_border_outlined,
            color: isFavourite ? secondaryColor : textColor,
            onTap: () async {
              final playingSong = playerController.playingSong.value;
              if (playingSong == null) return;

              if (isFavourite) {
                await PlaylistHelper.PlaylistHelper()
                    .removeSongFromPlaylist(1, playingSong.id);
                showToast("Removed from Favourites", context);
              } else {
                await PlaylistHelper.PlaylistHelper()
                    .addSongToPlaylist(1, playingSong.id);
                showToast("Added to Favourites", context);
              }

              playListController.fetchSongsInPlaylist(playingSong.id);
              playListController.getPlaylistsWithSongCount();
            },
          );
        }),
        // Queue
        _buildIconButton(
          icon: Icons.queue_music,
          size: 30.sp,
          onTap: () {
            if (playerController.playList.isNotEmpty) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                // backgroundColor: Colors.transparent, // keep corners visible
                barrierColor: Colors.transparent,
                // .withOpacity(0.9), // darker overlay behind sheet
                builder: (_) =>
                    MusicQueueModal(songs: playerController.playList),
              );
            } else {
              Get.snackbar("Oops!", "No songs in the queue.",
                  backgroundColor: Colors.red.withOpacity(0.8),
                  colorText: Colors.white);
            }
          },
        ),

        // Add to playlist
        _buildIconButton(
          icon: CupertinoIcons.plus_rectangle_fill,
          size: 20.sp,
          onTap: () {
            showAddPlaylistModal(
                context, playerController.playingSong.value!.id);
          },
        ),
      ],
    ).paddingSymmetric(
      horizontal: MediaQuery.of(context).size.width * 0.052,
    );
  }

  /// 🔹 Reusable helper for consistent IconButtons
  Widget _buildIconButton({
    required IconData icon,
    Color? color,
    double? size,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, color: color ?? textColor, size: size),
      onPressed: onTap,
    );
  }

  Widget buildPlaybackControls() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      children: [
        // Position + Slider + Duration
        StreamBuilder<Duration>(
          stream: playerController.audioPlayer.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final duration =
                playerController.audioPlayer.duration ?? Duration.zero;

            final positionMillis = position.inMilliseconds.toDouble();
            final durationMillis = duration.inMilliseconds.toDouble();

            String formatDuration(Duration d) {
              final hours = d.inHours;
              final minutes =
                  d.inMinutes.remainder(60).toString().padLeft(2, '0');
              final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
              return hours > 0
                  ? "$hours:$minutes:$seconds"
                  : "$minutes:$seconds";
            }

            return ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 5.h,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 7.0),
                      trackHeight: 5.0,
                      activeTrackColor: secondaryColor,
                      inactiveTrackColor: textColor.withOpacity(0.5),
                      thumbColor: textColor,
                      overlayColor: secondaryColor.withOpacity(0.2),
                    ),
                    child: Slider(
                      min: 0.0,
                      max: durationMillis > 0 ? durationMillis : 1.0,
                      value: positionMillis > durationMillis
                          ? durationMillis
                          : positionMillis,
                      onChanged: (value) {
                        if (durationMillis > 0) {
                          playerController.audioPlayer
                              .seek(Duration(milliseconds: value.toInt()));
                        }
                      },
                    ),
                  ),
                ),
                getVerSpace(20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    getCustomFont(formatDuration(position), 15.sp, textColor, 1,
                        fontWeight: FontWeight.w700),
                    getCustomFont(formatDuration(duration), 15.sp, textColor, 1,
                        fontWeight: FontWeight.w700),
                  ],
                ).paddingSymmetric(
                  horizontal: screenWidth * 0.052,
                ),
              ],
            );
          },
        ),

        // Playback Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(CupertinoIcons.backward_end_fill,
                  color: textColor, size: 30.h),
              onPressed: () {
                if (playerController.songList.length == 1) {
                  showToast("No Previous Song to Play", context);
                } else {
                  playerController.playPreviousSong();
                }
              },
            ),
            getHorSpace(screenWidth * 0.05),
            Obx(() => IconButton(
                  icon: Icon(
                    playerController.isPlaying.value
                        ? CupertinoIcons.pause_circle
                        : CupertinoIcons.play_circle,
                    size: 72.h,
                    color: textColor,
                  ),
                  onPressed: () => playerController.togglePlayPause(),
                )),
            getHorSpace(screenWidth * 0.05),
            IconButton(
              icon: Icon(CupertinoIcons.forward_end_fill,
                  color: textColor, size: 30.h),
              onPressed: () {
                if (playerController.songList.length == 1) {
                  showToast("No Next Song to Play", context);
                } else {
                  playerController.playNextSong();
                }
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [],
        ),
      ],
    );
  }

  buildMusicDetail() {
    return Obx(
      () => ListTile(
        contentPadding: EdgeInsets.zero,
        title: getCustomFont(playerController.playingSong.value?.title ?? '',
            25.sp, textColor, 1,
            fontWeight: FontWeight.w700, textAlign: TextAlign.center),
        subtitle: getCustomFont(
            playerController.playingSong.value?.artist ?? '',
            18.sp,
            textColor,
            1,
            fontWeight: FontWeight.w400,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center),
      ),
    );
  }
}
