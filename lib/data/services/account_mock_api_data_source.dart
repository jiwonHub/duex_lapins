import 'dart:convert';

import 'package:deux_lapins/core/network/shared_mock_api_client.dart';

class AccountMockApiException implements Exception {
  const AccountMockApiException(this.code, this.message);
  final String code;
  final String message;

  @override
  String toString() => message;
}

/// Mock 세션 및 회원/배송지 API. 실제 인증은 기존 Kakao Auth에 맡긴다.
class AccountMockApiDataSource {
  final Map<String, String> _providerUsers = {};
  final Map<String, Map<String, dynamic>> _profiles = {};
  final Map<String, List<Map<String, dynamic>>> _addresses = {};
  int _userSequence = 0;
  int _addressSequence = 0;

  Future<Map<String, dynamic>> request(
      String method,
      String path, [
        Map<String, dynamic>? body,
      ]) async {
    if (SharedMockApiClient.enabled) {
      // 공통 Node + SQLite를 사용할 때는 오류가 나도 메모리 Mock으로 대체하지 않는다.
      return SharedMockApiClient.instance.request(method, path, body);
    }
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final payload = body == null
        ? null
        : jsonDecode(jsonEncode(body)) as Map<String, dynamic>;
    try {
      final result = _dispatch(method.toUpperCase(), Uri.parse(path), payload);
      return jsonDecode(jsonEncode({'success': true, 'data': result}))
      as Map<String, dynamic>;
    } on AccountMockApiException catch (error) {
      return {
        'success': false,
        'error': {'code': error.code, 'message': error.message},
      };
    }
  }

  Object _dispatch(String method, Uri uri, Map<String, dynamic>? data) {
    final parts = uri.pathSegments;
    if (method == 'POST' && uri.path == '/mock/session') {
      final providerId = (data?['provider_user_id'] as String?)?.trim() ?? '';
      if (providerId.isEmpty) {
        throw const AccountMockApiException('UNAUTHORIZED', '로그인 정보가 없습니다.');
      }
      final id = _providerUsers.putIfAbsent(
        providerId,
            () => 'mock-user-${++_userSequence}',
      );
      final profile = _profiles.putIfAbsent(id, () => {
        'id': id,
        'name': ((data?['nickname'] as String?) ?? '').trim(),
        'email': ((data?['email'] as String?) ?? '').trim(),
        'phone': '',
      });
      _addresses.putIfAbsent(id, () => []);
      return profile;
    }

    if (parts.length < 2 || parts[0] != 'users') {
      throw const AccountMockApiException('NOT_FOUND', 'API 경로가 없습니다.');
    }
    final userId = parts[1];
    final profile = _profiles[userId];
    final addresses = _addresses[userId];
    if (profile == null || addresses == null) {
      throw const AccountMockApiException('NOT_FOUND', '회원이 없습니다.');
    }

    if (parts.length == 3 && parts[2] == 'profile') {
      if (method == 'GET') return profile;
      if (method == 'PUT') {
        final name = (data?['name'] as String?)?.trim() ?? '';
        final email = (data?['email'] as String?)?.trim() ?? '';
        final phone = (data?['phone'] as String?)?.trim() ?? '';
        if (name.isEmpty || name.length > 100 ||
            (email.isNotEmpty &&
                !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) ||
            (phone.isNotEmpty &&
                (phone.replaceAll(RegExp(r'\D'), '').length < 9 ||
                    phone.replaceAll(RegExp(r'\D'), '').length > 15))) {
          throw const AccountMockApiException(
              'VALIDATION_ERROR', '이름·이메일·휴대폰 번호를 확인해주세요.');
        }
        profile.addAll({'name': name, 'email': email, 'phone': phone});
        return profile;
      }
    }

    if (parts.length == 3 && parts[2] == 'addresses') {
      if (method == 'GET') return addresses;
      if (method == 'POST') {
        _validateAddress(data);
        final address = Map<String, dynamic>.from(data!);
        address['id'] = 'mock-address-${++_addressSequence}';
        address['user_id'] = userId;
        final makeDefault = addresses.isEmpty || address['is_default'] == true;
        if (makeDefault) {
          for (final existing in addresses) {
            existing['is_default'] = false;
          }
        }
        address['is_default'] = makeDefault;
        addresses.add(address);
        return address;
      }
    }

    if (parts.length == 4 && parts[2] == 'addresses') {
      final index = addresses.indexWhere((row) => row['id'] == parts[3]);
      if (index < 0) {
        throw const AccountMockApiException('NOT_FOUND', '배송지가 없습니다.');
      }
      if (method == 'PUT') {
        _validateAddress(data);
        final updating = addresses[index];
        final makeDefault = data!['is_default'] == true ||
            (updating['is_default'] == true &&
                !addresses.any((row) => row != updating && row['is_default'] == true));
        if (makeDefault) {
          for (final row in addresses) {
            row['is_default'] = false;
          }
        }
        updating.addAll(data);
        updating['id'] = parts[3];
        updating['user_id'] = userId;
        updating['is_default'] = makeDefault;
        return updating;
      }
      if (method == 'DELETE') {
        final wasDefault = addresses[index]['is_default'] == true;
        addresses.removeAt(index);
        if (wasDefault && addresses.isNotEmpty) {
          addresses.first['is_default'] = true;
        }
        return {'deleted': true};
      }
    }

    if (parts.length == 5 && parts[2] == 'addresses' &&
        parts[4] == 'default' && method == 'PUT') {
      if (!addresses.any((row) => row['id'] == parts[3])) {
        throw const AccountMockApiException('NOT_FOUND', '배송지가 없습니다.');
      }
      for (final row in addresses) {
        row['is_default'] = row['id'] == parts[3];
      }
      return addresses.firstWhere((row) => row['id'] == parts[3]);
    }
    throw const AccountMockApiException('METHOD_NOT_ALLOWED', '지원하지 않는 요청입니다.');
  }

  void _validateAddress(Map<String, dynamic>? data) {
    final name = (data?['recipient_name'] as String?)?.trim() ?? '';
    final phone = (data?['phone'] as String?)?.trim() ?? '';
    final postcode = (data?['postcode'] as String?)?.trim() ?? '';
    final address = (data?['address'] as String?)?.trim() ?? '';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (name.isEmpty || name.length > 100 ||
        digits.length < 9 || digits.length > 15 ||
        postcode.isEmpty || postcode.length > 20 || address.isEmpty) {
      throw const AccountMockApiException(
          'VALIDATION_ERROR', '수령인·연락처·우편번호·주소를 확인해주세요.');
    }
  }
}