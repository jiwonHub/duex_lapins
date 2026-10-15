import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/core/utils/price_formatter.dart';
import 'package:deux_lapins/core/widgets/app_image.dart';
import 'package:deux_lapins/ui/account/account_view_model.dart';
import 'package:deux_lapins/ui/account/account_orders_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountViewModelProvider);
    final mobile = MediaQuery.sizeOf(context).width < 720;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 16 : 40,
        mobile ? 26 : 36,
        mobile ? 16 : 40,
        76,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACCOUNT  /  ORDER HISTORY',
            style: AppTypography.label(
              fontSize: 8.5,
              letterSpacing: 1.7,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders',
            style: AppTypography.serif(
              fontSize: mobile ? 42 : 58,
              height: 0.95,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          const Divider(height: 1),
          if (state.loading)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: CircularProgressIndicator(strokeWidth: 1.2),
            )
          else if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text('주문내역 조회 실패: ${state.errorMessage}'),
            )
          else if (state.orders.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text('아직 주문내역이 없습니다.'),
              )
            else
              ...state.orders.map(
              (order) => InkWell(
                onTap: () => context.push(AppRoutePath.orderDetail(order.id)),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.line),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: mobile ? 86 : 110,
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
                              orderDeliveryLabel(order),
                              style: AppTypography.label(
                                fontSize: 8.5,
                                letterSpacing: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              order.itemName.toUpperCase(),
                              style: AppTypography.serif(
                                fontSize: 21,
                                height: 1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '상품 ${order.itemCount}개  ·  ${order.date}',
                              style: AppTypography.body(
                                fontSize: 11,
                                color: AppTheme.muted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatPrice(order.total),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Text('→'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
