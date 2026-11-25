import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/product.dart';

class DatabaseHelper {
  static const String _dbName = 'warehouse.db';
  static const int _dbVersion = 1;

  DatabaseHelper._(this._path);

  /// App-wide instance backed by `warehouse.db` in the default databases dir.
  static final DatabaseHelper instance = DatabaseHelper._(null);

  /// Creates a helper bound to a custom path (e.g. [inMemoryDatabasePath]).
  /// Intended for tests.
  factory DatabaseHelper.forPath(String path) => DatabaseHelper._(path);

  final String? _path;
  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = _path ?? p.join(await getDatabasesPath(), _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT NOT NULL,
        active INTEGER NOT NULL,
        description TEXT
      )
    ''');

    await _insertUser(db, 'admin', '123456');
    const samples = [
      Product(
          name: 'Chuột không dây',
          price: 150000,
          quantity: 20,
          category: 'Điện tử'),
      Product(
          name: 'Bàn phím cơ',
          price: 450000,
          quantity: 3,
          category: 'Điện tử'),
      Product(
          name: 'Sổ tay A5',
          price: 25000,
          quantity: 40,
          category: 'Văn phòng phẩm'),
    ];
    for (final s in samples) {
      await db.insert('products', s.toMap());
    }
  }

  Future<int> _insertUser(DatabaseExecutor db, String username, String password) {
    return db.insert('users', {'username': username, 'password': password});
  }

  Future<bool> checkLogin(String username, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<int> insertUser(String username, String password) async {
    final db = await database;
    return _insertUser(db, username, password);
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final rows = await db.query('products', orderBy: 'id DESC');
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final rows = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Product.fromMap(rows.first);
  }

  Future<int> updateQuantity(int id, int quantity) async {
    final db = await database;
    return db.update(
      'products',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getTotalValue() async {
    final db = await database;
    final rows =
        await db.rawQuery('SELECT SUM(price * quantity) AS total FROM products');
    return (rows.first['total'] as int?) ?? 0;
  }

  Future<int> countLowStock() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM products WHERE quantity < ?',
      [kLowStockThreshold],
    );
    return (rows.first['c'] as int?) ?? 0;
  }

  Future<int> countProducts() async {
    final db = await database;
    final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM products');
    return (rows.first['c'] as int?) ?? 0;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
