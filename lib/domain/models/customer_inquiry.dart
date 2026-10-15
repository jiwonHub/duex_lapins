enum CustomerInquiryType { oneToOne, product }

extension CustomerInquiryTypeLabel on CustomerInquiryType {
  String get label => switch (this) {
    CustomerInquiryType.oneToOne => '1:1 문의',
    CustomerInquiryType.product => '상품 문의',
  };
}

class CustomerInquiry {
  const CustomerInquiry({
    required this.id,
    required this.type,
    required this.title,
    required this.question,
    required this.status,
    required this.createdAt,
    this.productId,
    this.productName,
    this.answer = '',
    this.answeredAt,
  });

  final String id;
  final CustomerInquiryType type;
  final String title;
  final String question;
  final String status;
  final DateTime createdAt;
  final String? productId;
  final String? productName;
  final String answer;
  final DateTime? answeredAt;

  bool get isAnswered => status == 'answered';

  factory CustomerInquiry.fromJson(Map<String, dynamic> json) =>
      CustomerInquiry(
        id: json['id'] as String,
        type: CustomerInquiryType.values.byName(
          json['inquiry_type'] as String,
        ),
        title: json['title'] as String,
        question: json['question'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        productId: json['product_id'] as String?,
        productName: json['product_name'] as String?,
        answer: json['answer'] as String? ?? '',
        answeredAt: json['answered_at'] == null
            ? null
            : DateTime.parse(json['answered_at'] as String),
      );
}