import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
 
import '../model/bottom_model.dart';
import '../model/release_model.dart';

class DataFile {
  static List<ModelBottom> bottomList = [
    ModelBottom(CupertinoIcons.music_note_2, CupertinoIcons.double_music_note, "Music"),
    ModelBottom(CupertinoIcons.search, CupertinoIcons.search, "Search"),
    ModelBottom(Icons.library_music_outlined, Icons.library_music, "My Library"),
  ];
    static List<ModelRelease> libraryList = [
    ModelRelease("playlist.svg", "Playlists"),
    ModelRelease("heart_bold.svg", "Favourite Music"),
    ModelRelease("download_from_cloud.svg", "Downloads"),
  ];

}
