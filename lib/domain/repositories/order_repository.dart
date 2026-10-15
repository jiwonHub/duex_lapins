import 'package:deux_lapins/domain/models/order.dart';
import 'package:deux_lapins/domain/models/order_claim.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders(String userId);
  Future<Order?> getOrder(String userId, String orderId);
  Future<Order> placeOrder(Map<String, dynamic> request);
  Future<List<OrderClaim>> getClaims(String userId);
  Future<OrderClaim> submitClaim(
      String userId, String requestId, OrderClaimRequest request,
      );

  Future<Map<String, dynamic>> getItemTracking(
      String userId,
      String orderId,
      String orderItemId,
      );
}