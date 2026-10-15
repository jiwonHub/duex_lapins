import 'package:deux_lapins/domain/models/cart_item.dart';
import 'package:deux_lapins/domain/models/product.dart';
import 'package:deux_lapins/domain/models/selected_product_option.dart';

abstract class CartRepository {
  Future<List<CartItem>> getItems();
  Future<List<CartItem>> add(Product product, String size, String color);
  Future<List<CartItem>> addOptions(List<SelectedProductOption> options);
  Future<List<CartItem>> updateQuantity(String productVariantId, int quantity);
  Future<List<CartItem>> remove(String productVariantId);
  Future<List<CartItem>> clear();
}
