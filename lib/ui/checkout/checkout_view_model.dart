import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutState {
  const CheckoutState({
    this.name = '최지원',
    this.phone = '010-0000-0000',
    this.postcode = '00000',
    this.address = '서울특별시 성동구 성수이로 00',
    this.detailAddress = '000동 000호',
    this.payment = 'CARD',
    this.saveAddress = true,
    this.agreed = false,
  });

  final String name;
  final String phone;
  final String postcode;
  final String address;
  final String detailAddress;
  final String payment;
  final bool saveAddress;
  final bool agreed;

  CheckoutState copyWith({
    String? name,
    String? phone,
    String? postcode,
    String? address,
    String? detailAddress,
    String? payment,
    bool? saveAddress,
    bool? agreed,
  }) {
    return CheckoutState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      postcode: postcode ?? this.postcode,
      address: address ?? this.address,
      detailAddress: detailAddress ?? this.detailAddress,
      payment: payment ?? this.payment,
      saveAddress: saveAddress ?? this.saveAddress,
      agreed: agreed ?? this.agreed,
    );
  }
}

class CheckoutViewModel extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  void setPayment(String value) => state = state.copyWith(payment: value);
  void toggleAddress(bool value) => state = state.copyWith(saveAddress: value);
  void toggleAgreement(bool value) => state = state.copyWith(agreed: value);
}

final checkoutViewModelProvider =
    NotifierProvider<CheckoutViewModel, CheckoutState>(CheckoutViewModel.new);
