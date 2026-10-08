import 'package:duex_lapins/domain/models/order.dart';
import 'package:duex_lapins/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  @override
  Future<List<Order>> getOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    return const [
      Order(
        id: 'DL-20261006-1042',
        date: '2026.10.06',
        status: '배송 준비 중',
        itemName: 'Structured Wool Coat',
        itemCount: 2,
        total: 648000,
        imageUrl: 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=600&q=85',
      ),
      Order(
        id: 'DL-20260918-0834',
        date: '2026.09.18',
        status: '배송 완료',
        itemName: 'Leather Shoulder Bag',
        itemCount: 1,
        total: 379000,
        imageUrl: 'https://images.unsplash.com/photo-1559563458-527698bf5295?auto=format&fit=crop&w=600&q=85',
      ),
    ];
  }
}
