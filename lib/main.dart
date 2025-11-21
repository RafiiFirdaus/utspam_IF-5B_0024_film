import 'package:flutter/material.dart';
import 'package:KirofTix/data/presentation/login_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KirofTix',
      theme: ThemeData(
        // Warna Utama (Dark Blue-Grey)
        primaryColor: const Color(0xFF2C3E50),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C3E50),
          primary: const Color(0xFF2C3E50), // Warna tombol & appbar
          secondary: const Color(0xFFE74C3C), // Warna aksen tombol logout & cancel
        ),
        useMaterial3: true,
        // default style input form
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        )
      ),
      home: const LoginPage(),
    );
  }
}
