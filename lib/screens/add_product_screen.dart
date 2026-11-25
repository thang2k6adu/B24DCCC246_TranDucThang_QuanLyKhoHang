import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database_helper.dart';
import '../models/product.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _category = kCategories.first;
  bool _active = true;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _quantityCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên sản phẩm' : null;

  String? _validatePrice(String? v) {
    final n = int.tryParse(v?.trim() ?? '');
    if (n == null || n <= 0) return 'Giá bán phải lớn hơn 0';
    return null;
  }

  String? _validateQuantity(String? v) {
    final n = int.tryParse(v?.trim() ?? '');
    if (n == null || n < 0) return 'Số lượng không hợp lệ';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final desc = _descCtrl.text.trim();
    try {
      await DatabaseHelper.instance.insertProduct(Product(
        name: _nameCtrl.text.trim(),
        price: int.parse(_priceCtrl.text.trim()),
        quantity: int.parse(_quantityCtrl.text.trim()),
        category: _category,
        active: _active,
        description: desc.isEmpty ? null : desc,
      ));
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể lưu sản phẩm')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm sản phẩm')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Tên sản phẩm',
                border: OutlineInputBorder(),
              ),
              validator: _validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Giá bán (đ)',
                border: OutlineInputBorder(),
              ),
              validator: _validatePrice,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Số lượng',
                border: OutlineInputBorder(),
              ),
              validator: _validateQuantity,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Loại sản phẩm',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final c in kCategories)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Đang kinh doanh'),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Mô tả (không bắt buộc)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Lưu sản phẩm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
