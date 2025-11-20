class Movies {
  final int id;
  final String judul;
  final String genre;
  final int harga;
  final String poster; // Bisa path asset / URL
  final List<String> jadwal; // "12:10" / "14:20"

  Movies({
    required this.id,
    required this.judul,
    required this.genre,
    required this.harga,
    required this.poster,
    required this.jadwal,
  });
}