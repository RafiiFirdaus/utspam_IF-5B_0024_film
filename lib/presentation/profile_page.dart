import 'package:flutter/material.dart';
import 'package:KirofTix/data/model/users.dart';
import 'package:KirofTix/presentation/login_page.dart';

class ProfilePage extends StatelessWidget {
  final Users user;

  const ProfilePage({super.key, required this.user});

  // logout 
  void _logout(BuildContext context) {
    // kembali ke halaman login dan hapus semua halaman sebelumnya
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF2C3E50),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            _buildProfileItem('Nama Lengkap', user.nama),
            _buildProfileItem('Username', user.username),
            _buildProfileItem('Email', user.email),
            _buildProfileItem('No. Telepon', user.telepon),
            _buildProfileItem('Alamat', user.alamat),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('KELUAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C), // Warna merah
                  foregroundColor: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String judul, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(judul, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}