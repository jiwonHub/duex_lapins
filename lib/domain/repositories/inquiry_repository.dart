import 'package:deux_lapins/domain/models/customer_inquiry.dart';

abstract class InquiryRepository {
  Future<List<CustomerInquiry>> getInquiries(String userId);

  Future<CustomerInquiry> createInquiry({
    required String userId,
    required String requestId,
    required String customerName,
    required CustomerInquiryType type,
    required String title,
    required String question,
    String? productId,
  });
}