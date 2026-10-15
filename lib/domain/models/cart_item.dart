import 'package:deux_lapins/domain/models/product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
    required this.productVariantId,
  });

  final Product product;
  final String productVariantId;
  final String size;
  final String color;
  final int quantity;

  int get total => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      size: size,
      color: color,
      productVariantId: productVariantId,
      quantity: quantity ?? this.quantity,
    );
  }
}
