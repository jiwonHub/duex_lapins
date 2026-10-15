import 'package:deux_lapins/data/services/shopping_mock_api_data_source.dart';
import 'package:deux_lapins/domain/models/order.dart';
import 'package:deux_lapins/domain/models/order_claim.dart';
import 'package:deux_lapins/core/network/shared_mock_api_client.dart';
import 'package:deux_lapins/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._api);

  final ShoppingMockApiDataSource _api;

  Future<dynamic> _request(
      String method,
      String path, [
        Map<String, dynamic>? body,
      ]) async {
    final response = await _api.request(method, path, body);
    if (response['success'] != true) {
      final error = response['error'] as Map<String, dynamic>?;
      throw ShoppingMockApiException(
        error?['code']?.toString() ?? 'UNKNOWN',
        error?['message']?.toString() ?? '주문 요청에 실패했습니다.',
      );
    }
    return response['data'];
  }

  @override
  Future<List<Order>> getOrders(String userId) async {
    final data = await _request(
      'GET', '/orders?user_id=${Uri.encodeQueryComponent(userId)}',
    ) as List<dynamic>;
    return data
        .map((row) => Order.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Order?> getOrder(String userId, String orderId) async {
    try {
      final data = await _request(
        'GET',
        '/orders/${Uri.encodeComponent(orderId)}?user_id=${Uri.encodeQueryComponent(userId)}',
      );
      return Order.fromJson(data as Map<String, dynamic>);
    } on ShoppingMockApiException catch (error) {
      if (error.code == 'NOT_FOUND') return null;
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getItemTracking(
      String userId,
      String orderId,
      String orderItemId,
      ) async {
    final result = await _request(
      'GET',
      '/orders/${Uri.encodeComponent(orderId)}/items/'
          '${Uri.encodeComponent(orderItemId)}/tracking'
          '?user_id=${Uri.encodeQueryComponent(userId)}',
    );

    return result as Map<String, dynamic>;
  }

  @override
  Future<List<OrderClaim>> getClaims(String userId) async {
    if (!SharedMockApiClient.enabled) {
      throw StateError('클레임 테스트는 공통 Mock API 서버 연결이 필요합니다.');
    }
    final rows = await _request('GET',
        '/claims?user_id=${Uri.encodeQueryComponent(userId)}') as List<dynamic>;
    return rows.map((row) => OrderClaim.fromJson(
      row as Map<String, dynamic>,
    )).toList(growable: false);
  }

  @override
  Future<OrderClaim> submitClaim(
      String userId, String requestId, OrderClaimRequest request,
      ) async {
    if (!SharedMockApiClient.enabled) {
      throw StateError('클레임 테스트는 공통 Mock API 서버 연결이 필요합니다.');
    }
    final data = await _request('POST', '/claims',
        request.toJson(userId, requestId));
    return OrderClaim.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Order> placeOrder(Map<String, dynamic> request) async {
    final data = await _request('POST', '/orders', request);
    return Order.fromJson(data as Map<String, dynamic>);
  }
}