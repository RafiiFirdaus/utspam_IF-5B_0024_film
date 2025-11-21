import 'package:KirofTix/data/model/movies.dart';

class MoviesRepo {
  static List<Movies> getMoviesList() {
    return [
      Movies(
        id: 1,
        judul: "Predator: Badlands",
        genre: "Action, Adventure, Sci-Fi, Thriller",
        durasi: "1 jam 47 menit",
        rating: 7.2,
        harga: 25000,
        poster: "assets/images/predator_badlands.jpg",
        jadwal: ["12:10", "15:30", "18:20"],
      ),
      Movies(
        id: 2,
        judul: "Now You See Me: Now You Don't",
        genre: "Heist, Crime, Thriller",
        durasi: "1 jam 53 menit",
        rating: 6.3,
        harga: 25000,
        poster: "assets/images/nysm_nyd.jpg",
        jadwal: ["12:10", "15:30", "18:20"],
      ),
      Movies(
        id: 3,
        judul: "The Long Walk",
        genre: "Sci-Fi, Survival, Horror, Thriller",
        durasi: "1 jam 48 menit",
        rating: 6.8,
        harga: 25000,
        poster: "assets/images/tlw.jpg",
        jadwal: ["12:10", "15:30", "18:20"],
      ),
      Movies(
        id: 4,
        judul: "Rental Family",
        genre: "Tragedy, Drama, Comedy",
        durasi: "1 jam 43 menit",
        rating: 7.7,
        harga: 25000,
        poster: "assets/images/rental_family.jpg",
        jadwal: ["12:10", "15:30", "18:20"],
      ),
      Movies(
        id: 5,
        judul: "The Bad Guys 2",
        genre: "Family, Crime, Comedy, Animation, Adventure, Action, Heist",
        durasi: "1 jam 44 menit",
        rating: 7.0,
        harga: 25000,
        poster: "assets/images/tbg2.jpg",
        jadwal: ["12:10", "15:30", "18:20"],
      ),
    ];
  }
}
