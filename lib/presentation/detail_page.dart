import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:KirofTix/data/model/transactions.dart';
import 'package:KirofTix/data/db/db_helper.dart';
// import edit page

class DetailPage extends StatefulWidget {
  final Transactions transactions;

  const DetailPage({super.key, required this.transactions});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Transactions _currentData;

  @override
  void initState() {
    super.initState();
    _currentData = widget.transactions;
  }

  // fungsi pembatalan
  void _cancelTransaction() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembatalan'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan transaksi ini?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // tutup dialog
            },
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // tutup dialog
              // hapus dari database
              DbHelper dbHelper = DbHelper();
              await dbHelper.deleteTransaction(_currentData.id!);

              if (!mounted) return;
              // kembali ke halaman riwayat
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaksi berhasil dibatalkan')),
              );
            },
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // navigasi ke halaman edit
  void _goToEditPage() {
    final result = Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPage(transactions: _currentData),
      ),
    );

    // terima data yang diupdate dari halaman edit
    if (result != null && result is Transactions) {
      setState(() async {
        _currentData = await result; // perbarui data transaksi
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // sensor nomor kartu
    String maskedCardNumber = '-';
    if (_currentData.noKartu != null && _currentData.noKartu!.length == 16) {
      maskedCardNumber =
          "${_currentData.noKartu!.substring(0, 4)} **** **** ${_currentData.noKartu!.substring(12)}";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // poster besar
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  _currentData.poster,
                  width: 150,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(width: 150, height: 220, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // judul film
            Text(
              _currentData.judulFilm,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // detail
            _buildDetailRow("ID Transaksi", "#${_currentData.id}"),
            _buildDetailRow("Tanggal", _currentData.tanggalTransaksi),
            _buildDetailRow("Jadwal Tayang", _currentData.jadwalFilm),
            _buildDetailRow(
              "Jumlah Tiket",
              "${_currentData.jumlahTiket} Tiket",
            ),
            _buildDetailRow("Metode Bayar", _currentData.metodePembayaran),
            if (_currentData.metodePembayaran != 'Cash')
              _buildDetailRow("No. Kartu", maskedCardNumber),

            const Divider(height: 30, thickness: 1),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Harga",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  formatRupiah.format(_currentData.totalHarga),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE74C3C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // tombol batal dan edit
            if (_currentData.status == 'Selesai') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _cancelTransaction,
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text(
                        'Batalkan',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _goToEditPage,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Pesanan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: const Text(
                    'Transaksi Dibatalkan',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              // fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
