import 'package:deux_lapins/core/di/providers.dart';
import 'package:deux_lapins/domain/models/member_profile.dart';
import 'package:deux_lapins/domain/models/order.dart';
import 'package:deux_lapins/domain/models/product.dart';
import 'package:deux_lapins/domain/models/selected_product_option.dart';
import 'package:deux_lapins/ui/account/account_view_model.dart';
import 'package:deux_lapins/ui/account/orders_view_model.dart';
import 'package:deux_lapins/ui/auth/auth_view_model.dart';
import 'package:deux_lapins/ui/cart/cart_view_model.dart';
import 'package:deux_lapins/ui/catalog/catalog_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutState {
  const CheckoutState({
    this.name = '',
    this.phone = '',
    this.postcode = '',
    this.address = '',
    this.addressSearchRevision = 0,
    this.detailAddress = '',
    this.payment = 'CARD',
    this.saveAddress = false,
    this.selectedAddressId,
    this.agreed = false,
    this.simulatePaymentFailure = false,
    this.submitting = false,
    this.errorMessage,
    this.lastOrder,
    this.directProduct,
    this.directVariant,
    this.directOptions = const [],
  });

  final String name;
  final String phone;
  final String postcode;
  final String address;
  final int addressSearchRevision;
  final String detailAddress;
  final String payment;
  final bool saveAddress;
  final String? selectedAddressId;
  final bool agreed;
  final bool simulatePaymentFailure;
  final bool submitting;
  final String? errorMessage;
  final Order? lastOrder;
  final Product? directProduct;
  final ProductVariant? directVariant;
  final List<SelectedProductOption> directOptions;

  bool get isDirectPurchase =>
      directProduct != null && directOptions.isNotEmpty;

  CheckoutState copyWith({
    String? name,
    String? phone,
    String? postcode,
    String? address,
    int? addressSearchRevision,
    String? detailAddress,
    String? payment,
    bool? saveAddress,
    String? selectedAddressId,
    bool clearSelectedAddress = false,
    bool? agreed,
    bool? simulatePaymentFailure,
    bool? submitting,
    String? errorMessage,
    Order? lastOrder,
    Product? directProduct,
    ProductVariant? directVariant,
    List<SelectedProductOption>? directOptions,
    bool clearDirectPurchase = false,
    bool clearError = false,
  }) => CheckoutState(
    name: name ?? this.name,
    phone: phone ?? this.phone,
    postcode: postcode ?? this.postcode,
    address: address ?? this.address,
    addressSearchRevision:
    addressSearchRevision ?? this.addressSearchRevision,
    detailAddress: detailAddress ?? this.detailAddress,
    payment: payment ?? this.payment,
    saveAddress: saveAddress ?? this.saveAddress,
    selectedAddressId: clearSelectedAddress ? null :
    selectedAddressId ?? this.selectedAddressId,
    agreed: agreed ?? this.agreed,
    simulatePaymentFailure: simulatePaymentFailure ?? this.simulatePaymentFailure,
    submitting: submitting ?? this.submitting,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    lastOrder: lastOrder ?? this.lastOrder,
    directProduct:
    clearDirectPurchase ? null : directProduct ?? this.directProduct,
    directVariant:
    clearDirectPurchase ? null : directVariant ?? this.directVariant,
    directOptions:
    clearDirectPurchase ? const [] : directOptions ?? this.directOptions,
  );
}

class CheckoutViewModel extends Notifier<CheckoutState> {
  int _sequence = 0;
  String? _requestId;
  bool _deliveryEdited = false;

  @override
  CheckoutState build() {
    // 로그인 계정 변경 시 이전 회원의 배송정보가 남지 않도록 상태를 초기화한다.
    ref.watch(authViewModelProvider.select((value) => value.user?.id));
    _deliveryEdited = false;
    _requestId = null;
    ref.listen<AccountState>(accountViewModelProvider, (previous, next) {
      if (!next.loading && next.defaultAddress != null && !_deliveryEdited) {
        selectSavedAddress(next.defaultAddress!, userSelected: false);
      }
    });
    final initial = ref.read(accountViewModelProvider).defaultAddress;
    return initial == null
        ? const CheckoutState()
        : CheckoutState(
      name: initial.recipientName,
      phone: initial.phone,
      postcode: initial.postcode,
      address: initial.address,
      detailAddress: initial.detailAddress,
      selectedAddressId: initial.id,
    );
  }

  void selectSavedAddress(DeliveryAddress address, {bool userSelected = true}) {
    if (userSelected) _deliveryEdited = true;
    state = state.copyWith(
      name: address.recipientName,
      phone: address.phone,
      postcode: address.postcode,
      address: address.address,
      detailAddress: address.detailAddress,
      selectedAddressId: address.id,
      addressSearchRevision: state.addressSearchRevision + 1,
    );
  }

  void _markDeliveryEdited() => _deliveryEdited = true;

  void startDirectPurchase(Product product, ProductVariant variant) {
    startDirectPurchaseOptions(
      product,
      [SelectedProductOption(variant: variant, quantity: 1)],
    );
  }

  void startDirectPurchaseOptions(
      Product product,
      List<SelectedProductOption> options,
      ) {
    if (options.isEmpty || options.any((option) => option.quantity <= 0 ||
        option.variant.isSoldOut || option.quantity > option.variant.stockQuantity)) {
      throw StateError('구매할 옵션과 재고를 확인해주세요.');
    }
    _requestId = null;
    state = state.copyWith(
      directProduct: product,
      directVariant: options.first.variant,
      directOptions: List.unmodifiable(options),
      clearError: true,
    );
  }

