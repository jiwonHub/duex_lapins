import 'dart:convert';

import 'package:http/http.dart' as http;

/// MOCK_API_BASE_URL이 지정된 경우에만 공통 서버를 사용한다.
/// 서버가 실패하면 앱 내부 Mock 데이터로 조용히 전환하지 않는다.
class SharedMockApiClient {
  SharedMockApiClient._();

  static final SharedMockApiClient instance = SharedMockApiClient._();

  static const String baseUrl = String.fromEnvironment(
    'MOCK_API_BASE_URL',
  );

  static bool get enabled => baseUrl.trim().isNotEmpty;

  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> request(
      String method,
      String path, [
        Map<String, dynamic>? body,
      ]) async {
    if (!enabled) {
      throw StateError('MOCK_API_BASE_URL이 설정되지 않았습니다.');
    }

    try {
      final request = http.Request(
        method.toUpperCase(),
        Uri.parse(
          '${baseUrl.replaceFirst(RegExp(r"/$"), "")}$path',
        ),
      );

      request.headers['Content-Type'] =
      'application/json; charset=utf-8';

      if (body != null) {
        request.body = jsonEncode(body);
      }

      final streamed = await _client.send(request).timeout(
        const Duration(seconds: 10),
      );

      final response = await http.Response.fromStream(streamed);
      final decoded = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Mock 서버의 응답 형식이 올바르지 않습니다.',
        );
      }

      return decoded;
    } catch (error) {
      return {
        'success': false,
        'error': {
          'code': 'NETWORK_ERROR',
          'message': '공통 Mock 서버에 연결할 수 없습니다: $error',
        },
      };
    }
  }
}