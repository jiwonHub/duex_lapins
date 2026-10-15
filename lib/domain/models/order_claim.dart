enum OrderClaimType { cancel, exchange, returnItem }

extension OrderClaimTypeLabel on OrderClaimType {
  String get label => switch (this) {
    OrderClaimType.cancel => '주문 취소',
    OrderClaimType.exchange => '교환',
    OrderClaimType.returnItem => '반품',
  };
}

class OrderClaimRequest {
  const OrderClaimRequest({
    required this.orderId,
    required this.orderItemId,
    required this.type,
    required this.quantity,
    required this.reason,
    this.exchangeVariantId,
  });

  final String orderId;
  final String orderItemId;
  final OrderClaimType type;
  final int quantity;
  final String reason;
  final String? exchangeVariantId;

  Map<String, dynamic> toJson(String userId, String requestId) => {
    'user_id': userId,
    'request_id': requestId,
    'order_id': orderId,
    'order_item_id': orderItemId,
    'claim_type': type.name,
    'quantity': quantity,
    'reason': reason.trim(),
    if (exchangeVariantId != null) 'exchange_variant_id': exchangeVariantId,
  };
}

class OrderClaim {
  const OrderClaim({
    required this.id,
    required this.orderId,
    required this.orderItemId,
    required this.type,
    required this.quantity,
    required this.reason,
    required this.processStatus,
    required this.pickupStatus,
    required this.refundStatus,
    required this.requestedAt,
    this.exchangeVariantId,
    this.adminMemo = '',
  });

  final String id;
  final String orderId;
  final String orderItemId;
  final OrderClaimType type;
  final int quantity;
  final String reason;
  final String processStatus;
  final String pickupStatus;
  final String refundStatus;
  final DateTime requestedAt;
  final String? exchangeVariantId;
  final String adminMemo;

  String get processLabel => switch (processStatus) {
    'requested' => '신청 접수',
    'processing' => '처리 중',
    'approved' => '승인',
    'rejected' => '거절',
    'completed' => '처리 완료',
    _ => '상태 확인',
  };

  int get reservedQuantity => processStatus == 'rejected' ? 0 : quantity;

  factory OrderClaim.fromJson(Map<String, dynamic> json) => OrderClaim(
    id: json['id'] as String,
    orderId: json['order_id'] as String,
    orderItemId: json['order_item_id'] as String,
    type: OrderClaimType.values.byName(json['claim_type'] as String),
    quantity: json['quantity'] as int,
    reason: json['reason'] as String,
    processStatus: json['process_status'] as String,
    pickupStatus: json['pickup_status'] as String,
    refundStatus: json['refund_status'] as String,
    requestedAt: DateTime.parse(json['requested_at'] as String),
    exchangeVariantId: json['exchange_variant_id'] as String?,
    adminMemo: json['admin_memo'] as String? ?? '',
  );
}