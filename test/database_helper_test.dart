import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:warehouse_manager/data/database_helper.dart';
import 'package:warehouse_manager/models/product.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseHelper helper;

  setUp(() {
    helper = DatabaseHelper.forPath(inMemoryDatabasePath);
  });

  tearDown(() async {
    await helper.close();
  });

  test('seeds sample products and statistics', () async {
    final products = await helper.getAllProducts();
    expect(products.length, 3);
    expect(await helper.countProducts(), 3);
    expect(await helper.getTotalValue(), 5350000);
    expect(await helper.countLowStock(), 1);
    expect(products.every((p) => p.active), isTrue);
  });

  test('checkLogin validates against users table', () async {
    expect(await helper.checkLogin('admin', '123456'), isTrue);
    expect(await helper.checkLogin('admin', 'wrong'), isFalse);
    expect(await helper.checkLogin('nobody', '123456'), isFalse);
    expect(await helper.checkLogin('', ''), isFalse);
  });

  test('insertUser adds an account and rejects duplicates', () async {
    await helper.insertUser('staff', 'abc');
    expect(await helper.checkLogin('staff', 'abc'), isTrue);
    expect(() => helper.insertUser('staff', 'x'), throwsA(anything));
  });

  test('insertProduct and getProductById round-trip', () async {
    final id = await helper.insertProduct(const Product(
      name: 'Nồi chiên',
      price: 1200000,
      quantity: 2,
      category: 'Gia dụng',
      active: false,
      description: 'Mô tả',
    ));
    final p = await helper.getProductById(id);
    expect(p, isNotNull);
    expect(p!.name, 'Nồi chiên');
    expect(p.active, isFalse);
    expect(p.description, 'Mô tả');
    expect(await helper.countProducts(), 4);
    expect(await helper.countLowStock(), 2);
  });

  test('getProductById returns null for unknown id', () async {
    expect(await helper.getProductById(9999), isNull);
  });

  test('updateQuantity changes stats', () async {
    final keyboard = (await helper.getAllProducts())
        .firstWhere((p) => p.name == 'Bàn phím cơ');
    await helper.updateQuantity(keyboard.id!, 10);
    expect((await helper.getProductById(keyboard.id!))!.quantity, 10);
    expect(await helper.countLowStock(), 0);
    expect(await helper.getTotalValue(), 5350000 + 450000 * 7);
  });

  test('deleteProduct removes the row and handles empty table', () async {
    for (final p in await helper.getAllProducts()) {
      await helper.deleteProduct(p.id!);
    }
    expect(await helper.getAllProducts(), isEmpty);
    expect(await helper.getTotalValue(), 0);
    expect(await helper.countLowStock(), 0);
  });
}
