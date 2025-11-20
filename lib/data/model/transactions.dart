class Transactions {
  final int? id;
  final String username; 
  final String judulFilm;
  final String poster;
  final String jadwalFilm;
  final int jumlahTiket;
  final int totalHarga;
  final String metodePembayaran; // 'Cash' / 'Kartu Kredit'
  final String? noKartu; // Opsional, null jika cash
  final String tanggalTransaksi; // Format: "YYYY-MM-DD"
  final String status; // 'Selesai' atau 'Dibatalkan'

  Transactions({
    this.id,
    required this.username,
    required this.judulFilm,
    required this.poster,
    required this.jadwalFilm,
    required this.jumlahTiket,
    required this.totalHarga,
    required this.metodePembayaran,
    this.noKartu,
    required this.tanggalTransaksi,
    required this.status,
  });

  // ubah objek Transactions jadi map ke database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'judulFilm': judulFilm,
      'poster': poster,
      'jadwalFilm': jadwalFilm,
      'jumlahTiket': jumlahTiket,
      'totalHarga': totalHarga,
      'metodePembayaran': metodePembayaran,
      'noKartu': noKartu,
      'tanggalTransaksi': tanggalTransaksi,
      'status': status,
    };
  }

  // ubah map dari database jadi objek Transactions
  factory Transactions.fromMap(Map<String, dynamic> map) {
    return Transactions(
      id: map['id'],
      username: map['username'],
      judulFilm: map['judulFilm'],
      poster: map['poster'],
      jadwalFilm: map['jadwalFilm'],
      jumlahTiket: map['jumlahTiket'],
      totalHarga: map['totalHarga'],
      metodePembayaran: map['metodePembayaran'],
      noKartu: map['noKartu'],
      tanggalTransaksi: map['tanggalTransaksi'],
      status: map['status'],
    );
  }
}