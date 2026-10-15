class MemberProfile {
  const MemberProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  final String id;
  final String name;
  final String email;
  final String phone;

  factory MemberProfile.fromJson(Map<String, dynamic> json) => MemberProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
  };
}

class DeliveryAddress {
  const DeliveryAddress({
    required this.id,
    required this.userId,
    required this.recipientName,
    required this.phone,
    required this.postcode,
    required this.address,
    required this.detailAddress,
    required this.isDefault,
  });

  final String id;
  final String userId;
  final String recipientName;
  final String phone;
  final String postcode;
  final String address;
  final String detailAddress;
  final bool isDefault;

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) => DeliveryAddress(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    recipientName: json['recipient_name'] as String,
    phone: json['phone'] as String,
    postcode: json['postcode'] as String,
    address: json['address'] as String,
    detailAddress: json['detail_address'] as String? ?? '',
    isDefault: json['is_default'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'recipient_name': recipientName,
    'phone': phone,
    'postcode': postcode,
    'address': address,
    'detail_address': detailAddress,
    'is_default': isDefault,
  };
}