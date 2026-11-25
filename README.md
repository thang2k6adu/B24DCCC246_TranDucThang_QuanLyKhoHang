# Quản lý kho hàng (Flutter)

Ứng dụng Android quản lý kho hàng cho cửa hàng nhỏ: đăng nhập, xem danh sách sản phẩm kèm thống kê, thêm sản phẩm, xem chi tiết, nhập thêm / bán / xóa. Dữ liệu lưu bằng SQLite (`warehouse.db`) qua `sqflite`.

Tài khoản mẫu: `admin` / `123456`.

## Cấu trúc

```
lib/
├─ main.dart
├─ models/product.dart            # Product, danh mục, ngưỡng sắp hết hàng
├─ data/database_helper.dart      # SQLite: bảng users, products + các truy vấn
├─ screens/
│  ├─ login_screen.dart
│  ├─ main_screen.dart            # thống kê + danh sách
│  ├─ add_product_screen.dart
│  └─ product_detail_screen.dart
└─ utils/format.dart              # định dạng tiền VNĐ
test/database_helper_test.dart    # unit test DatabaseHelper
```

## Chạy ứng dụng

```
flutter pub get
flutter run
flutter test
```
