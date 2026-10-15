import 'package:deux_lapins/core/network/shared_mock_api_client.dart';
import 'package:deux_lapins/domain/models/customer_inquiry.dart';
import 'package:deux_lapins/domain/repositories/inquiry_repository.dart';

class InquiryRepositoryImpl implements InquiryRepository {
  InquiryRepositoryImpl(this._client);

  final SharedMockApiClient _client;

  Future<dynamic> _request(
      String method,
      String path, [
        Map<String, dynamic>? body,
      ]) async {
    final response = await _client.request(method, path, body);

    if (response['success'] != true) {
      final error = response['error'] as Map<String, dynamic>?;
      throw StateError(
        error?['message']?.toString() ?? '문의 요청에 실패했습니다.',
      );
    }

    return response['data'];
  }

  @override
  Future<List<CustomerInquiry>> getInquiries(String userId) async {
    final data = await _request(
      'GET',
      '/inquiries?user_id=${Uri.encodeQueryComponent(userId)}',
    ) as List<dynamic>;

    return data.map((row) => CustomerInquiry.fromJson(
      row as Map<String, dynamic>,
    )).toList(growable: false);
  }

  @override
  Future<CustomerInquiry> createInquiry({
    required String userId,
    required String requestId,
    required String customerName,
    required CustomerInquiryType type,
    required String title,
    required String question,
    String? productId,
  }) async {
    final data = await _request('POST', '/inquiries', {
      'user_id': userId,
      'request_id': requestId,
      'customer_name': customerName,
      'inquiry_type': type.name,
      'title': title.trim(),
      'question': question.trim(),
      if (type == CustomerInquiryType.product)
        'product_id': productId,
    });

    return CustomerInquiry.fromJson(data as Map<String, dynamic>);
  }
}