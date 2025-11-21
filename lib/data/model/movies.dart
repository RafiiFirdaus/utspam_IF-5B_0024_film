class Movies {
  final int id;
  final String judul;
  final String genre;
  final int harga;
  final double rating;
  final String durasi;
  final String poster; // Bisa path asset / URL
  final List<String> jadwal; // "12:10" / "14:20"

  Movies({
    required this.id,
    required this.judul,
    required this.genre,
    required this.harga,
    required this.rating,
    required this.durasi,
    required this.poster,
    required this.jadwal,
  });
}