import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/core/di/providers.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/core/utils/price_formatter.dart';
import 'package:deux_lapins/core/widgets/app_image.dart';
import 'package:deux_lapins/domain/models/order.dart';
import 'package:deux_lapins/ui/account/account_view_model.dart';
import 'package:deux_lapins/ui/account/order_claim_section.dart';
import 'package:deux_lapins/ui/auth/auth_view_model.dart';
import 'package:deux_lapins/ui/account/account_orders_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String? orderId;

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    // 상세 화면에 다시 들어왔을 때 관리자 운송장 등록 내역을 새로 받는다.
    Future<void>.microtask(() {
      if (mounted) ref.read(accountViewModelProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
    final account = ref.watch(accountViewModelProvider);
    Order? order;

    for (final item in account.orders) {
      if (item.id == orderId) {
        order = item;
        break;
      }
    }

    if (order == null) {
      if (account.loading) {
        return const Center(
          child: CircularProgressIndicator(strokeWidth: 1.2),
        );
      }
      return Center(
        child: Text(account.errorMessage ?? '해당 주문을 찾을 수 없습니다.'),
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
              '${order.date}  ·  ${orderDeliveryLabel(order)}',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 20),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: mobile ? 86 : 110,
                      child: AppImage(
                        url: item.imageUrl.isEmpty
                            ? order.imageUrl
                            : item.imageUrl,
                        aspectRatio: 0.78,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppTypography.serif(
                              fontSize: mobile ? 19 : 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${item.color} / ${item.size} · ${item.quantity}개',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.muted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            formatPrice(item.total),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '택배사: ${item.carrier.isEmpty ? "미등록" : item.carrier}',
                          ),
                          Text(
                            '운송장번호: ${item.trackingNumber.isEmpty ? "미등록" : item.trackingNumber}',
                          ),
                          if (item.trackingNumber.isNotEmpty)
                            _ItemTrackingStatus(
                              orderId: order.id,
                              item: item,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 48),
            OrderClaimSection(order: order),
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
            Text('${order.recipientName} · ${order.recipientPhone}'),
            const SizedBox(height: 6),
            Text(
              '(${order.postcode}) ${order.address} ${order.detailAddress}'.trim(),
              style: const TextStyle(color: AppTheme.muted),
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
            Text(
              switch (order.paymentMethod) {
                'card' => '신용/체크카드',
                'kakao_pay' => '카카오페이',
                'naver_pay' => '네이버페이',
                'bank_transfer' => '계좌이체',
                _ => '결제수단 확인',
              },
            ),
            const SizedBox(height: 8),
            Text('상품 금액 · ${formatPrice(order.productAmount)}'),
            const SizedBox(height: 6),
            Text('배송비 · ${formatPrice(order.shippingFee)}'),
            const SizedBox(height: 10),
            Text(
              '총 결제금액 · ${formatPrice(order.total)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemTrackingStatus extends ConsumerStatefulWidget {
  const _ItemTrackingStatus({
    required this.orderId,
    required this.item,
  });

  final String orderId;
  final OrderItem item;

  @override
  ConsumerState<_ItemTrackingStatus> createState() =>
      _ItemTrackingStatusState();
}

class _ItemTrackingStatusState
    extends ConsumerState<_ItemTrackingStatus> {
  Future<Map<String, dynamic>>? _request;

  void _load() {
    final userId = ref.read(authViewModelProvider).user?.id;
    if (userId == null) return;

    setState(() {
      _request = ref.read(orderRepositoryProvider).getItemTracking(
        userId,
        widget.orderId,
        widget.item.orderItemId,
      );
    });
  }

  @override
  void initState() {
    super.initState();

    Future<void>.microtask(() {
      if (mounted) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _request,
            builder: (context, snapshot) {
              if (_request == null ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Text('배송상태 조회 중');
              }

              if (snapshot.hasError) {
                return Text(
                  '배송조회 실패: ${snapshot.error}',
                );
              }

              final result = snapshot.data;
              final label =
                  result?['label']?.toString() ?? '확인 불가';

              return Text('배송상태: $label');
            },
          ),
        ),
        TextButton(
          onPressed: _load,
          child: const Text('다시 조회'),
        ),
      ],
    );
  }
}
