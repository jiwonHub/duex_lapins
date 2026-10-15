import 'package:deux_lapins/core/di/providers.dart';
import 'package:deux_lapins/core/network/shared_mock_api_client.dart';
import 'package:deux_lapins/domain/models/cart_item.dart';
import 'package:deux_lapins/domain/models/product.dart';
import 'package:deux_lapins/domain/models/selected_product_option.dart';
import 'package:deux_lapins/ui/auth/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartState {
  const CartState({
    this.items = const [],
    this.loading = false,
    this.saving = false,
    this.errorMessage,
    this.shippingFee = 3000,
    this.freeShippingThreshold = 200000,
  });

  final int shippingFee;
  final int freeShippingThreshold;
  final List<CartItem> items;
  final bool loading;
  final bool saving;
  final String? errorMessage;

  CartState copyWith({
    List<CartItem>? items,
    bool? loading,
    bool? saving,
    String? errorMessage,
    int? shippingFee,
    int? freeShippingThreshold,
    bool clearError = false,
  }) => CartState(
    items: items ?? this.items,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    shippingFee: shippingFee ?? this.shippingFee,
    freeShippingThreshold:
    freeShippingThreshold ?? this.freeShippingThreshold,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  int get subtotal => items.fold(0, (sum, item) => sum + item.total);
  int get shipping =>
      subtotal == 0 || subtotal >= freeShippingThreshold
          ? 0
          : shippingFee;
  int get total => subtotal + shipping;
  int get count => items.fold(0, (sum, item) => sum + item.quantity);
}

class CartViewModel extends Notifier<CartState> {
  @override
  CartState build() {
    ref.watch(
      authViewModelProvider.select((auth) => auth.user?.id),
    );

    Future<void>.microtask(refresh);

    return const CartState(loading: true);
  }

  Future<void> refresh() async {
    if (state.saving) return;

    final userId = ref.read(authViewModelProvider).user?.id;

    state = state.copyWith(
      loading: true,
      clearError: true,
    );

    try {
      final items = await ref.read(cartRepositoryProvider).getItems();

      var shippingFee = state.shippingFee;
      var freeShippingThreshold = state.freeShippingThreshold;

      if (SharedMockApiClient.enabled) {
        final response = await SharedMockApiClient.instance.request(
          'GET',
          '/public/store-settings',
        );

        if (response['success'] != true) {
          final error = response['error'] as Map<String, dynamic>?;

          throw StateError(
            error?['message']?.toString() ??
                '배송비 설정을 조회하지 못했습니다.',
          );
        }

        final settings = response['data'] as Map<String, dynamic>;

        shippingFee = settings['shipping_fee'] as int;
        freeShippingThreshold =
        settings['free_shipping_threshold'] as int;
      }

      if (ref.read(authViewModelProvider).user?.id != userId) {
        return;
      }

      state = state.copyWith(
        items: items,
        shippingFee: shippingFee,
        freeShippingThreshold: freeShippingThreshold,
        loading: false,
      );
    } catch (error) {
      if (ref.read(authViewModelProvider).user?.id != userId) {
        return;
      }

      state = state.copyWith(
        loading: false,
        errorMessage: '$error',
      );
    }
  }

  Future<void> _mutate(Future<List<CartItem>> Function() request) async {
    if (state.saving || state.loading) {
      throw StateError('다른 장바구니 요청이 진행 중입니다.');
    }
    state = state.copyWith(saving: true, clearError: true);
    try {
      final items = await request();
      state = state.copyWith(items: items, saving: false);
    } catch (error) {
      state = state.copyWith(saving: false, errorMessage: '$error');
      rethrow;
    }
  }

  Future<void> add(Product product, String size, String color) =>
      _mutate(() => ref.read(cartRepositoryProvider).add(product, size, color));

  Future<void> addOptions(List<SelectedProductOption> options) =>
      _mutate(() => ref.read(cartRepositoryProvider).addOptions(options));

  Future<void> updateQuantity(String productVariantId, int quantity) =>
      _mutate(() => ref.read(cartRepositoryProvider)
          .updateQuantity(productVariantId, quantity));

  Future<void> remove(String productVariantId) =>
      _mutate(() => ref.read(cartRepositoryProvider).remove(productVariantId));

  Future<void> clear() =>
      _mutate(() => ref.read(cartRepositoryProvider).clear());
}

final cartViewModelProvider =
    NotifierProvider<CartViewModel, CartState>(CartViewModel.new);
