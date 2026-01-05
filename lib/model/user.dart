class User {
  final int? id;
  final String? username;
  final String? name;
  final String? role;
  final String? email;
  final String? profilePhoto;
  final String? phone;
  final String? address;

  User(
      {this.id,
      this.username,
      this.name,
      this.role,
      this.email,
      this.profilePhoto,
      this.address,
      this.phone});

  factory User.fromMap(Map<dynamic, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      username: map['username'],
      email: map['email'],
      role: map['role'],
      phone: map['phone'],
      address: map['address'],
    );
  }

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      address: json['address'],
      profilePhoto: json['profilePhoto'],
    );
  }
  @override
  String toString() {
    return 'User{id: $id, username: $username, name: $name, role: $role, email: $email, profilePhoto: $profilePhoto, phone: $phone, address: $address}';
  }
}
