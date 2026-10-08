import 'package:duex_lapins/app/app_routes.dart';
import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:duex_lapins/core/utils/price_formatter.dart';
import 'package:duex_lapins/core/widgets/app_image.dart';
import 'package:duex_lapins/domain/models/order.dart';
import 'package:duex_lapins/ui/account/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(accountViewModelProvider).orders;
    Order? order;

    for (final item in orders) {
      if (item.id == orderId) {
        order = item;
      }
    }

    order ??= orders.isEmpty ? null : orders.first;

    if (order == null) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 1.2),
      );
    }

    final mobile = MediaQuery.sizeOf(context).width < 720;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 16 : 40,
        mobile ? 24 : 34,
        mobile ? 16 : 40,
        76,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutePath.orders);
                }
              },
              icon: const Icon(Icons.arrow_back, size: 15),
              label: const Text('주문 목록'),
            ),
            const SizedBox(height: 14),
            Text(
              'ORDER  /  ${order.id}',
              style: AppTypography.label(
                fontSize: 8.5,
                letterSpacing: 1.6,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Order Detail',
              style: AppTypography.serif(
                fontSize: mobile ? 38 : 50,
                height: 0.96,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              '${order.date}  ·  ${order.status}',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: AppImage(
                    url: order.imageUrl,
                    aspectRatio: 0.78,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.itemName.toUpperCase(),
                        style: AppTypography.serif(
                          fontSize: 24,
                          height: 1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '상품 ${order.itemCount}개',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formatPrice(order.total),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 48),
            Text(
              '배송 정보',
              style: AppTypography.label(
                fontSize: 9,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text('최지원 · 010-0000-0000'),
            const SizedBox(height: 6),
            const Text(
              '서울특별시 성동구 성수이로 00, 000동 000호',
              style: TextStyle(color: AppTheme.muted),
            ),
            const Divider(height: 48),
            Text(
              '결제 정보',
              style: AppTypography.label(
                fontSize: 9,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text('신용/체크카드'),
            const SizedBox(height: 6),
            Text(
              formatPrice(order.total),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
