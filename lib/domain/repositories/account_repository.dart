import 'package:deux_lapins/domain/models/auth_user.dart';
import 'package:deux_lapins/domain/models/member_profile.dart';
import 'package:deux_lapins/domain/models/notification_preferences.dart';
import 'package:deux_lapins/domain/models/order.dart';

abstract class AccountRepository {
  Future<List<Order>> getOrders(String userId);
  Future<MemberProfile> getProfile(AuthUser user);
  Future<MemberProfile> updateProfile(MemberProfile profile);
  Future<List<DeliveryAddress>> getAddresses(String userId);
  Future<DeliveryAddress> saveAddress(DeliveryAddress address);
  Future<void> deleteAddress(String userId, String addressId);
  Future<void> setDefaultAddress(String userId, String addressId);
  Future<NotificationPreferences> getNotificationPreferences(String userId);
  Future<NotificationPreferences> saveNotificationPreferences(
      String userId, NotificationPreferences preferences,
      );
}