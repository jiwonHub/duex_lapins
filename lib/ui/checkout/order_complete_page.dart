import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/utils/price_formatter.dart';
import 'package:deux_lapins/ui/checkout/checkout_view_model.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrderCompletePage extends ConsumerWidget {
  const OrderCompletePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(checkoutViewModelProvider).lastOrder;
    if (order == null) {
      return Center(child: TextButton(
        onPressed: () => context.go(AppRoutePath.orders),
        child: const Text('확인할 주문이 없습니다. 주문 내역 보기'),
      ));
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            children: [
              const Icon(Icons.check, size: 34),
              const SizedBox(height: 24),
              Text(
                'Order Complete',
                style: AppTypography.serif(
                  fontSize: 48,
                  height: 0.95,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '주문해주셔서 감사합니다.',
                style: AppTypography.body(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                'ORDER  /  ${order.id}',
                style: AppTypography.label(
                  fontSize: 8.5,
                  letterSpacing: 1.35,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 12),
              Text('결제 완료 · ${formatPrice(order.total)}',
                  style: AppTypography.body(fontSize: 12)),
              const SizedBox(height: 12),
              Text('${order.recipientName} · ${order.address} ${order.detailAddress}',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(fontSize: 12)),
              const SizedBox(height: 30),
              const Divider(height: 1),
              const SizedBox(height: 22),
              Text(
                'Mock 결제가 완료되었습니다. 실제 결제나 이메일 발송은 수행하지 않았습니다. 주문 내역에서 테스트 주문을 확인할 수 있습니다.',
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  fontSize: 12,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => context.go(AppRoutePath.orders),
                    child: const Text('주문 내역 보기'),
                  ),
                  FilledButton(
                    onPressed: () => context.go(AppRoutePath.home),
                    child: const Text('쇼핑 계속하기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
