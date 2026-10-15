import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/core/network/shared_mock_api_client.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/core/utils/address_search.dart';
import 'package:deux_lapins/core/utils/price_formatter.dart';
import 'package:deux_lapins/ui/account/account_view_model.dart';
import 'package:deux_lapins/ui/cart/cart_view_model.dart';
import 'package:deux_lapins/ui/checkout/checkout_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkout = ref.watch(checkoutViewModelProvider);
    final account = ref.watch(accountViewModelProvider);
    final cart = ref.watch(cartViewModelProvider);
    final mobile = MediaQuery.sizeOf(context).width < 900;

    final direct = checkout.isDirectPurchase;
    final subtotal = direct
        ? checkout.directOptions.fold<int>(
      0,
          (sum, option) => sum + checkout.directProduct!.price * option.quantity,
    )
        : cart.subtotal;

    final shipping = direct
        ? (subtotal >= cart.freeShippingThreshold
        ? 0
        : cart.shippingFee)
        : cart.shipping;

    final total = subtotal + shipping;

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle(number: '01', title: '배송 정보'),
        const SizedBox(height: 20),
        if (account.loading)
          const LinearProgressIndicator(minHeight: 2),
        if (account.addresses.isNotEmpty) ...[
          DropdownButtonFormField<String>(
            value: account.addresses.any(
                  (item) => item.id == checkout.selectedAddressId,
            ) ? checkout.selectedAddressId : null,
            decoration: const InputDecoration(labelText: '저장된 배송지 선택'),
            hint: const Text('배송지를 선택해주세요'),
            items: account.addresses.map((item) => DropdownMenuItem<String>(
              value: item.id,
              child: Text(
                '${item.isDefault ? "[기본] " : ""}${item.recipientName} · ${item.address}',
                overflow: TextOverflow.ellipsis,
              ),
            )).toList(growable: false),
            onChanged: checkout.submitting ? null : (id) {
              if (id == null) return;
              for (final address in account.addresses) {
                if (address.id == id) {
                  ref.read(checkoutViewModelProvider.notifier)
                      .selectSavedAddress(address);
                  break;
                }
              }
            },
          ),
          const SizedBox(height: 20),
        ],
        _field('이름', checkout.name, ref.read(checkoutViewModelProvider.notifier).setName,
            key: ValueKey('recipient-${checkout.addressSearchRevision}')),
        const SizedBox(height: 16),
        _field('휴대폰 번호', checkout.phone, ref.read(checkoutViewModelProvider.notifier).setPhone,
            key: ValueKey('phone-${checkout.addressSearchRevision}')),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _field(
                '우편번호',
                checkout.postcode,
                ref.read(checkoutViewModelProvider.notifier).setPostcode,
                key: ValueKey('postcode-${checkout.addressSearchRevision}'),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () async {
                final result = await searchKoreanAddress(context);
                if (!context.mounted || result == null) return;

                ref.read(checkoutViewModelProvider.notifier).selectAddress(
                  result.postcode,
                  result.address,
                );
              },
              child: const Text('주소 찾기'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _field(
          '주소',
          checkout.address,
          ref.read(checkoutViewModelProvider.notifier).setAddress,
          key: ValueKey('address-${checkout.addressSearchRevision}'),
        ),
        const SizedBox(height: 16),
        _field('상세 주소', checkout.detailAddress, ref.read(checkoutViewModelProvider.notifier).setDetailAddress,
            key: ValueKey('detail-${checkout.addressSearchRevision}')),
        const SizedBox(height: 10),
        CheckboxListTile(
          value: checkout.saveAddress,
          onChanged: checkout.submitting
              ? null
              : (value) => ref
              .read(checkoutViewModelProvider.notifier)
              .toggleAddress(value ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            '기본 배송지로 저장',
            style: TextStyle(fontSize: 12),
          ),
        ),
        const Divider(height: 50),
        const _StepTitle(number: '02', title: '결제 수단'),
        const SizedBox(height: 14),
        ...['CARD', 'KAKAO PAY', 'NAVER PAY', 'BANK TRANSFER'].map(
          (payment) => RadioListTile<String>(
            value: payment,
            groupValue: checkout.payment,
            onChanged: (value) {
              if (value != null) {
                ref
                    .read(checkoutViewModelProvider.notifier)
                    .setPayment(value);
              }
            },
            contentPadding: EdgeInsets.zero,
            title: Text(
              _paymentLabel(payment),
              style: AppTypography.label(
                fontSize: 9.5,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
        if (kDebugMode && SharedMockApiClient.enabled)
          CheckboxListTile(
            value: checkout.simulatePaymentFailure,
            onChanged: checkout.submitting
                ? null
                : (value) => ref
                .read(checkoutViewModelProvider.notifier)
                .setPaymentFailure(value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Mock API 주문 실패 테스트'),
            subtitle: const Text('실패 응답 시 재고와 장바구니는 변경되지 않습니다.'),
          ),
        const Divider(height: 50),
        const _StepTitle(number: '03', title: '약관 동의'),
        const SizedBox(height: 10),
        CheckboxListTile(
          value: checkout.agreed,
          onChanged: (value) => ref
              .read(checkoutViewModelProvider.notifier)
              .toggleAgreement(value ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            '주문, 결제, 교환 및 반품 정책에 동의합니다.',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );

    final summary = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.line,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주문 상품',
            style: AppTypography.serif(
              fontSize: 28,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          if (direct)
            ...checkout.directOptions.map(
                  (option) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${checkout.directProduct!.name} / '
                            '${option.variant.color} / '
                            '${option.variant.size} × ${option.quantity}',
                        style: const TextStyle(fontSize: 11.5),
                      ),
                    ),
                    Text(
                      formatPrice(checkout.directProduct!.price * option.quantity),
                      style: const TextStyle(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            )
          else
            ...cart.items.map(
                  (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name} × ${item.quantity}',
                      style: const TextStyle(fontSize: 11.5),
                    ),
                  ),
                  Text(
                    formatPrice(item.total),
                    style: const TextStyle(fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          _summaryRow('상품 금액', formatPrice(subtotal)),
          const SizedBox(height: 10),
          _summaryRow(
            '배송비',
            shipping == 0 ? '무료' : formatPrice(shipping),
          ),
          const Divider(height: 28),
          _summaryRow('총 결제금액', formatPrice(total), bold: true),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: (!direct && cart.items.isEmpty) ||
                  !checkout.agreed ||
                  (!direct && (cart.loading || cart.saving)) ||
                  checkout.submitting
                  ? null
                  : () async {
                try {
                  await ref.read(checkoutViewModelProvider.notifier).submit();
                  if (!context.mounted) return;

                  final warning =
                      ref.read(checkoutViewModelProvider).errorMessage;
                  if (warning != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(warning)),
                    );
                  }

                  context.go(AppRoutePath.orderComplete);
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('주문 실패: $error')),
                  );
                }
              },
              child: Text(checkout.submitting
                  ? '주문 처리 중...'
                  : '${formatPrice(total)} 결제하기  →'),
            ),
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 16 : 34,
        mobile ? 24 : 34,
        mobile ? 16 : 34,
        76,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORDER  /  SECURE CHECKOUT',
            style: AppTypography.label(
              fontSize: 8.5,
              letterSpacing: 1.7,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Checkout',
            style: AppTypography.serif(
              fontSize: mobile ? 42 : 58,
              height: 0.95,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          const Divider(height: 1),
          const SizedBox(height: 28),
          if (mobile)
            Column(
              children: [
                form,
                const SizedBox(height: 34),
                summary,
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: form),
                const SizedBox(width: 52),
                Expanded(flex: 4, child: summary),
              ],
            ),
        ],
      ),
    );
  }

  static String _paymentLabel(String payment) {
    switch (payment) {
      case 'CARD':
        return '신용/체크카드';
      case 'BANK TRANSFER':
        return '계좌이체';
      default:
        return payment;
    }
  }

  static Widget _field(
      String label,
      String initial,
      ValueChanged<String> onChanged, {
        Key? key,
      }) {
    return TextFormField(
      key: key,
      initialValue: initial,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }

  static Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.number, required this.title});

  final String number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          number,
          style: AppTypography.label(
            fontSize: 8.5,
            letterSpacing: 1.3,
            color: AppTheme.muted,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTypography.label(
            fontSize: 10,
            letterSpacing: 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
