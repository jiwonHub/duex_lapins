class NotificationPreferences {
  const NotificationPreferences({
    this.orderUpdates = true,
    this.newArrivals = true,
    this.promotions = false,
  });

  final bool orderUpdates;
  final bool newArrivals;
  final bool promotions;

  NotificationPreferences copyWith({
    bool? orderUpdates,
    bool? newArrivals,
    bool? promotions,
  }) => NotificationPreferences(
    orderUpdates: orderUpdates ?? this.orderUpdates,
    newArrivals: newArrivals ?? this.newArrivals,
    promotions: promotions ?? this.promotions,
  );

  Map<String, dynamic> toJson() => {
    'order_updates': orderUpdates,
    'new_arrivals': newArrivals,
    'promotions': promotions,
  };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      NotificationPreferences(
        orderUpdates: json['order_updates'] == true,
        newArrivals: json['new_arrivals'] == true,
        promotions: json['promotions'] == true,
      );
}