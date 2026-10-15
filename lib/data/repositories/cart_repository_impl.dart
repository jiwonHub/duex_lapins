import 'package:deux_lapins/data/services/shopping_mock_api_data_source.dart';
import 'package:deux_lapins/domain/repositories/catalog_repository.dart';
import 'package:deux_lapins/domain/models/cart_item.dart';
import 'package:deux_lapins/domain/repositories/cart_repository.dart';
import 'package:deux_lapins/domain/models/product.dart';
import 'package:deux_lapins/domain/models/selected_product_option.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._api, this._catalog);

  final ShoppingMockApiDataSource _api;
  final CatalogRepository _catalog;

  Future<dynamic> _request(String method, String path,
      [Map<String, dynamic>? body]) async {
    final response = await _api.request(method, path, body);
    if (response['success'] != true) {
      final error = response['error'] as Map<String, dynamic>?;
      throw ShoppingMockApiException(
        error?['code']?.toString() ?? 'UNKNOWN',
        error?['message']?.toString() ?? '장바구니 요청에 실패했습니다.',
      );
    }
    return response['data'];
  }

  @override
  Future<List<CartItem>> getItems() async {
    final rows = await _request('GET', '/cart') as List<dynamic>;
    final products = await _catalog.getProducts();
    final result = <CartItem>[];
    for (final raw in rows) {
      final row = raw as Map<String, dynamic>;
      final variantId = row['product_variant_id'] as String;
      for (final product in products) {
        for (final variant in product.variants) {
          if (variant.id != variantId) continue;
          result.add(CartItem(
            product: product,
            productVariantId: variantId,
            color: variant.color,
            size: variant.size,
            quantity: row['quantity'] as int,
          ));
        }
      }
    }
    return List.unmodifiable(result);
  }

  @override
  Future<List<CartItem>> add(Product product, String size, String color) async {
    final variant = product.variantFor(color, size);
    if (variant == null) {
      throw const ShoppingMockApiException('NOT_FOUND', '선택한 상품 옵션이 없습니다.');
    }
    await _request('POST', '/cart/items', {
      'product_variant_id': variant.id,
      'quantity': 1,
    });
    return getItems();
  }

  @override
  Future<List<CartItem>> addOptions(List<SelectedProductOption> options) async {
    if (options.isEmpty) {
      throw StateError('장바구니에 담을 옵션을 선택해주세요.');
    }

    final quantities = <String, int>{};
    for (final option in options) {
      if (option.quantity <= 0) {
        throw StateError('수량은 1개 이상이어야 합니다.');
      }
      quantities.update(
        option.variantId,
            (quantity) => quantity + option.quantity,
        ifAbsent: () => option.quantity,
      );
    }

    // 기존 서버의 단건 API를 재사용한다. 실제 API에서 batch를 지원하면
    // 이 메서드의 전송 로직만 교체하면 되고 ViewModel/UI는 그대로 유지한다.
    final previous = {
      for (final item in await getItems())
        item.productVariantId: item.quantity,
    };
    final applied = <String>[];

    try {
      for (final entry in quantities.entries) {
        await _request('POST', '/cart/items', {
          'product_variant_id': entry.key,
          'quantity': entry.value,
        });
        applied.add(entry.key);
      }
      return await getItems();
    } catch (error) {
      var rollbackFailed = false;
      for (final variantId in applied.reversed) {
        try {
          final previousQuantity = previous[variantId];
          if (previousQuantity == null) {
            await _request(
              'DELETE',
              '/cart/items/${Uri.encodeComponent(variantId)}',
            );
          } else {
            await _request(
              'PATCH',
              '/cart/items/${Uri.encodeComponent(variantId)}',
              {'quantity': previousQuantity},
            );
          }
        } catch (_) {
          rollbackFailed = true;
        }
      }
      if (rollbackFailed) {
        throw StateError('일부 옵션의 장바구니 복원에 실패했습니다. 장바구니를 확인해주세요. ($error)');
      }
      rethrow;
    }
  }

  @override
  Future<List<CartItem>> updateQuantity(String productVariantId, int quantity) async {
    if (quantity <= 0) return remove(productVariantId);
    await _request(
      'PATCH', '/cart/items/${Uri.encodeComponent(productVariantId)}',
      {'quantity': quantity},
    );
    return getItems();
  }

  @override
  Future<List<CartItem>> remove(String productVariantId) async {
    await _request('DELETE', '/cart/items/${Uri.encodeComponent(productVariantId)}');
    return getItems();
  }

  @override
  Future<List<CartItem>> clear() async {
    await _request('DELETE', '/cart');
    return getItems();
  }
}