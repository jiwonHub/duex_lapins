import 'package:deux_lapins/core/di/providers.dart';
import 'package:deux_lapins/domain/models/order_claim.dart';
import 'package:deux_lapins/ui/auth/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderClaimsState {
  const OrderClaimsState({
    this.orderId,
    this.claims = const [],
    this.loading = false,
    this.saving = false,
    this.errorMessage,
  });

  final String? orderId;
  final List<OrderClaim> claims;
  final bool loading;
  final bool saving;
  final String? errorMessage;
}

final orderClaimsViewModelProvider =
NotifierProvider<OrderClaimsViewModel, OrderClaimsState>(
  OrderClaimsViewModel.new,
);

class OrderClaimsViewModel extends Notifier<OrderClaimsState> {
  final Map<String, String> _retryIds = {};
  int _requestCounter = 0;

  @override
  OrderClaimsState build() {
    ref.watch(authViewModelProvider.select((value) => value.user?.id));
    _retryIds.clear();
    return const OrderClaimsState();
  }

  Future<void> load(String orderId) async {
    final userId = ref.read(authViewModelProvider).user?.id;
    if (userId == null) return;
    state = OrderClaimsState(
      orderId: orderId,
      claims: state.orderId == orderId ? state.claims : const [],
      loading: true,
    );
    try {
      final claims = await ref.read(orderRepositoryProvider).getClaims(userId);
      if (ref.read(authViewModelProvider).user?.id != userId ||
          state.orderId != orderId) return;
      state = OrderClaimsState(
        orderId: orderId,
        claims: claims.where((claim) => claim.orderId == orderId).toList(),
      );
    } catch (error) {
      if (state.orderId != orderId) return;
      state = OrderClaimsState(
        orderId: orderId,
        claims: state.claims,
        errorMessage: '$error',
      );
    }
  }

  Future<void> submit(OrderClaimRequest request) async {
    if (state.saving) throw StateError('신청 처리 중입니다.');
    final userId = ref.read(authViewModelProvider).user?.id;
    if (userId == null) throw StateError('로그인이 필요합니다.');
    final signature = [userId, request.orderId, request.orderItemId,
      request.type.name, request.quantity, request.reason.trim(),
      request.exchangeVariantId ?? ''].join('|');
    final requestId = _retryIds.putIfAbsent(signature,
            () => 'claim-${DateTime.now().microsecondsSinceEpoch}-${++_requestCounter}');
    state = OrderClaimsState(
      orderId: request.orderId,
      claims: state.claims,
      saving: true,
    );
    try {
      await ref.read(orderRepositoryProvider).submitClaim(userId, requestId, request);
      _retryIds.remove(signature);
      if (ref.read(authViewModelProvider).user?.id != userId) return;
      await load(request.orderId);
    } catch (error) {
      state = OrderClaimsState(
        orderId: request.orderId,
        claims: state.claims,
        errorMessage: '$error',
      );
      rethrow;
    }
  }
}