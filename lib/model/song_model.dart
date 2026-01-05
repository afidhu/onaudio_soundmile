class Song {
  final int? id;
  final String? title;
  final String? photo;
  final String? audioPath;
  final String? createdAt;
  final String? updatedAt;
  final String? artistName;

  Song(
      {this.id,
      this.title,
      this.photo,
      this.audioPath,
      this.createdAt,
      this.updatedAt,
      this.artistName});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      photo: json['photo'],
      audioPath: json['audio_path'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      artistName: json['artist_name'],
    );
  }

  @override
  String toString() {
    return 'Song(id: $id, title: $title, photo: $photo, audioPath: $audioPath, artist: $artistName)';
  }
}