class PlayList {
  final int? id;
  final String? name;
  final String? image;
  final String? time;
  final int? songsCount;

  PlayList({
    this.id,
    this.name,
    this.image,
    this.time,
    this.songsCount,
  });

  factory PlayList.fromMap(Map<String, dynamic> map) {
    return PlayList(
      id: map['id'] as int?,
      name: map['name'] as String?,
      image: map['image'] as String?,
      time: map['time'] as String?,
      songsCount: map['song_count'] as int?,
    );
  }
}