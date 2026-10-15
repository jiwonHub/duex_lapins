import 'package:deux_lapins/core/di/providers.dart';
import 'package:deux_lapins/domain/models/member_profile.dart';
import 'package:deux_lapins/domain/models/order.dart';
import 'package:deux_lapins/ui/auth/auth_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountState {
  const AccountState({
    this.orders = const [],
    this.addresses = const [],
    this.loading = true,
    this.saving = false,
    this.memberId,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.errorMessage,
  });

  final List<Order> orders;
  final List<DeliveryAddress> addresses;
  final bool loading;
  final bool saving;
  final String? memberId;
  final String name;
  final String email;
  final String phone;
  final String? errorMessage;

  DeliveryAddress? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return null;
  }

  AccountState copyWith({
    List<Order>? orders,
    List<DeliveryAddress>? addresses,
    bool? loading,
    bool? saving,
    String? memberId,
    String? name,
    String? email,
    String? phone,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AccountState(
      orders: orders ?? this.orders,
      addresses: addresses ?? this.addresses,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      memberId: memberId ?? this.memberId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AccountViewModel extends Notifier<AccountState> {
  @override
  AccountState build() {
    final user = ref.watch(authViewModelProvider.select((value) => value.user));
    if (user != null) {
      Future<void>.microtask(_load);
    }
    return AccountState(loading: user != null);
  }

  Future<void> _load() async {
    final user = ref.read(authViewModelProvider).user;
    if (user == null) return;
    try {
      final repository = ref.read(accountRepositoryProvider);
      final profile = await repository.getProfile(user);

      if (kDebugMode) {
        debugPrint('========== [PROFILE API RESULT] ==========');
        debugPrint('kakaoUserId: ${user.id}');
        debugPrint('kakaoEmail: ${user.email}');
        debugPrint('memberId: ${profile.id}');
        debugPrint('name: ${profile.name}');
        debugPrint('email: ${profile.email}');
        debugPrint('phone: ${profile.phone}');
        debugPrint('==========================================');
      }

      final addresses = await repository.getAddresses(profile.id);
      final orders = await repository.getOrders(user.id);
      if (ref.read(authViewModelProvider).user?.id != user.id) return;
      state = state.copyWith(
        orders: orders,
        addresses: addresses,
        memberId: profile.id,
        name: profile.name,
        email: profile.email,
        phone: profile.phone,
        loading: false,
        clearError: true,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PROFILE API ERROR] $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      if (ref.read(authViewModelProvider).user?.id != user.id) return;
      state = state.copyWith(loading: false, errorMessage: '$error');
    }
  }

  Future<void> refresh() async {
    if (state.saving) return;
    state = state.copyWith(loading: true, clearError: true);
    await _load();
  }

  Future<void> _mutate(Future<void> Function() action) async {
    if (state.loading || state.saving || state.memberId == null) {
      throw StateError('회원정보를 불러오는 중이거나 요청이 진행 중입니다.');
    }
    state = state.copyWith(saving: true, clearError: true);
    try {
      await action();
      state = state.copyWith(saving: false);
    } catch (error) {
      state = state.copyWith(saving: false, errorMessage: '$error');
      rethrow;
    }
  }

  Future<void> updateProfile(String name, String email, String phone) =>
      _mutate(() async {
        final profile = await ref.read(accountRepositoryProvider).updateProfile(
          MemberProfile(
            id: state.memberId!,
            name: name.trim(),
            email: email.trim(),
            phone: phone.trim(),
          ),
        );
        state = state.copyWith(
          name: profile.name, email: profile.email, phone: profile.phone,
        );
      });

  Future<void> saveAddress(DeliveryAddress address) => _mutate(() async {
    final repository = ref.read(accountRepositoryProvider);
    await repository.saveAddress(address);
    final addresses = await repository.getAddresses(state.memberId!);
    state = state.copyWith(addresses: addresses);
  });

  Future<void> deleteAddress(String addressId) => _mutate(() async {
    final repository = ref.read(accountRepositoryProvider);
    await repository.deleteAddress(state.memberId!, addressId);
    final addresses = await repository.getAddresses(state.memberId!);
    state = state.copyWith(addresses: addresses);
  });

  Future<void> setDefaultAddress(String addressId) => _mutate(() async {
    final repository = ref.read(accountRepositoryProvider);
    await repository.setDefaultAddress(state.memberId!, addressId);
    final addresses = await repository.getAddresses(state.memberId!);
    state = state.copyWith(addresses: addresses);
  });
}

final accountViewModelProvider =
    NotifierProvider<AccountViewModel, AccountState>(AccountViewModel.new);
