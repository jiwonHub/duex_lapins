import 'package:duex_lapins/domain/models/cart_item.dart';
import 'package:duex_lapins/domain/repositories/cart_repository.dart';
import 'package:duex_lapins/domain/models/product.dart';

class CartRepositoryImpl implements CartRepository {
  final List<CartItem> _items = [];

  @override
  List<CartItem> getItems() => List.unmodifiable(_items);

  @override
  List<CartItem> add(Product product, String size, String color) {
    final index = _items.indexWhere(
      (e) => e.product.id == product.id && e.size == size && e.color == color,
    );
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity + 1);
    } else {
      _items.add(
        CartItem(
          product: product,
          size: size,
          color: color,
          quantity: 1,
        ),
      );
    }
    return getItems();
  }

  @override
  List<CartItem> updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((e) => e.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
    }
    return getItems();
  }

  @override
  List<CartItem> remove(String productId) {
    _items.removeWhere((e) => e.product.id == productId);
    return getItems();
  }

  @override
  List<CartItem> clear() {
    _items.clear();
    return getItems();
  }
}
