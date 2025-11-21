import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:KirofTix/data/model/users.dart';
import 'package:KirofTix/data/model/transactions.dart';

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
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // tabel users (email & username harus unik)
    await db.execute('''
        CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            fullName TEXT NOT NULL,
            address TEXT NOT NULL,
            phone TEXT NOT NULL
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

  // CRUD users
  Future<int> registerUser(Users user) async {
    final db = await instance.database;
    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      return -1; // error jika email / username sudah ada
    }
  }

  Future<Users?> loginUser(String username, String password) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return Users.fromMap(maps.first);
    } else {
      // coba login dengan email jika username tidak ditemukan
      final List<Map<String, dynamic>> mapsEmail = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [username, password],
      );
      if (mapsEmail.isNotEmpty) {
        return Users.fromMap(mapsEmail.first);
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

  Future<int> updateTransactionStatus(int id, String status) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // digunakan tombol cancel untuk update status menjadi 'dibatalkan'
  // dan transaksi dihapus dari database
  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
