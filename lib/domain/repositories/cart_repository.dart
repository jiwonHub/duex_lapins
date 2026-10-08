import 'package:duex_lapins/domain/models/cart_item.dart';
import 'package:duex_lapins/domain/models/product.dart';

abstract class CartRepository {
  List<CartItem> getItems();
  List<CartItem> add(Product product, String size, String color);
  List<CartItem> updateQuantity(String productId, int quantity);
  List<CartItem> remove(String productId);
  List<CartItem> clear();
}
