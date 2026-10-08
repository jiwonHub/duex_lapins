class Order {
  const Order({
    required this.id,
    required this.date,
    required this.status,
    required this.itemName,
    required this.itemCount,
    required this.total,
    required this.imageUrl,
  });

  final String id;
  final String date;
  final String status;
  final String itemName;
  final int itemCount;
  final int total;
  final String imageUrl;
}
