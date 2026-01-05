import 'package:on_audio_query/on_audio_query.dart';

class ExtendedSongModel extends SongModel {
  final Uri? artworkUri;

  // Constructor that initializes the base SongModel with _info and adds artworkUri.
  ExtendedSongModel(Map<dynamic, dynamic> info, {this.artworkUri}) : super(info);

  // Factory method to create ExtendedSongModel from a SongModel.
  factory ExtendedSongModel.fromSongModel(SongModel song, Uri? artworkUri) {
    return ExtendedSongModel(song.getMap, artworkUri: artworkUri);
  }

  // Convert an ExtendedSongModel into a Map. The keys must correspond to the names of the JSON keys.
  Map toJson() {
    final map = super.getMap;
    map['artworkUri'] = artworkUri?.toString();
    return map;
  }

  // A method that converts a map into an ExtendedSongModel.
  factory ExtendedSongModel.fromJson(Map<String, dynamic> json) {
    final songModel = SongModel(json);
    final artworkUri = json['artworkUri'] != null ? Uri.parse(json['artworkUri']) : null;
    return ExtendedSongModel.fromSongModel(songModel, artworkUri);
  }

  @override
  String toString() {
    return '${super.toString()}, artworkUri: $artworkUri';
  }
}