import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:KirofTix/data/model/transactions.dart';
import 'package:KirofTix/data/model/users.dart';
import 'package:KirofTix/data/model/movies.dart';
import 'package:KirofTix/data/db/db_helper.dart';
// import history page

class PurchasePage extends StatefulWidget {
  final Users user;
  final Movies movie;
  final String jadwal;

  const PurchasePage({
    super.key,
    required this.user,
    required this.movie,
    required this.jadwal,
  });

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _noKartuController = TextEditingController();

  String _paymentMethod = 'Cash';
  int _totalPrice = 0;
  final String _currentDate = DateFormat(
    'yyyy-MM-dd HH:mm',
  ).format(DateTime.now());

  // metode pembayaran
  final List<String> _paymentMethods = ['Cash', 'Credit Card', 'Debit Card'];

  @override
  void initState() {
    super.initState();
    // set nilai awal total harga
    _jumlahController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _noKartuController.dispose();
    super.dispose();
  }

  // hitung total harga
  void _calculateTotal() {
    setState(() {
      int jumlah = int.tryParse(_jumlahController.text) ?? 0;
      _totalPrice = jumlah * widget.movie.harga;
    });
  }

  // simpan transaksi
  void _submitTransaction() async {
    if (_formKey.currentState!.validate()) {
      // buat objek transaksi
      Transactions newTransaction = Transactions(
        username: widget.user.username,
        judulFilm: widget.movie.judul,
        poster: widget.movie.poster,
        jadwalFilm: widget.jadwal,
        jumlahTiket: int.parse(_jumlahController.text),
        totalHarga: _totalPrice,
        metodePembayaran: _paymentMethod,
        noKartu: (_paymentMethod == 'Cash') ? null : _noKartuController.text,
        tanggalTransaksi: _currentDate,
        status: 'Selesai', // status awal
      );

      // simpan ke database
      DbHelper dbHelper = DbHelper();
      int result = await dbHelper.insertTransaction(newTransaction);

      // tampil pesan berhasil dan pindah ke halaman riwayat
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Pembelian Berhasil'),
          content: const Text('Anda telah berhasil membeli tiket'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // tutup dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      body: HistoryPage(
                        user: widget.user,
                      ), // langsung ke halaman riwayat
                    ),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembelian Tiket'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // informasi film
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      widget.movie.poster,
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(width: 80, height: 120, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.movie.judul,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Jadwal: ${widget.jadwal}',
                          style: const TextStyle(color: Color(0xFF74C3C), fontWeight: FontWeight.bold),
                        ),
                        Text('Harga: ${formatRupiah.format(widget.movie.harga)} / tiket'),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 32, thickness: 1),

              // form input
              // nama
              TextFormField(
                initialValue: widget.user.nama,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person),
                  filled: true
                ),
              ),
              const SizedBox(height: 16),

              // tanggal
              TextFormField(
                initialValue: _currentDate,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Pembelian',
                  prefixIcon: Icon(Icons.calendar_today),
                  filled: true
                ),
              ),
              const SizedBox(height: 16),

              // jumlah tiket
              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Tiket',
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jumlah tiket';
                  }
                  int? jumlah = int.tryParse(value);
                  if (jumlah == null || jumlah <= 0) {
                    return 'Minimal beli 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // metode pembayaran
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Metode Pembayaran',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _paymentMethod = newValue!;
                    // reset no kartu jika metode cash
                    if (_paymentMethod == 'Cash') {
                      _noKartuController.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // no kartu (jika bukan cash)
              if (_paymentMethod != 'Cash')
                TextFormField(
                  controller: _noKartuController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'No. Kartu (16 digit)',
                    prefixIcon: Icon(Icons.credit_card),
                    hintText: '0000 0000 0000 0000',
                  ),
                  validator: (value) {
                    if (_paymentMethod != 'Cash') {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      if (value.length != 16) {
                        return 'Harus 16 digit';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Hanya boleh angka';
                      }
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 32),

              // total harga
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2C3E50)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Harga:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatRupiah.format(_totalPrice),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(8),
                    // ),
                  ),
                  child: const Text(
                    'Beli Tiket',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
