class Artist {
  int? id;
  String? name;
  String? email;
  String? profilePicture;
  int? songcout;

  Artist({this.id, this.name, this.email, this.profilePicture, this.songcout});

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profile_picture'] is String ? json['profile_picture'] : null,
      songcout: json['total_songs'],
    );
  }
}