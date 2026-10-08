import 'package:duex_lapins/core/di/providers.dart';
import 'package:duex_lapins/domain/models/order.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountState {
  const AccountState({
    this.orders = const [],
    this.loading = true,
    this.name = '',
    this.email = '',
  });

  final List<Order> orders;
  final bool loading;
  final String name;
  final String email;

  AccountState copyWith({
    List<Order>? orders,
    bool? loading,
    String? name,
    String? email,
  }) {
    return AccountState(
      orders: orders ?? this.orders,
      loading: loading ?? this.loading,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}

class AccountViewModel extends Notifier<AccountState> {
  @override
  AccountState build() {
    Future<void>.microtask(_load);
    return const AccountState();
  }

  Future<void> _load() async {
    final orders = await ref.read(accountRepositoryProvider).getOrders();
    state = state.copyWith(orders: orders, loading: false);
  }

  void updateProfile(String name, String email) {
    state = state.copyWith(name: name, email: email);
  }
}

final accountViewModelProvider =
    NotifierProvider<AccountViewModel, AccountState>(AccountViewModel.new);
