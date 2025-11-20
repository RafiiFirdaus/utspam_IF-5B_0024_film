class User {
  final int? id;
  final String username;
  final String password;
  final String nama;
  final String email;
  final String alamat;
  final String telepon;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.nama,
    required this.email,
    required this.alamat,
    required this.telepon,
  });

  // ubah objek User jadi map ke database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'nama': nama,
      'email': email,
      'alamat': alamat,
      'telepon': telepon,
    };
  }

  // ubah map dari database jadi objek User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      nama: map['nama'],
      email: map['email'],
      alamat: map['alamat'],
      telepon: map['telepon'],
    );
  }
}