import 'dart:convert';

import 'package:deux_lapins/data/services/catalog_mock_data_source.dart';
import 'package:deux_lapins/domain/models/product.dart';
import 'package:deux_lapins/domain/repositories/catalog_repository.dart';
import 'package:deux_lapins/core/network/shared_mock_api_client.dart';

class ShoppingMockApiException implements Exception {
  const ShoppingMockApiException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

/// 현재 Flutter 실행 환경에서만 살아 있는 장바구니·위시리스트 원본.
/// 요청/응답은 실제 HTTP JSON과 동일하게 직렬화한다.
class ShoppingMockApiDataSource {
  ShoppingMockApiDataSource(
      this._catalog,
      this._catalogSource, {
        String? Function()? currentUserId,
      }) : _currentUserId = currentUserId;

  final CatalogRepository _catalog;
  final CatalogMockDataSource _catalogSource;
  final String? Function()? _currentUserId;
  final Map<String, int> _cart = <String, int>{};
  final Set<String> _wishlist = <String>{'p02', 'p05'};
  final List<Map<String, dynamic>> _orders = [];
  final Map<String, Map<String, dynamic>> _completedRequests = {};
  bool _ordering = false;
  int _orderSequence = 0;

  Future<Map<String, dynamic>> request(
      String method,
      String path, [
        Map<String, dynamic>? body,
      ]) async {
    if (SharedMockApiClient.enabled) {
      final uri = Uri.parse(path);

      final requiresUser =
          uri.path == '/cart' ||
              uri.path.startsWith('/cart/') ||
              uri.path == '/wishlist' ||
              uri.path.startsWith('/wishlist/');

      var requestPath = path;

      if (requiresUser) {
        final currentUserId = _currentUserId?.call()?.trim();
        final userId = currentUserId == null || currentUserId.isEmpty
            ? 'guest'
            : currentUserId;

        requestPath = uri.replace(
          queryParameters: {
            ...uri.queryParameters,
            'user_id': userId,
          },
        ).toString();
      }

      return SharedMockApiClient.instance.request(
        method,
        requestPath,
        body,
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 80));
    final payload = body == null
        ? null
        : jsonDecode(jsonEncode(body)) as Map<String, dynamic>;
    try {
      final data = await _dispatch(method.toUpperCase(), path, payload);
      return jsonDecode(jsonEncode({'success': true, 'data': data}))
      as Map<String, dynamic>;
    } on ShoppingMockApiException catch (error) {
      return {
        'success': false,
        'error': {'code': error.code, 'message': error.message},
      };
    } on StateError catch (error) {
      return {
        'success': false,
        'error': {'code': 'INSUFFICIENT_STOCK', 'message': error.message},
      };
    }
  }

