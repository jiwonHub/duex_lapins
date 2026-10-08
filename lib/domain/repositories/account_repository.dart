import 'package:duex_lapins/domain/models/order.dart';

abstract class AccountRepository {
  Future<List<Order>> getOrders();
}
