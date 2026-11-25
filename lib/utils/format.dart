import 'package:intl/intl.dart';

final NumberFormat _vnd = NumberFormat('#,###', 'vi_VN');

/// Formats an amount as Vietnamese dong, e.g. `150.000 đ`.
String formatVnd(int amount) => '${_vnd.format(amount)} đ';
