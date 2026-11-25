import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/product.dart';
import '../utils/format.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _db = DatabaseHelper.instance;

  Product? _product;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _db.getProductById(widget.productId);
    if (!mounted) return;
    if (p == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _product = p;
      _loading = false;
    });
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _changeQuantity(int delta) async {
    final p = _product!;
    if (delta < 0 && p.quantity == 0) {
      _toast('Hết hàng');
      return;
    }
    await _db.updateQuantity(p.id!, p.quantity + delta);
    await _load();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc muốn xóa "${_product!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _db.deleteProduct(_product!.id!);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(_product!),
    );
  }

  Widget _buildContent(Product p) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final desc = (p.description == null || p.description!.isEmpty)
        ? 'Không có mô tả'
        : p.description!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(p.name, style: textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '${p.category} • ${p.active ? 'Đang kinh doanh' : 'Ngừng kinh doanh'}',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Giá bán: ${formatVnd(p.price)}'),
                const SizedBox(height: 8),
                Text(
                  'Số lượng tồn: ${p.quantity}',
                  style: TextStyle(
                    color: p.isLowStock ? scheme.error : null,
                    fontWeight: p.isLowStock ? FontWeight.bold : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Giá trị tồn kho: ${formatVnd(p.stockValue)}'),
                if (p.isLowStock) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Cảnh báo: sắp hết hàng',
                    style: TextStyle(
                      color: scheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Mô tả', style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(desc),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _changeQuantity(1),
                icon: const Icon(Icons.add),
                label: const Text('Nhập thêm 1'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => _changeQuantity(-1),
                icon: const Icon(Icons.remove),
                label: const Text('Bán 1'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Quay lại'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _delete,
                style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Xóa sản phẩm'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
