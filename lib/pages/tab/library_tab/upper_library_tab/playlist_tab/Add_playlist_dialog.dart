// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sound_mile/util/color_category.dart';
import 'package:sound_mile/util/constant_widget.dart';
import '../../../../../helpers/playlist_helper.dart';

void showAddPlaylistModal(BuildContext context, int songId) {
  final TextEditingController controller = TextEditingController();
  final PlaylistHelper playlistHelper = PlaylistHelper.PlaylistHelper();
  String? selectedPlaylist;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> addSongToPlaylist(int playlistId) async {
            await playlistHelper.addSongToPlaylist(playlistId, songId);
            // ignore: duplicate_ignore
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: BoxDecoration(
              color: containerBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'New Playlist Name',
                    labelStyle: TextStyle(color: secondaryColor, fontSize: 15),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: secondaryColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: secondaryColor),
                    ),
                  ),
                  style: TextStyle(color: secondaryColor),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                        onPressed: () async {
                          if (controller.text.isNotEmpty) {
                            int playlistId = await playlistHelper
                                .createPlaylist(controller.text);
                            addSongToPlaylist(playlistId);
                            playListController.getPlaylistsWithSongCount();
                          } else if (selectedPlaylist != null) {
                            int? playlistId = await playlistHelper
                                .getPlaylistIdByName(selectedPlaylist!);
                            if (playlistId != null) {
                              addSongToPlaylist(playlistId);
                            } else {
                              return;
                            }
                          }
                        },
                        child: getCustomFont("Add", 12, textColor, 1)),
                  ],
                ),
                getCustomFont("ExistingPlaylist", 15.sp, textColor, 1),
                const SizedBox(height: 20),
                FutureBuilder<List<String>>(
                  future: playlistHelper.getPlaylists(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No existing playlists.');
                    } else {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            String playlist = snapshot.data![index];
                            return ListTile(
                              onTap: () async {
                                setState(() {
                                  selectedPlaylist = playlist;
                                });
                                int? playlistId = await playlistHelper
                                    .getPlaylistIdByName(selectedPlaylist!);
                                if (playlistId != null) {
                                  addSongToPlaylist(playlistId);
                                  playListController.fetchSongsInPlaylist(songId);
                                  playListController.getPlaylistsWithSongCount();
                                }
                              },
                              title: getCustomFont(
                                  playlist, 15, secondaryColor, 1),
                              leading: playlist.isNotEmpty
                                  ? Text(
                                      playlist[0].toUpperCase(),
                                      style: const TextStyle(fontSize: 20),
                                    )
                                  : const SizedBox(), // Handle empty playlist name
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void showNewPlaylistModal(
  BuildContext context,
) {
  final TextEditingController controller = TextEditingController();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: BoxDecoration(
              color: containerBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'New Playlist Name',
                    labelStyle: TextStyle(color: secondaryColor, fontSize: 15),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: secondaryColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: secondaryColor),
                    ),
                  ),
                  style: TextStyle(color: secondaryColor),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: getCustomFont("Cancel", 15, Colors.red, 1),
                    ),
                    TextButton(
                      onPressed: () async {
                        PlaylistHelper playlistHelper =
                            PlaylistHelper.PlaylistHelper();
                        if (controller.text.isNotEmpty) {
                          await playlistHelper.createPlaylist(controller.text);
                          playListController
                              .getPlaylistsWithSongCount();
                          Navigator.of(context).pop();
                        } else {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter a playlist name.'),
                            ),
                          );
                        }
                      },
                      child: getCustomFont("Create", 15, textColor, 1),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