  Future<Object?> _dispatch(
      String method,
      String path,
      Map<String, dynamic>? body,
      ) async {
    final uri = Uri.parse(path);
    final parts = uri.pathSegments;
    if (method == 'POST' && uri.path == '/orders') {
      return _createOrder(body);
    }
    if (method == 'GET' &&
        parts.length == 5 &&
        parts[0] == 'orders' &&
        parts[2] == 'items' &&
        parts[4] == 'tracking') {
      final order = _orders.where(
            (o) =>
        o['id'] == parts[1] &&
            o['user_id'] == uri.queryParameters['user_id'],
      );

      if (order.isEmpty) {
        throw const ShoppingMockApiException(
          'NOT_FOUND',
          '주문을 찾을 수 없습니다.',
        );
      }

      final items = order.first['items'] as List<dynamic>;
      final matches = items.where(
            (raw) =>
        (raw as Map<String, dynamic>)['product_variant_id'] ==
            parts[3],
      );

      if (matches.isEmpty) {
        throw const ShoppingMockApiException(
          'NOT_FOUND',
          '주문 상품을 찾을 수 없습니다.',
        );
      }

      final item = matches.first as Map<String, dynamic>;

      return {
        'source': 'mock',
        'status': item['delivery_status'] ?? 'preparing',
        'label': '실시간 배송조회 미연결',
        'tracking_number': item['tracking_number'] ?? '',
      };
    }

    if (method == 'GET' && uri.path == '/orders') {
      final userId = uri.queryParameters['user_id'];
      if (userId == null || userId.isEmpty) {
        throw const ShoppingMockApiException('UNAUTHORIZED', '회원 ID가 없습니다.');
      }
      return _orders.where((order) => order['user_id'] == userId).toList();
    }
    if (method == 'GET' && parts.length == 2 && parts[0] == 'orders') {
      final userId = uri.queryParameters['user_id'];
      for (final order in _orders) {
        if (order['id'] == parts[1] && order['user_id'] == userId) return order;
      }
      throw const ShoppingMockApiException('NOT_FOUND', '주문을 찾을 수 없습니다.');
    }
    if (_ordering && (path.startsWith('/cart'))) {
      throw const ShoppingMockApiException('BUSY', '주문 처리 중에는 장바구니를 변경할 수 없습니다.');
    }
    if (method == 'GET' && path == '/cart') {
      return _cart.entries
          .map((entry) => {
        'product_variant_id': entry.key,
        'quantity': entry.value,
      })
          .toList(growable: false);
    }
    if (method == 'DELETE' && path == '/cart') {
      _cart.clear();
      return <String, dynamic>{'cleared': true};
    }
    if (method == 'POST' && path == '/cart/items') {
      final variantId = body?['product_variant_id'];
      final quantity = body?['quantity'];
      if (variantId is! String || quantity is! int || quantity <= 0) {
        throw const ShoppingMockApiException(
            'VALIDATION_ERROR', '옵션 ID와 1 이상의 수량이 필요합니다.');
      }
      final variant = await _findVariant(variantId);
      _checkStock(variant, (_cart[variantId] ?? 0) + quantity);
      _cart[variantId] = (_cart[variantId] ?? 0) + quantity;
      return {'product_variant_id': variantId, 'quantity': _cart[variantId]};
    }
    if (parts.length == 3 && parts[0] == 'cart' && parts[1] == 'items') {
      final variantId = parts[2];
      if (method == 'PATCH') {
        final quantity = body?['quantity'];
        if (quantity is! int || quantity < 1) {
          throw const ShoppingMockApiException(
              'VALIDATION_ERROR', '1 이상의 수량을 입력해주세요.');
        }
        if (!_cart.containsKey(variantId)) {
          throw const ShoppingMockApiException(
              'NOT_FOUND', '장바구니 항목이 없습니다.');
        }
        final variant = await _findVariant(variantId);
        _checkStock(variant, quantity);
        _cart[variantId] = quantity;
        return {'product_variant_id': variantId, 'quantity': quantity};
      }
      if (method == 'DELETE') {
        if (_cart.remove(variantId) == null) {
          throw const ShoppingMockApiException(
              'NOT_FOUND', '장바구니 항목이 없습니다.');
        }
        return {'product_variant_id': variantId, 'deleted': true};
      }
    }
    if (method == 'GET' && path == '/wishlist') {
      return _wishlist.toList(growable: false);
    }
    if (parts.length == 2 && parts[0] == 'wishlist') {
      final productId = parts[1];
      if (method == 'PUT') {
        final products = await _catalog.getProducts();
        if (!products.any((product) => product.id == productId && product.isVisible)) {
          throw const ShoppingMockApiException(
              'NOT_FOUND', '존재하지 않거나 비공개된 상품입니다.');
        }
        _wishlist.add(productId);
        return _wishlist.toList(growable: false);
      }
      if (method == 'DELETE') {
        _wishlist.remove(productId);
        return _wishlist.toList(growable: false);
      }
    }
    throw const ShoppingMockApiException(
        'NOT_FOUND', '지원하지 않는 Mock API 경로입니다.');
  }

