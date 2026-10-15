class Order {
  const Order({
    required this.id,
    required this.date,
    required this.status,
    required this.itemName,
    required this.itemCount,
    required this.total,
    required this.imageUrl,
    this.userId = '',
    this.paymentStatus = '',
    this.deliveryStatus = '',
    this.paymentMethod = '',
    this.recipientName = '',
    this.recipientPhone = '',
    this.postcode = '',
    this.address = '',
    this.detailAddress = '',
    this.productAmount = 0,
    this.shippingFee = 0,
    this.items = const [],
  });

  final String id;
  final String date;
  final String status;
  final String itemName;
  final int itemCount;
  final int total;
  final String imageUrl;
  final String userId;
  final String paymentStatus;
  final String deliveryStatus;
  final String paymentMethod;
  final String recipientName;
  final String recipientPhone;
  final String postcode;
  final String address;
  final String detailAddress;
  final int productAmount;
  final int shippingFee;
  final List<OrderItem> items;

  factory Order.fromJson(Map<String, dynamic> json) {
    final rows = (json['items'] as List<dynamic>)
        .map((raw) => OrderItem.fromJson(raw as Map<String, dynamic>))
        .toList(growable: false);
    final orderedAt = DateTime.parse(json['ordered_at'] as String).toLocal();
    final date = '${orderedAt.year}.${orderedAt.month.toString().padLeft(2, '0')}.${orderedAt.day.toString().padLeft(2, '0')}';
    return Order(
      id: json['order_number'] as String,
      date: date,
      status: json['order_status'] as String,
      itemName: rows.isEmpty ? '' : rows.first.productName,
      itemCount: rows.fold<int>(0, (sum, item) => sum + item.quantity),
      total: json['total_amount'] as int,
      imageUrl: rows.isEmpty ? '' : rows.first.imageUrl,
      userId: json['user_id'] as String,
      paymentStatus: json['payment_status'] as String,
      deliveryStatus: json['delivery_status'] as String,
      paymentMethod: json['payment_method'] as String,
      recipientName: json['recipient_name'] as String,
      recipientPhone: json['recipient_phone'] as String,
      postcode: json['postcode'] as String,
      address: json['address'] as String,
      detailAddress: json['detail_address'] as String? ?? '',
      productAmount: json['product_amount'] as int,
      shippingFee: json['shipping_fee'] as int,
      items: rows,
    );
  }
}

class OrderItem {
  const OrderItem({
    required this.variantId,
    this.orderItemId = '',
    this.productId = '',
    required this.productName,
    required this.productCode,
    required this.color,
    required this.size,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    this.carrier = '',
    this.trackingNumber = '',
    this.deliveryStatus = 'preparing',
  });

  final String variantId;
  final String orderItemId;
  final String productId;
  final String productName;
  final String productCode;
  final String color;
  final String size;
  final String imageUrl;
  final int quantity;
  final int unitPrice;
  final String carrier;
  final String trackingNumber;
  final String deliveryStatus;

  int get total => quantity * unitPrice;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    variantId: json['product_variant_id'] as String,
    orderItemId: json['order_item_id'] as String? ?? '',
    productId: json['product_id'] as String? ?? '',
    productName: json['product_name'] as String,
    productCode: json['product_code'] as String,
    color: json['color_name'] as String,
    size: json['size_name'] as String,
    imageUrl: json['image_url'] as String? ?? '',
    quantity: json['quantity'] as int,
    unitPrice: json['unit_price'] as int,
    carrier: json['carrier'] as String? ?? '',
    trackingNumber: json['tracking_number'] as String? ?? '',
    deliveryStatus: json['delivery_status'] as String? ?? 'preparing',
  );
}
