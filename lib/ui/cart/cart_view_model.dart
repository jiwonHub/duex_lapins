import 'package:duex_lapins/core/di/providers.dart';
import 'package:duex_lapins/domain/models/cart_item.dart';
import 'package:duex_lapins/domain/models/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartState {
  const CartState({this.items = const []});
  final List<CartItem> items;
  int get subtotal => items.fold(0, (sum, item) => sum + item.total);
  int get shipping => subtotal == 0 || subtotal >= 200000 ? 0 : 3000;
  int get total => subtotal + shipping;
  int get count => items.fold(0, (sum, item) => sum + item.quantity);
}

class CartViewModel extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  void add(Product product, String size, String color) {
    final items = ref.read(cartRepositoryProvider).add(product, size, color);
    state = CartState(items: items);
  }

  void updateQuantity(String productId, int quantity) {
    final items = ref.read(cartRepositoryProvider).updateQuantity(productId, quantity);
    state = CartState(items: items);
  }

  void remove(String productId) {
    final items = ref.read(cartRepositoryProvider).remove(productId);
    state = CartState(items: items);
  }

  void clear() {
    final items = ref.read(cartRepositoryProvider).clear();
    state = CartState(items: items);
  }
}

final cartViewModelProvider =
    NotifierProvider<CartViewModel, CartState>(CartViewModel.new);
