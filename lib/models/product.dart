const List<String> kCategories = [
  'Điện tử',
  'Thực phẩm',
  'Văn phòng phẩm',
  'Gia dụng',
  'Khác',
];

/// Products with quantity below this value are flagged as low stock.
const int kLowStockThreshold = 5;

class Product {
  final int? id;
  final String name;
  final int price;
  final int quantity;
  final String category;
  final bool active;
  final String? description;

  const Product({
    this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.category,
    this.active = true,
    this.description,
  });

  bool get isLowStock => quantity < kLowStockThreshold;

  int get stockValue => price * quantity;

  Product copyWith({int? quantity}) => Product(
        id: id,
        name: name,
        price: price,
        quantity: quantity ?? this.quantity,
        category: category,
        active: active,
        description: description,
      );

  factory Product.fromMap(Map<String, Object?> map) => Product(
        id: map['id'] as int?,
        name: map['name'] as String,
        price: map['price'] as int,
        quantity: map['quantity'] as int,
        category: map['category'] as String,
        active: (map['active'] as int) == 1,
        description: map['description'] as String?,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'category': category,
        'active': active ? 1 : 0,
        'description': description,
      };
}
