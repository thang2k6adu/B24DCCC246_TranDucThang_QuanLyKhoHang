import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/product.dart';
import '../utils/format.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _db = DatabaseHelper.instance;

  List<Product> _products = [];
  int _totalValue = 0;
  int _lowStock = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final results = await Future.wait([
        _db.getAllProducts(),
        _db.getTotalValue(),
        _db.countLowStock(),
      ]);
      if (!mounted) return;
      setState(() {
        _products = results[0] as List<Product>;
        _totalValue = results[1] as int;
        _lowStock = results[2] as int;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Không thể tải dữ liệu';
      });
    }
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách sản phẩm')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(const AddProductScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Thêm sản phẩm'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));

    return Column(
      children: [
        _StatsCard(
          count: _products.length,
          totalValue: _totalValue,
          lowStock: _lowStock,
        ),
        Expanded(
          child: _products.isEmpty
              ? const Center(child: Text('Chưa có sản phẩm'))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: _products.length,
                  itemBuilder: (context, i) {
                    final p = _products[i];
                    return _ProductTile(
                      product: p,
                      onTap: () => _open(ProductDetailScreen(productId: p.id!)),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int count;
  final int totalValue;
  final int lowStock;

  const _StatsCard({
    required this.count,
    required this.totalValue,
    required this.lowStock,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.all(12),
      color: scheme.primaryContainer,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tổng số sản phẩm: $count'),
            const SizedBox(height: 4),
            Text('Tổng giá trị kho: ${formatVnd(totalValue)}'),
            const SizedBox(height: 4),
            Text(
              'Sắp hết hàng: $lowStock',
              style: TextStyle(
                color: lowStock > 0 ? scheme.error : null,
                fontWeight: lowStock > 0 ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final low = product.isLowStock;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: onTap,
        title: Text(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${formatVnd(product.price)} • ${product.category}'),
            if (low)
              Text(
                'Sắp hết hàng',
                style: TextStyle(
                  color: scheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Tồn kho', style: TextStyle(fontSize: 11)),
            Text(
              '${product.quantity}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: low ? scheme.error : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
