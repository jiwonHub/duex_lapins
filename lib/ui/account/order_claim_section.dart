import 'package:deux_lapins/core/di/providers.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/domain/models/order.dart';
import 'package:deux_lapins/domain/models/order_claim.dart';
import 'package:deux_lapins/domain/models/product.dart';
import 'package:deux_lapins/ui/account/order_claims_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderClaimSection extends ConsumerStatefulWidget {
  const OrderClaimSection({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<OrderClaimSection> createState() => _OrderClaimSectionState();
}

class _OrderClaimSectionState extends ConsumerState<OrderClaimSection> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      if (mounted) ref.read(orderClaimsViewModelProvider.notifier).load(widget.order.id);
    });
  }

  @override
  void didUpdateWidget(covariant OrderClaimSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.id != widget.order.id) {
      Future<void>.microtask(() {
        if (mounted) ref.read(orderClaimsViewModelProvider.notifier).load(widget.order.id);
      });
    }
  }

  Future<void> _open(OrderItem item, int available) async {
    final shipped = item.trackingNumber.isNotEmpty ||
        ['shipped', 'delivered'].contains(widget.order.deliveryStatus);
    Product? product;
    if (shipped && item.productId.isNotEmpty) {
      try {
        product = await ref.read(catalogRepositoryProvider).getProduct(item.productId);
      } catch (_) {
        // 상품 옵션 조회에 실패해도 반품 신청은 가능하다.
      }
    }
    if (!mounted) return;

    final options = product?.variants.where((variant) =>
    variant.isActive && !variant.isSoldOut && variant.id != item.variantId,
    ).toList(growable: false) ?? <ProductVariant>[];
    var type = shipped ? OrderClaimType.returnItem : OrderClaimType.cancel;
    var quantity = 1;
    String? exchangeVariantId;
    var reasonText = '';
    final key = GlobalKey<FormState>();

    final request = await showDialog<OrderClaimRequest>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('취소 · 교환 · 반품 신청'),
          content: SizedBox(
            width: 430,
            child: Form(
              key: key,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${item.productName} · ${item.color} / ${item.size}'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<OrderClaimType>(
                      value: type,
                      decoration: const InputDecoration(labelText: '신청 유형'),
                      items: OrderClaimType.values.map((option) {
                        final enabled = shipped
                            ? option != OrderClaimType.cancel
                            : option == OrderClaimType.cancel;

                        return DropdownMenuItem<OrderClaimType>(
                          value: option,
                          enabled: enabled,
                          child: Text(
                            enabled
                                ? option.label
                                : '${option.label} · ${shipped ? "발송 전만 가능" : "발송 후 가능"}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => update(() {
                        type = value ?? type;
                        exchangeVariantId = null;
                      }),
                    ),
                    if (!shipped) ...[
                      const SizedBox(height: 8),
                      const Text(
                        '교환·반품은 관리자에서 운송장을 등록하거나 상품을 발송 처리한 뒤 신청할 수 있습니다.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: quantity,
                      decoration: const InputDecoration(labelText: '신청 수량'),
                      items: [for (var i = 1; i <= available; i++)
                        DropdownMenuItem(value: i, child: Text('$i개'))],
                      onChanged: (value) => update(() => quantity = value ?? 1),
                    ),
                    if (type == OrderClaimType.exchange) ...[
                      const SizedBox(height: 12),
                      if (options.isEmpty)
                        const Text('교환 가능한 옵션이 없습니다. 다른 신청 유형을 선택해주세요.'),
                      if (options.isNotEmpty)
                        DropdownButtonFormField<String>(
                          value: exchangeVariantId,
                          decoration: const InputDecoration(labelText: '교환할 색상 / 사이즈'),
                          items: options.map((variant) => DropdownMenuItem(
                            value: variant.id,
                            child: Text('${variant.color} / ${variant.size}'),
                          )).toList(),
                          onChanged: (value) => update(() => exchangeVariantId = value),
                          validator: (value) => value == null ? '교환 옵션을 선택해주세요.' : null,
                        ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      onChanged: (value) => reasonText = value,
                      maxLength: 500,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: '신청 사유'),
                      validator: (value) => (value?.trim().length ?? 0) < 2
                          ? '사유를 2자 이상 입력해주세요.' : null,
                    ),
                    const Text('현재는 Mock 신청/처리 테스트이며 실제 환불이나 택배 회수는 진행되지 않습니다.'),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('닫기')),
            FilledButton(
              onPressed: type == OrderClaimType.exchange && options.isEmpty
                  ? null
                  : () {
                if (key.currentState?.validate() != true) return;
                Navigator.pop(dialogContext, OrderClaimRequest(
                  orderId: widget.order.id,
                  orderItemId: item.orderItemId,
                  type: type,
                  quantity: quantity,
                  reason: reasonText.trim(),
                  exchangeVariantId: type == OrderClaimType.exchange
                      ? exchangeVariantId : null,
                ));
              },
              child: const Text('신청하기'),
            ),
          ],
        ),
      ),
    );
    if (request == null || !mounted) return;

    try {
      await ref.read(orderClaimsViewModelProvider.notifier).submit(request);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신청이 접수됐습니다.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('신청 실패: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderClaimsViewModelProvider);
    final claims = state.orderId == widget.order.id ? state.claims : <OrderClaim>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: Text('취소 · 교환 · 반품',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            TextButton.icon(
              onPressed: state.loading || state.saving
                  ? null
                  : () => ref.read(orderClaimsViewModelProvider.notifier).load(widget.order.id),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('새로고침'),
            ),
          ],
        ),
        if (state.loading && state.orderId == widget.order.id)
          const LinearProgressIndicator(minHeight: 2),
        if (state.errorMessage != null && state.orderId == widget.order.id)
          Text('클레임 조회: ${state.errorMessage}',
              style: const TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 12),
        ...widget.order.items.map((item) {
          final itemClaims = claims.where((claim) => claim.orderItemId == item.orderItemId);
          final used = itemClaims.fold<int>(0, (sum, claim) => sum + claim.reservedQuantity);
          final available = item.quantity - used;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.productName} · ${item.color} / ${item.size}'),
                const SizedBox(height: 6),
                ...itemClaims.map((claim) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${claim.type.label} ${claim.quantity}개 · '
                      '${claim.processLabel}'
                      '${claim.refundStatus == 'completed' ? ' · Mock 환불 완료' : ''}'
                      '${claim.adminMemo.isNotEmpty ? ' · ${claim.adminMemo}' : ''}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                )),
                if (available > 0 && widget.order.paymentStatus == 'paid' &&
                    item.orderItemId.isNotEmpty)
                  TextButton(
                    onPressed: state.saving || state.loading ? null : () => _open(item, available),
                    child: Text('신청하기 (가능 수량 $available개)'),
                  ),
              ],
            ),
          );
        }),
        const Text('표시된 환불 상태는 Mock 테스트용이며 실제 PG 환불을 의미하지 않습니다.',
            style: TextStyle(fontSize: 11, color: AppTheme.muted)),
      ],
    );
  }
}