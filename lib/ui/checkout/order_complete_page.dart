import 'package:duex_lapins/app/app_routes.dart';
import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrderCompletePage extends ConsumerWidget {
  const OrderCompletePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                'ORDER  /  DL-20261006-1198',
                style: AppTypography.label(
                  fontSize: 8.5,
                  letterSpacing: 1.35,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 30),
              const Divider(height: 1),
              const SizedBox(height: 22),
              Text(
                '결제가 완료되면 주문 확인 메일이 발송됩니다. 배송 진행 상황은 마이페이지의 주문 내역에서 확인할 수 있습니다.',
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
