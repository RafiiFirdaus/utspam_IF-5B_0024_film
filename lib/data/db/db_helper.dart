import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:KirofTix/data/model/users.dart';
import 'package:KirofTix/data/model/transactions.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class DbHelper {
  static const String dbname = "kiroftix.db";
  static const int currentDbVersion = 5; // Versi database saat ini
  static const String dbVersionKey = 'database_version';

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

  // Fungsi untuk reset database (hapus dan buat ulang)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbname);

    developer.log('===== RESET DATABASE =====');
    developer.log('Menghapus database: $path');

    // Tutup database jika sedang terbuka
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    // Hapus file database
    await deleteDatabase(path);
    developer.log('Database berhasil dihapus');

    // Buat database baru
    _database = await _initDatabase(dbname);
    developer.log('Database baru berhasil dibuat');
  }

  // Fungsi untuk cek dan reset database jika versi tidak cocok
  Future<void> _checkAndResetDatabaseIfNeeded(String dbPath) async {
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getInt(dbVersionKey) ?? 0;

    developer.log('===== CEK VERSI DATABASE =====');
    developer.log('Versi tersimpan: $savedVersion');
    developer.log('Versi saat ini: $currentDbVersion');

    if (savedVersion != currentDbVersion) {
      developer.log('VERSI TIDAK COCOK! Menghapus semua database lama...');

      // Tutup database jika ada
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Hapus semua database lama
      final oldDatabases = [
        'kiroftix.db',
        'kiroftix_v2.db',
        'kiroftix_v3.db',
        'kiroftix_v4.db',
        'kiroftix_v5.db',
      ];

      for (var oldDb in oldDatabases) {
        final oldPath = join(dbPath, oldDb);
        try {
          await deleteDatabase(oldPath);
          developer.log('Database dihapus: $oldDb');
        } catch (e) {
          developer.log('Database tidak ditemukan: $oldDb');
        }
      }

      // Simpan versi baru
      await prefs.setInt(dbVersionKey, currentDbVersion);
      developer.log('Versi database diupdate ke: $currentDbVersion');
    } else {
      developer.log('Versi database sudah sesuai, tidak perlu reset');
    }
  }

  Future<Database> _initDatabase(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // CEK DAN RESET DATABASE JIKA VERSI TIDAK COCOK
    await _checkAndResetDatabaseIfNeeded(dbPath);

    developer.log('===== DATABASE PATH =====');
    developer.log('Database location: $path');

    final db = await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // Cek schema tabel users
    final tableInfo = await db.rawQuery('PRAGMA table_info(users)');
    developer.log('===== SCHEMA TABEL USERS =====');

    bool hasNamaColumn = false;
    bool hasFullNameColumn = false;

    for (var column in tableInfo) {
      developer.log('Column: ${column['name']} - Type: ${column['type']}');
      if (column['name'] == 'nama') hasNamaColumn = true;
      if (column['name'] == 'fullName') hasFullNameColumn = true;
    }

    // Jika masih ada kolom lama, paksa recreate tabel
    if (hasFullNameColumn && !hasNamaColumn) {
      developer.log('DETEKSI SCHEMA LAMA! Melakukan migrasi paksa...');
      await _migrateOldSchema(db);
    }

    // Cek schema tabel transactions
    final transTableInfo = await db.rawQuery('PRAGMA table_info(transactions)');
    developer.log('===== SCHEMA TABEL TRANSACTIONS =====');

    bool hasJudulFilmColumn = false;
    bool hasMovieTitleColumn = false;
    bool hasDateColumn = false;
    bool hasTanggalTransaksiColumn = false;

    for (var column in transTableInfo) {
      developer.log('Column: ${column['name']} - Type: ${column['type']}');
      if (column['name'] == 'judulFilm') hasJudulFilmColumn = true;
      if (column['name'] == 'movieTitle') hasMovieTitleColumn = true;
      if (column['name'] == 'date') hasDateColumn = true;
      if (column['name'] == 'tanggalTransaksi')
        hasTanggalTransaksiColumn = true;
    }

    // Jika masih ada kolom lama di transactions, paksa recreate
    if ((hasMovieTitleColumn && !hasJudulFilmColumn) ||
        (hasDateColumn && !hasTanggalTransaksiColumn)) {
      developer.log(
        'DETEKSI SCHEMA LAMA DI TRANSACTIONS! Melakukan migrasi paksa...',
      );
      await _migrateOldTransactionsSchema(db);
    }

    return db;
  }

  // Fungsi untuk migrasi paksa tabel transactions dari schema lama ke baru
  Future<void> _migrateOldTransactionsSchema(Database db) async {
    developer.log('===== MIGRASI SCHEMA TRANSACTIONS LAMA =====');

    // Hapus tabel transactions lama
    await db.execute('DROP TABLE IF EXISTS transactions');
    developer.log('Tabel transactions lama dihapus');

    // Buat tabel transactions baru dengan schema baru
    await db.execute('''
      CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL,
          judulFilm TEXT NOT NULL,
          poster TEXT NOT NULL,
          jadwalFilm TEXT NOT NULL,
          jumlahTiket INTEGER NOT NULL,
          totalHarga INTEGER NOT NULL,
          metodePembayaran TEXT NOT NULL,
          noKartu TEXT,
          status TEXT NOT NULL,
          tanggalTransaksi TEXT NOT NULL
      )
    ''');
    developer.log('Tabel transactions baru dibuat dengan schema yang benar');
  }

  // Fungsi untuk migrasi paksa dari schema lama ke baru
  Future<void> _migrateOldSchema(Database db) async {
    developer.log('===== MIGRASI SCHEMA LAMA =====');

    // Backup data user lama jika ada
    List<Map<String, dynamic>> oldUsers = [];
    try {
      oldUsers = await db.query('users');
      developer.log('Ditemukan ${oldUsers.length} user untuk dimigrasi');
    } catch (e) {
      developer.log('Tidak ada data untuk dibackup: $e');
    }

    // Hapus tabel lama
    await db.execute('DROP TABLE IF EXISTS users');
    developer.log('Tabel users lama dihapus');

    // Buat tabel baru dengan schema baru
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
    developer.log('Tabel users baru dibuat dengan schema yang benar');

    // Restore data jika ada (dengan mapping kolom lama ke baru)
    for (var oldUser in oldUsers) {
      try {
        await db.insert('users', {
          'id': oldUser['id'],
          'username': oldUser['username'],
          'email': oldUser['email'],
          'password': oldUser['password'],
          'nama': oldUser['fullName'] ?? oldUser['nama'] ?? '',
          'alamat': oldUser['address'] ?? oldUser['alamat'] ?? '',
          'telepon': oldUser['phone'] ?? oldUser['telepon'] ?? '',
        });
        developer.log('User ${oldUser['username']} berhasil dimigrasi');
      } catch (e) {
        developer.log('Gagal migrasi user ${oldUser['username']}: $e');
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    developer.log('===== DATABASE ONCREATE (Version $version) =====');
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
            judulFilm TEXT NOT NULL,
            poster TEXT NOT NULL,
            jadwalFilm TEXT NOT NULL,
            jumlahTiket INTEGER NOT NULL,
            totalHarga INTEGER NOT NULL,
            metodePembayaran TEXT NOT NULL,
            noKartu TEXT,
            status TEXT NOT NULL,
            tanggalTransaksi TEXT NOT NULL
        )
        ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    developer.log('===== DATABASE ONUPGRADE =====');
    developer.log('Upgrade dari versi $oldVersion ke $newVersion');

    // Migrasi untuk semua versi lama
    if (oldVersion < 5) {
      developer.log('Menghapus semua tabel lama...');
      // Hapus tabel lama dan buat ulang dengan schema baru
      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('DROP TABLE IF EXISTS transactions');
      developer.log('Membuat tabel users dan transactions baru...');

      // Recreate tables
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

      await db.execute('''
        CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            judulFilm TEXT NOT NULL,
            poster TEXT NOT NULL,
            jadwalFilm TEXT NOT NULL,
            jumlahTiket INTEGER NOT NULL,
            totalHarga INTEGER NOT NULL,
            metodePembayaran TEXT NOT NULL,
            noKartu TEXT,
            status TEXT NOT NULL,
            tanggalTransaksi TEXT NOT NULL
        )
        ''');

      developer.log(
        'Database upgraded: Tabel dibuat ulang dengan kolom yang benar',
      );
    }
  } // CRUD users

  Future<int> registerUser(Users user) async {
    final db = await instance.database;
    try {
      developer.log('===== REGISTER USER =====');
      developer.log(
        'Username: "${user.username}" (length: ${user.username.length})',
      );
      developer.log('Email: "${user.email}" (length: ${user.email.length})');
      developer.log(
        'Password: "${user.password}" (length: ${user.password.length})',
      );
      developer.log('Nama: "${user.nama}"');
      developer.log('Alamat: "${user.alamat}"');
      developer.log('Telepon: "${user.telepon}"');

      final userMap = user.toMap();
      developer.log('User Map: $userMap');

      final result = await db.insert('users', userMap);
      developer.log('Register berhasil dengan ID: $result');
      return result;
    } catch (e) {
      developer.log('Register gagal: $e', error: e);

      // Cek data yang sudah ada
      final existingUsers = await db.query('users');
      developer.log('Jumlah user di database: ${existingUsers.length}');
      for (var u in existingUsers) {
        developer.log('User existing - ID: ${u['id']}');
        developer.log(
          '  Username: "${u['username']}" (length: ${(u['username'] as String).length})',
        );
        developer.log(
          '  Email: "${u['email']}" (length: ${(u['email'] as String).length})',
        );
        developer.log('  Password: "${u['password']}"');
        developer.log('  Full data: $u');
      }

      return -1; // error jika email / username sudah ada
    }
  }

  Future<Users?> loginUser(String username, String password) async {
    final db = await instance.database;

    developer.log('===== LOGIN USER =====');
    developer.log(
      'Input Username/Email: "$username" (length: ${username.length})',
    );
    developer.log('Input Password: "$password" (length: ${password.length})');
    developer.log('Username bytes: ${username.codeUnits}');

    // Cek semua user di database
    final allUsers = await db.query('users');
    developer.log('Total user di database: ${allUsers.length}');
    for (var u in allUsers) {
      final dbUsername = u['username'] as String;
      final dbEmail = u['email'] as String;
      final dbPassword = u['password'] as String;
      developer.log('User DB - ID: ${u['id']}');
      developer.log(
        '  Username: "$dbUsername" (length: ${dbUsername.length}, bytes: ${dbUsername.codeUnits})',
      );
      developer.log('  Email: "$dbEmail" (length: ${dbEmail.length})');
      developer.log('  Password: "$dbPassword" (length: ${dbPassword.length})');
      developer.log('  Username match: ${username == dbUsername}');
      developer.log('  Password match: ${password == dbPassword}');
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
    try {
      developer.log('===== INSERT TRANSACTION =====');
      developer.log('Transaction data: ${transaction.toMap()}');

      final result = await db.insert('transactions', transaction.toMap());
      developer.log('Transaction berhasil disimpan dengan ID: $result');
      return result;
    } catch (e) {
      developer.log('ERROR Insert Transaction: $e', error: e);
      return -1;
    }
  }

  Future<List<Transactions>> getTransactions(String username) async {
    final db = await instance.database;
    // ambil transaksi berdasarkan username
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'tanggalTransaksi DESC', // diurutkan berdasarkan tanggal terbaru
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
