import 'package:duex_lapins/app/app_routes.dart';
import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:duex_lapins/core/utils/price_formatter.dart';
import 'package:duex_lapins/ui/cart/cart_view_model.dart';
import 'package:duex_lapins/ui/checkout/checkout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkout = ref.watch(checkoutViewModelProvider);
    final cart = ref.watch(cartViewModelProvider);
    final mobile = MediaQuery.sizeOf(context).width < 900;

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle(number: '01', title: '배송 정보'),
        const SizedBox(height: 20),
        _field('이름', checkout.name),
        const SizedBox(height: 16),
        _field('휴대폰 번호', checkout.phone),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _field('우편번호', checkout.postcode)),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () {},
              child: const Text('주소 찾기'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _field('주소', checkout.address),
        const SizedBox(height: 16),
        _field('상세 주소', checkout.detailAddress),
        const SizedBox(height: 10),
        CheckboxListTile(
          value: checkout.saveAddress,
          onChanged: (value) => ref
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
          _summaryRow('상품 금액', formatPrice(cart.subtotal)),
          const SizedBox(height: 10),
          _summaryRow(
            '배송비',
            cart.shipping == 0 ? '무료' : formatPrice(cart.shipping),
          ),
          const Divider(height: 28),
          _summaryRow('총 결제금액', formatPrice(cart.total), bold: true),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: cart.items.isEmpty || !checkout.agreed
                  ? null
                  : () {
                      ref.read(cartViewModelProvider.notifier).clear();
                      context.go(AppRoutePath.orderComplete);
                    },
              child: Text('${formatPrice(cart.total)} 결제하기  →'),
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

  static Widget _field(String label, String initial) {
    return TextFormField(
      initialValue: initial,
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
