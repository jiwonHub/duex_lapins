import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/core/utils/price_formatter.dart';
import 'package:deux_lapins/core/widgets/app_image.dart';
import 'package:deux_lapins/domain/models/order.dart';
import 'package:deux_lapins/ui/account/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

String orderDeliveryLabel(Order order) {
  final delivery = order.deliveryStatus.toLowerCase();
  final status = order.status.toLowerCase();
  final payment = order.paymentStatus.toLowerCase();

  if (const {'cancelled', 'canceled', 'returned', 'refunded', 'exchangereturn'}
      .contains(delivery) ||
      const {'cancelled', 'canceled', 'returned', 'refunded', 'exchangereturn'}
          .contains(status) ||
      payment == 'refunded') {
    return '취소/반품';
  }
  if (delivery == 'delivered' || status == 'delivered') {
    return '배송 완료';
  }
  if (delivery == 'shipped' || status == 'shipped') {
    return '배송 중';
  }
  if (delivery == 'preparing' ||
      status == 'paid' ||
      status == 'preparing' ||
      status == 'payment_completed' ||
      payment == 'paid') {
    return '상품 준비';
  }
  return '상태 확인';
}

class AccountOrdersOverview extends ConsumerWidget {
  const AccountOrdersOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountViewModelProvider);
    final orders = account.orders;
    final counts = <String, int>{
      '상품 준비': 0,
      '배송 중': 0,
      '배송 완료': 0,
      '취소/반품': 0,
      '상태 확인': 0,
    };

    for (final order in orders) {
      final label = orderDeliveryLabel(order);
      counts[label] = (counts[label] ?? 0) + 1;
    }

    final stats = <(String, int)>[
      ('전체 주문', orders.length),
      ('상품 준비', counts['상품 준비']!),
      ('배송 중', counts['배송 중']!),
      ('배송 완료', counts['배송 완료']!),
      ('취소/반품', counts['취소/반품']!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '주문 · 배송 현황',
                style: AppTypography.serif(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              tooltip: '주문내역 새로고침',
              onPressed: account.loading
                  ? null
                  : () => ref.read(accountViewModelProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 10.0;
            final columns = constraints.maxWidth >= 1000
                ? 5
                : constraints.maxWidth >= 620
                ? 3
                : constraints.maxWidth >= 360
                ? 2
                : 1;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final (label, count) in stats)
                  SizedBox(
                    width: width,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: AppTypography.body(
                              fontSize: 11,
                              color: AppTheme.muted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            account.loading || account.errorMessage != null
                                ? '—'
                                : '$count건',
                            style: AppTypography.serif(
                              fontSize: 27,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        if (!account.loading && counts['상태 확인']! > 0) ...[
          const SizedBox(height: 8),
          Text(
            '상태 확인이 필요한 주문 ${counts['상태 확인']}건',
            style: AppTypography.body(
              fontSize: 11,
              color: AppTheme.muted,
            ),
          ),
        ],
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: Text(
                '최근 주문 내역',
                style: AppTypography.serif(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutePath.orders),
              child: const Text('전체 주문 보기 →'),
            ),
          ],
        ),
        const Divider(height: 14),
        if (account.loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 1.2)),
          )
        else if (account.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text('주문 조회 실패: ${account.errorMessage}'),
          )
        else if (orders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('아직 주문 내역이 없습니다.'),
            )
          else ...[
              for (final order in orders.take(6))
                _OrderPreviewRow(order: order),
              if (orders.length > 6)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go(AppRoutePath.orders),
                    child: Text('나머지 ${orders.length - 6}건 더 보기 →'),
                  ),
                ),
            ],
      ],
    );
  }
}

class _OrderPreviewRow extends StatelessWidget {
  const _OrderPreviewRow({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 650;
    final first = order.items.isEmpty ? null : order.items.first;
    final otherCount = order.items.length - 1;
    final title = otherCount > 0
        ? '${order.itemName} 외 $otherCount종'
        : order.itemName;
    final option = first == null
        ? ''
        : [first.color, first.size]
        .where((value) => value.trim().isNotEmpty)
        .join(' / ');

    return InkWell(
      onTap: () => context.push(AppRoutePath.orderDetail(order.id)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.line)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: mobile ? 76 : 94,
              child: AppImage(
                url: first?.imageUrl.isNotEmpty == true
                    ? first!.imageUrl
                    : order.imageUrl,
                aspectRatio: 0.78,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderDeliveryLabel(order),
                    style: AppTypography.label(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.serif(
                      fontSize: mobile ? 17 : 21,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (option.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      '$option · ${order.itemCount}개',
                      style: AppTypography.body(
                        fontSize: 11,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    '${order.date} · 주문번호 ${order.id}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      fontSize: 10,
                      color: AppTheme.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatPrice(order.total),
                    style: AppTypography.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }
}