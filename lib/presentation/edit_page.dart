import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:KirofTix/data/model/transactions.dart';
import 'package:KirofTix/data/db/db_helper.dart';

class EditPage extends StatefulWidget {
  final Transactions transactions;

  const EditPage({super.key, required this.transactions});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _jumlahController;
  late TextEditingController _noKartuController;
  late String _metodePembayaran;
  late int _hargaPerTiket; // untuk hitung ulang

  @override
  void initState() {
    super.initState();
    _jumlahController = TextEditingController(
      text: widget.transactions.jumlahTiket.toString(),
    );
    _noKartuController = TextEditingController(
      text: widget.transactions.noKartu ?? '',
    );
    _metodePembayaran = widget.transactions.metodePembayaran;

    // hitung dari total lama dibagi jumlah tiket lama
    _hargaPerTiket =
        (widget.transactions.totalHarga / widget.transactions.jumlahTiket)
            .round();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _noKartuController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      int jumlahBaru = int.parse(_jumlahController.text);
      int totalBaru = jumlahBaru * _hargaPerTiket;
      // buat objek transaksi yang diupdate
      Transactions updatedTransaction = Transactions(
        id: widget.transactions.id, // ID tetap sama
        username: widget.transactions.username,
        judulFilm: widget.transactions.judulFilm,
        poster: widget.transactions.poster,
        jadwalFilm: widget.transactions.jadwalFilm,
        jumlahTiket: jumlahBaru,
        totalHarga: totalBaru,
        metodePembayaran: _metodePembayaran,
        noKartu: (_metodePembayaran == 'Cash') ? null : _noKartuController.text,
        tanggalTransaksi: widget.transactions.tanggalTransaksi,
        status: widget.transactions.status,
      );

      // simpan ke database
      DbHelper dbHelper = DbHelper();
      await dbHelper.updateTransaction(updatedTransaction);

      if (!mounted) return;
      // kembali ke halaman detail dengan data yang diupdate
      Navigator.pop(context, updatedTransaction);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan berhasil disimpan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pesanan'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Tiket',
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
                validator: (val) =>
                    (val == null ||
                        int.tryParse(val) == null ||
                        int.parse(val) <= 0)
                    ? 'Minimal 1'
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _metodePembayaran,
                decoration: const InputDecoration(
                  labelText: 'Metode Pembayaran',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: ['Cash', 'Credit Card', 'Debit Card']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _metodePembayaran = value!;
                    if (_metodePembayaran == 'Cash') {
                      _noKartuController.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              if (_metodePembayaran != 'Cash')
                TextFormField(
                  controller: _noKartuController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Kartu',
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  validator: (val) => (val == null || val.length != 16)
                      ? 'Harus 16 digit'
                      : null,
                ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context), // batal edit
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('BATAL'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('SIMPAN'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
