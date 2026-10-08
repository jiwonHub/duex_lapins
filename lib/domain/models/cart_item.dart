import 'package:duex_lapins/domain/models/product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
  });

  final Product product;
  final String size;
  final String color;
  final int quantity;

  int get total => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      size: size,
      color: color,
      quantity: quantity ?? this.quantity,
    );
  }
}
