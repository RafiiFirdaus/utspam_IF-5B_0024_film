import 'package:flutter/material.dart';
import 'package:KirofTix/data/db/db_helper.dart';
import 'package:KirofTix/data/model/users.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      // buat objek user baru
      Users newUser = Users(
        username: _usernameController.text,
        password: _passwordController.text,
        email: _emailController.text,
        telepon: _phoneController.text,
        nama: _nameController.text,
        alamat: _addressController.text,
      );

      // simpan ke database
      DbHelper dbHelper = DbHelper();
      int result = await dbHelper.registerUser(newUser);

      if (result > 0) {
        // berhasil registrasi
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login')),
        );
        Navigator.pop(context); // kembali ke halaman login
      } else {
        // gagal registrasi
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username atau email sudah terdaftar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi Pengguna'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Silakan lengkapi data diri anda",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // color: Colors.grey
                      color: Color(0xFF2C3E50))),
              const SizedBox(height: 20),

              // nama lengkap
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.badge)),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email (@gmail.com)', prefixIcon: Icon(Icons.email)),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Wajib diisi';
                  if (!value.contains('@gmail.com')) return 'Format email tidak valid';
                  return null;
                }
              ),
              const SizedBox(height: 12),

              // alamat
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Alamat', prefixIcon: Icon(Icons.home)),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // no telepon
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'No. Telepon', prefixIcon: Icon(Icons.phone)),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              Divider(color: Colors.grey[400]),
              const SizedBox(height: 12),

              // username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_outline)),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Wajib diisi';
                  if (value.length < 6) return 'Minimal 6 karakter';
                  // campuran angka
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Harus mengandung angka';
                  }
                  return null;
                }
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('DAFTAR', style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold),))
            ],
          ),
        ),
      ),
    );
  }
}