import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:KirofTix/data/model/users.dart';
import 'package:KirofTix/data/model/movies.dart';
import 'package:KirofTix/data/repository/movies_repo.dart';
// import purchase page
// import history page
// import profile page untuk logout

class HomePage extends StatefulWidget {
  final Users user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // list halaman untuk bottom navigation
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // halaman daftar film
      _buildMovieTab(),
      // halaman riwayat
      HistoryPage(user: widget.user),
      // halaman profil
      ProfilePage(user: widget.user),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Film'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2C3E50),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  // widget untuk tab daftar film
  Widget _buildMovieTab() {
    // data dari repository
    List<Movies> movies = MoviesRepo.getMoviesList();

    // format rupiah
    final formatRupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header informasi user
        Container(
          padding: const EdgeInsets.all(20),
          color: const Color(0xFF2C3E50),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat Datang, ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.user.nama,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // header
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Sedang Tayang',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),

        // daftar film
        Expanded(
          child: ListView.builder(
            itemCount: movies.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final Movies movie = movies[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3, // bayangan
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // poster film
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          movie.poster,
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 100,
                                height: 150,
                                color: Colors.grey,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // info film
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.judul,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatRupiah.format(movie.harga),
                              style: const TextStyle(
                                color: Color(0xFFE74C3C),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),

                            const Text(
                              "Pilih Jadwal:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // tombol jadwal
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: movie.jadwal.map((jadwal) {
                                return SizedBox(
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // navigasi ke halaman pembelian tiket
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PurchasePage(
                                            user: widget.user,
                                            movie: movie,
                                            selectedSchedule: jadwal,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2C3E50),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      textStyle: const TextStyle(fontSize: 12),
                                      // shape: RoundedRectangleBorder(
                                      //   borderRadius: BorderRadius.circular(8),
                                      // ),
                                    ),
                                    child: Text(jadwal),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
