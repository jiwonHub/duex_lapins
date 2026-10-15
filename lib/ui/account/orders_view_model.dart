import 'package:deux_lapins/core/di/providers.dart';
import 'package:deux_lapins/domain/models/order.dart';
import 'package:deux_lapins/ui/auth/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrdersState {
  const OrdersState({
    this.orders = const [],
    this.loading = true,
    this.errorMessage,
  });

  final List<Order> orders;
  final bool loading;
  final String? errorMessage;
}

class OrdersViewModel extends Notifier<OrdersState> {
  @override
  OrdersState build() {
    final userId = ref.watch(authViewModelProvider.select((value) => value.user?.id));
    if (userId != null) Future<void>.microtask(refresh);
    return OrdersState(loading: userId != null);
  }

  Future<void> refresh() async {
    final userId = ref.read(authViewModelProvider).user?.id;
    if (userId == null) return;
    state = OrdersState(orders: state.orders);
    try {
      final orders = await ref.read(orderRepositoryProvider).getOrders(userId);
      if (ref.read(authViewModelProvider).user?.id != userId) return;
      state = OrdersState(orders: orders, loading: false);
    } catch (error) {
      state = OrdersState(loading: false, errorMessage: '$error');
    }
  }
}

final ordersViewModelProvider =
NotifierProvider<OrdersViewModel, OrdersState>(OrdersViewModel.new);