import 'package:deux_lapins/data/services/account_mock_api_data_source.dart';
import 'package:deux_lapins/domain/models/auth_user.dart';
import 'package:deux_lapins/domain/models/member_profile.dart';
import 'package:deux_lapins/domain/models/notification_preferences.dart';
import 'package:deux_lapins/domain/models/order.dart';
import 'package:deux_lapins/domain/repositories/account_repository.dart';
import 'package:deux_lapins/domain/repositories/order_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._api, this._orderRepository);

  final AccountMockApiDataSource _api;
  final OrderRepository _orderRepository;

  Future<dynamic> _request(
      String method,
      String path, [
        Map<String, dynamic>? body,
      ]) async {
    final response = await _api.request(method, path, body);
    if (response['success'] != true) {
      final error = response['error'] as Map<String, dynamic>?;
      throw AccountMockApiException(
        error?['code']?.toString() ?? 'UNKNOWN',
        error?['message']?.toString() ?? '회원 요청에 실패했습니다.',
      );
    }
    return response['data'];
  }

  @override
  Future<MemberProfile> getProfile(AuthUser user) async {
    final data = await _request('POST', '/mock/session', {
      'provider_user_id': user.id,
      'nickname': user.nickname,
      'email': user.email,
    });
    return MemberProfile.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<MemberProfile> updateProfile(MemberProfile profile) async {
    final data = await _request(
      'PUT', '/users/${Uri.encodeComponent(profile.id)}/profile',
      profile.toJson(),
    );
    return MemberProfile.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<DeliveryAddress>> getAddresses(String userId) async {
    final data = await _request(
      'GET', '/users/${Uri.encodeComponent(userId)}/addresses',
    ) as List<dynamic>;
    return data
        .map((row) => DeliveryAddress.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<DeliveryAddress> saveAddress(DeliveryAddress address) async {
    final base = '/users/${Uri.encodeComponent(address.userId)}/addresses';
    final data = await _request(
      address.id.isEmpty ? 'POST' : 'PUT',
      address.id.isEmpty ? base : '$base/${Uri.encodeComponent(address.id)}',
      address.toJson(),
    );
    return DeliveryAddress.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAddress(String userId, String addressId) async {
    await _request(
      'DELETE',
      '/users/${Uri.encodeComponent(userId)}/addresses/${Uri.encodeComponent(addressId)}',
    );
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    await _request(
      'PUT',
      '/users/${Uri.encodeComponent(userId)}/addresses/${Uri.encodeComponent(addressId)}/default',
    );
  }

  @override
  Future<NotificationPreferences> getNotificationPreferences(String userId) async {
    final data = await _request(
      'GET', '/users/${Uri.encodeComponent(userId)}/notification-preferences',
    );
    return NotificationPreferences.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<NotificationPreferences> saveNotificationPreferences(
      String userId, NotificationPreferences preferences,
      ) async {
    final data = await _request(
      'PUT', '/users/${Uri.encodeComponent(userId)}/notification-preferences',
      preferences.toJson(),
    );
    return NotificationPreferences.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<Order>> getOrders(String userId) {
    return _orderRepository.getOrders(userId);
  }
}
