import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/core/utils/price_formatter.dart';
import 'package:deux_lapins/core/utils/product_label_formatter.dart';
import 'package:deux_lapins/core/widgets/app_image.dart';
import 'package:deux_lapins/ui/cart/cart_view_model.dart';
import 'package:deux_lapins/ui/checkout/checkout_view_model.dart';
import 'package:deux_lapins/domain/models/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartViewModelProvider);
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 900;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 16 : 34,
        mobile ? 24 : 34,
        mobile ? 16 : 34,
        70,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SHOPPING  /  DUEX LAPINS',
            style: AppTypography.label(
              fontSize: 8.5,
              letterSpacing: 1.7,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Shopping Bag',
            style: AppTypography.serif(
              fontSize: mobile ? 42 : 58,
              height: 0.95,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          const Divider(height: 1),
          const SizedBox(height: 18),
          if (cart.loading) const LinearProgressIndicator(minHeight: 2),
          if (cart.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(cart.errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            ),
          if (cart.loading)
            const SizedBox(height: 40)
          else if (cart.items.isEmpty)
            _empty(context)
          else if (mobile)
            Column(
              children: [
                ...cart.items.map((item) => _item(context, ref, item, true)),
                const SizedBox(height: 30),
                _summary(
                  context,
                  ref,
                  cart.subtotal,
                  cart.shipping,
                  cart.total,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    children: cart.items
                        .map((item) => _item(context, ref, item, false))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 52),
                Expanded(
                  flex: 4,
                  child: _summary(
                    context,
                    ref,
                    cart.subtotal,
                    cart.shipping,
                    cart.total,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 96),
      child: Center(
        child: Column(
          children: [
            Text(
              '장바구니가 비어 있습니다.',
              style: AppTypography.serif(
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '현재 컬렉션에서 마음에 드는 상품을 담아보세요.',
              style: AppTypography.body(
                fontSize: 12,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.go(AppRoutePath.newItems),
              child: const Text('쇼핑 계속하기  →'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeItem(
      BuildContext context,
      WidgetRef ref,
      String variantId, [
        int? quantity,
      ]) async {
    try {
      final notifier = ref.read(cartViewModelProvider.notifier);
      if (quantity == null) {
        await notifier.remove(variantId);
      } else {
        await notifier.updateQuantity(variantId, quantity);
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('장바구니 변경 실패: $error')),
      );
    }
  }

  Widget _item(BuildContext context, WidgetRef ref, CartItem item, bool mobile) {
    final saving = ref.watch(cartViewModelProvider.select((value) => value.saving));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.line),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: mobile ? 106 : 142,
            child: AppImage(
              url: item.product.imageUrl,
              aspectRatio: 0.76,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.brand,
                  style: AppTypography.label(
                    fontSize: 8.5,
                    letterSpacing: 1.4,
                    color: AppTheme.muted,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  item.product.name.toUpperCase(),
                  style: AppTypography.serif(
                    fontSize: mobile ? 18 : 22,
                    height: 0.98,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  '${formatProductColor(item.color)}  /  ${item.size}',
                  style: AppTypography.label(
                    fontSize: 8.5,
                    letterSpacing: 0.9,
                    color: AppTheme.muted,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: saving
                          ? null
                          : () => _changeItem(
                          context, ref, item.productVariantId, item.quantity - 1),
                      icon: const Icon(Icons.remove, size: 15),
                    ),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: saving
                          ? null
                          : () => _changeItem(
                          context, ref, item.productVariantId, item.quantity + 1),
                      icon: const Icon(Icons.add, size: 15),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: saving
                          ? null
                          : () => _changeItem(context, ref, item.productVariantId),
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!mobile) ...[
            const SizedBox(width: 16),
            Text(
              formatPrice(item.total),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summary(
      BuildContext context,
      WidgetRef ref,
      int subtotal,
    int shipping,
    int total,
  ) {
    return Container(
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
            '주문 요약',
            style: AppTypography.serif(
              fontSize: 28,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          _row('상품 금액', formatPrice(subtotal)),
          const SizedBox(height: 11),
          _row(
            '배송비',
            shipping == 0 ? '무료' : formatPrice(shipping),
          ),
          const Divider(height: 32),
          _row('총 결제금액', formatPrice(total), bold: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                ref
                    .read(checkoutViewModelProvider.notifier)
                    .startCartPurchase();

                context.go(AppRoutePath.checkout);
              },
              child: const Text('주문하기  →'),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '20만원 이상 구매 시 무료배송됩니다.',
            style: AppTypography.body(
              fontSize: 10.5,
              color: AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
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
