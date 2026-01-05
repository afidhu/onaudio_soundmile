class Categories{
  int? id;
  String? name;
  String? description;
  int? totalSongs;

  Categories({
    this.id,
    this.description,
    this.name,
    this.totalSongs,
  });

    factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      totalSongs: json['total_songs'],
    );
    
  }


}