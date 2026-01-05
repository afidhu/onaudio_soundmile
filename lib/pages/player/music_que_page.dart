import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/player_controller.dart';
import '../../model/extended_song_model.dart';
import '../../util/color_category.dart';
import '../../util/constant_widget.dart';

class MusicQueueModal extends StatefulWidget {
  final List<ExtendedSongModel>? songs;

  const MusicQueueModal({super.key, required this.songs});

  @override
  State<MusicQueueModal> createState() => _MusicQueueModalState();
}

class _MusicQueueModalState extends State<MusicQueueModal> {
  late List<ExtendedSongModel> queueSongs;
  final PlayerController playerController = Get.find<PlayerController>();

  @override
  void initState() {
    super.initState();
    queueSongs = List.from(widget.songs ?? playerController.allSongs);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Obx(
          () => Container(
            decoration: BoxDecoration(
              color: playerController.secondColor.value ?? bgDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    // color: Colors.grey,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                Text("Music Queue",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold)),
                Expanded(
                  child: queueSongs.isEmpty
                      ? Center(
                          child: Text(
                            "No songs in the queue",
                            style: TextStyle(color: textColor, fontSize: 14.sp),
                          ),
                        )
                      : ReorderableListView.builder(
                          scrollController: scrollController,
                          itemCount: queueSongs.length,
                          onReorder: (oldIndex, newIndex) async {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final song = queueSongs.removeAt(oldIndex);
                              queueSongs.insert(newIndex, song);
                            });
                            await playerController
                                .updatePlaylistOrder(queueSongs);
                          },
                          itemBuilder: (context, index) {
                            final song = queueSongs[index];
                            return ListTile(
                              key: ValueKey(song.id),
                              tileColor:
                                  playerController.playingSong.value?.id ==
                                          song.id
                                      ? playerController.imageColor.value ??
                                          secondaryColor
                                      : null,
                              leading: playerController.playingSong.value?.id ==
                                      song.id
                                  ? Icon(Icons.equalizer, color: textColor)
                                  : Icon(Icons.drag_handle, color: textColor),
                              title: getCustomFont(
                                  song.title, 15.sp, Colors.black, 1,
                                  fontWeight: FontWeight.w700),
                              subtitle: getCustomFont(
                                  song.artist ?? "Unknown Artist",
                                  12.sp,
                                  Colors.black,
                                  1,
                                  fontWeight: FontWeight.w400),
                              trailing: IconButton(
                                icon: Icon(CupertinoIcons.xmark,
                                    color: Colors.red, size: 20.sp),
                                onPressed: () {
                                  setState(() {
                                    queueSongs.removeAt(index);
                                  });
                                },
                              ),
                              onTap: () {
                                playerController.setPlaylistAndPlaySong(
                                    queueSongs, index);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
