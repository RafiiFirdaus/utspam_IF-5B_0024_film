import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:KirofTix/data/model/users.dart';
import 'package:KirofTix/data/model/transactions.dart';
import 'dart:developer' as developer;

class DbHelper {
  static const String dbname = "kiroftix.db";

  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  factory DbHelper() {
    return instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase(dbname);
    return _database!;
  }

  Future<Database> _initDatabase(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // tabel users (email & username harus unik)
    await db.execute('''
        CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            nama TEXT NOT NULL,
            alamat TEXT NOT NULL,
            telepon TEXT NOT NULL
        )
        ''');

    // tabel transactions
    await db.execute('''
        CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            movieTitle TEXT NOT NULL,
            moviePoster TEXT NOT NULL,
            selectedSchedule TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            totalPrice INTEGER NOT NULL,
            paymentMethod TEXT NOT NULL,
            cardNumber TEXT NOT NULL,
            status TEXT NOT NULL,
            date TEXT NOT NULL
        )
        ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Hapus tabel lama dan buat ulang dengan schema baru
      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('''
        CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            nama TEXT NOT NULL,
            alamat TEXT NOT NULL,
            telepon TEXT NOT NULL
        )
        ''');
      developer.log(
        'Database upgraded: Tabel users dibuat ulang dengan kolom yang benar',
      );
    }
  }

  // CRUD users
  Future<int> registerUser(Users user) async {
    final db = await instance.database;
    try {
      developer.log('===== REGISTER USER =====');
      developer.log('Username: "${user.username}"');
      developer.log('Email: "${user.email}"');
      developer.log('Password: "${user.password}"');

      final result = await db.insert('users', user.toMap());
      developer.log('Register berhasil dengan ID: $result');
      return result;
    } catch (e) {
      developer.log('Register gagal: $e', error: e);

      // Cek data yang sudah ada
      final existingUsers = await db.query('users');
      developer.log('Jumlah user di database: ${existingUsers.length}');
      for (var u in existingUsers) {
        developer.log(
          'User existing - Username: "${u['username']}", Email: "${u['email']}"',
        );
      }

      return -1; // error jika email / username sudah ada
    }
  }

  Future<Users?> loginUser(String username, String password) async {
    final db = await instance.database;

    developer.log('===== LOGIN USER =====');
    developer.log('Input Username/Email: "$username"');
    developer.log('Input Password: "$password"');

    // Cek semua user di database
    final allUsers = await db.query('users');
    developer.log('Total user di database: ${allUsers.length}');
    for (var u in allUsers) {
      developer.log(
        'User DB - Username: "${u['username']}", Email: "${u['email']}", Password: "${u['password']}"',
      );
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      developer.log('Login berhasil dengan username');
      return Users.fromMap(maps.first);
    } else {
      developer.log('Username tidak cocok, mencoba dengan email...');
      // coba login dengan email jika username tidak ditemukan
      final List<Map<String, dynamic>> mapsEmail = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [username, password],
      );
      if (mapsEmail.isNotEmpty) {
        developer.log('Login berhasil dengan email');
        return Users.fromMap(mapsEmail.first);
      } else {
        developer.log('Login gagal - Username/Email atau password salah');
      }
    }
    return null; // user tidak ditemukan
  }

  // CRUD transactions
  Future<int> insertTransaction(Transactions transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transactions>> getTransactions(String username) async {
    final db = await instance.database;
    // ambil transaksi berdasarkan username
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'date DESC', // diurutkan berdasarkan tanggal terbaru
    );
    return List.generate(maps.length, (i) {
      return Transactions.fromMap(maps[i]);
    });
  }

  Future<int> updateTransaction(Transactions transaction) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // digunakan tombol cancel untuk update status menjadi 'dibatalkan'
  // dan transaksi dihapus dari database
  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