  Future<Map<String, dynamic>> _createOrder(Map<String, dynamic>? body) async {
    final userId = (body?['user_id'] as String?)?.trim() ?? '';
    final key = (body?['request_id'] as String?)?.trim() ?? '';
    final recipient = (body?['recipient_name'] as String?)?.trim() ?? '';
    final phone = (body?['recipient_phone'] as String?)?.trim() ?? '';
    final postcode = (body?['postcode'] as String?)?.trim() ?? '';
    final address = (body?['address'] as String?)?.trim() ?? '';
    final detail = (body?['detail_address'] as String?)?.trim() ?? '';
    final paymentMethod = (body?['payment_method'] as String?) ?? '';
    if (userId.isEmpty) {
      throw const ShoppingMockApiException('UNAUTHORIZED', '로그인이 필요합니다.');
    }
    if (key.isEmpty || recipient.isEmpty || phone.replaceAll(RegExp(r'\D'), '').length < 9 ||
        postcode.isEmpty || address.isEmpty ||
        !const ['card', 'kakao_pay', 'naver_pay', 'bank_transfer'].contains(paymentMethod)) {
      throw const ShoppingMockApiException('VALIDATION_ERROR', '배송지 또는 결제 수단을 확인해주세요.');
    }
    final requestKey = '$userId|$key';
    final previous = _completedRequests[requestKey];
    if (previous != null) return previous;
    if (_ordering) {
      throw const ShoppingMockApiException('BUSY', '다른 주문을 처리 중입니다.');
    }
    _ordering = true;
    try {
      if (_cart.isEmpty) {
        throw const ShoppingMockApiException('EMPTY_CART', '장바구니가 비어 있습니다.');
      }
      final products = await _catalog.getProducts();
      final items = <Map<String, dynamic>>[];
      var productAmount = 0;
      for (final entry in _cart.entries) {
        Product? product;
        ProductVariant? variant;
        for (final candidate in products) {
          for (final option in candidate.variants) {
            if (option.id == entry.key) {
              product = candidate;
              variant = option;
              break;
            }
          }
          if (product != null) break;
        }
        if (product == null || variant == null ||
            !product.isVisible || product.saleStatus != 'selling' ||
            variant.isSoldOut || entry.value > variant.stockQuantity) {
          throw ShoppingMockApiException('INSUFFICIENT_STOCK',
              '품절 또는 재고 부족 옵션이 있습니다: ${entry.key}');
        }
        productAmount += product.price * entry.value;
        items.add({
          'product_variant_id': variant.id,
          'product_id': product.id,
          'product_name': product.name,
          'product_code': product.productCode.isEmpty ? product.id : product.productCode,
          'color_name': variant.color,
          'size_name': variant.size,
          'image_url': product.imageUrl,
          'quantity': entry.value,
          'unit_price': product.price,
          'carrier': '',
          'tracking_number': '',
          'delivery_status': 'preparing',
        });
      }
      final fee = productAmount >= 200000 ? 0 : 3000;
      final total = productAmount + fee;
      // 실패 모드는 결제 거절만 시뮬레이션. 재고/카트/주문을 변경하지 않는다.
      if (body?['simulate_payment_failure'] == true) {
        throw const ShoppingMockApiException('PAYMENT_FAILED', 'Mock 결제 승인이 거절되었습니다.');
      }
      await _catalogSource.deductStock(Map<String, int>.from(_cart));
      final now = DateTime.now();
      final date = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final orderNo = 'DL-$date-${(++_orderSequence).toString().padLeft(5, '0')}';
      final result = <String, dynamic>{
        'id': orderNo,
        'order_number': orderNo,
        'user_id': userId,
        'ordered_at': now.toIso8601String(),
        'order_status': 'payment_completed',
        'payment_status': 'paid',
        'delivery_status': 'preparing',
        'payment_method': paymentMethod,
        'recipient_name': recipient,
        'recipient_phone': phone,
        'postcode': postcode,
        'address': address,
        'detail_address': detail,
        'product_amount': productAmount,
        'shipping_fee': fee,
        'total_amount': total,
        'items': items,
      };
      _orders.insert(0, result);
      _completedRequests[requestKey] = result;
      _cart.clear();
      return result;
    } finally {
      _ordering = false;
    }
  }

  Future<ProductVariant> _findVariant(String variantId) async {
    final products = await _catalog.getProducts();
    for (final product in products) {
      if (!product.isVisible || product.saleStatus != 'selling') continue;
      for (final variant in product.variants) {
        if (variant.id == variantId && variant.isActive) return variant;
      }
    }
    throw const ShoppingMockApiException(
        'NOT_FOUND', '판매 가능한 상품 옵션이 없습니다.');
  }

  void _checkStock(ProductVariant variant, int requested) {
    if (variant.isSoldOut || requested > variant.stockQuantity) {
      throw ShoppingMockApiException(
        'INSUFFICIENT_STOCK',
        '선택한 옵션의 재고가 부족합니다. (잔여 ${variant.stockQuantity}개)',
      );
    }
  }
}