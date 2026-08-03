import 'package:intl/intl.dart';

extension NumberX on num {
  String get asCurrency => NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(this);
  String get compact => NumberFormat.compact().format(this);
  String get formatted => NumberFormat('#,###').format(this);
  String get asQuantity => '$formatted unit${this == 1 ? '' : 's'}';
}