  void startCartPurchase() {
    _requestId = null;

    state = state.copyWith(
      clearDirectPurchase: true,
      clearError: true,
    );
  }

  void setName(String value) {
    _markDeliveryEdited();
    state = state.copyWith(name: value, clearSelectedAddress: true);
  }
  void setPhone(String value) {
    _markDeliveryEdited();
    state = state.copyWith(phone: value, clearSelectedAddress: true);
  }
  void setPostcode(String value) {
    _markDeliveryEdited();
    state = state.copyWith(postcode: value, clearSelectedAddress: true);
  }
  void setAddress(String value) {
    _markDeliveryEdited();
    state = state.copyWith(address: value, clearSelectedAddress: true);
  }

  void selectAddress(String postcode, String address) {
    _markDeliveryEdited();
    state = state.copyWith(
      postcode: postcode,
      address: address,
      clearSelectedAddress: true,
      addressSearchRevision: state.addressSearchRevision + 1,
    );
  }

  void setDetailAddress(String value) {
    _markDeliveryEdited();
    state = state.copyWith(detailAddress: value, clearSelectedAddress: true);
  }
  void setPayment(String value) => state = state.copyWith(payment: value);
  void toggleAddress(bool value) => state = state.copyWith(saveAddress: value);
  void toggleAgreement(bool value) => state = state.copyWith(agreed: value);
  void setPaymentFailure(bool value) =>
      state = state.copyWith(simulatePaymentFailure: value);

  Future<Order> submit() async {
    if (state.submitting) throw StateError('주문 처리 중입니다.');
    final user = ref.read(authViewModelProvider).user;
    if (user == null) throw StateError('주문하려면 로그인이 필요합니다.');
    final userId = user.id;
    if (!state.agreed) throw StateError('주문 약관에 동의해주세요.');
    final cart = ref.read(cartViewModelProvider);
    if (state.isDirectPurchase) {
      if (state.directOptions.any((option) => option.variant.isSoldOut ||
          option.quantity > option.variant.stockQuantity)) {
        throw StateError('선택한 상품 옵션의 재고가 부족합니다.');
      }
    } else if (cart.loading || cart.saving || cart.items.isEmpty) {
      throw StateError('장바구니 상품을 확인해주세요.');
    }
    _requestId ??= '${DateTime.now().microsecondsSinceEpoch}-${++_sequence}';
    state = state.copyWith(submitting: true, clearError: true);
    try {
      final method = switch (state.payment) {
        'CARD' => 'card',
        'KAKAO PAY' => 'kakao_pay',
        'NAVER PAY' => 'naver_pay',
        'BANK TRANSFER' => 'bank_transfer',
        _ => '',
      };
      final order = await ref.read(orderRepositoryProvider).placeOrder({
        'request_id': _requestId,
        'user_id': userId,
        'recipient_name': state.name,
        'recipient_phone': state.phone,
        'postcode': state.postcode,
        'address': state.address,
        'detail_address': state.detailAddress,
        'payment_method': method,
        'simulate_payment_failure': state.simulatePaymentFailure,
        if (state.isDirectPurchase)
          'items': state.directOptions.map((option) => {
            'product_variant_id': option.variantId,
            'quantity': option.quantity,
          }).toList(growable: false),
      });
      _requestId = null;
      String? addressSaveError;

      if (state.saveAddress) {
        try {
          final repository = ref.read(accountRepositoryProvider);
          final profile = await repository.getProfile(user);
          final addresses = await repository.getAddresses(profile.id);

          String existingId = '';
          for (final item in addresses) {
            if (item.recipientName == order.recipientName &&
                item.phone == order.recipientPhone &&
                item.postcode == order.postcode &&
                item.address == order.address &&
                item.detailAddress == order.detailAddress) {
              existingId = item.id;
              break;
            }
          }

          await repository.saveAddress(
            DeliveryAddress(
              id: existingId,
              userId: profile.id,
              recipientName: order.recipientName,
              phone: order.recipientPhone,
              postcode: order.postcode,
              address: order.address,
              detailAddress: order.detailAddress,
              isDefault: true,
            ),
          );
        } catch (error) {
          addressSaveError = '주문은 완료됐지만 기본 배송지 저장에 실패했습니다: $error';
          debugPrint('[CHECKOUT] $addressSaveError');
        }
      }

      state = state.copyWith(
        submitting: false,
        lastOrder: order,
        saveAddress: false,
        clearDirectPurchase: true,
        errorMessage: addressSaveError,
        clearError: addressSaveError == null,
      );

      ref.invalidate(ordersViewModelProvider);
      ref.invalidate(accountViewModelProvider);
      ref.invalidate(catalogViewModelProvider);

      try {
        await ref.read(cartViewModelProvider.notifier).refresh();
      } catch (error) {
        debugPrint('[CHECKOUT] 결제 완료 후 장바구니 갱신 실패: $error');
      }

      return order;
    } catch (error) {
      state = state.copyWith(submitting: false, errorMessage: '$error');
      rethrow;
    }
  }
}

final checkoutViewModelProvider =
    NotifierProvider<CheckoutViewModel, CheckoutState>(CheckoutViewModel.new);
