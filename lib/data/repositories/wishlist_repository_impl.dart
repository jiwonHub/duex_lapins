import 'package:deux_lapins/data/services/shopping_mock_api_data_source.dart';
import 'package:deux_lapins/domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl(this._api);

  final ShoppingMockApiDataSource _api;

  Future<dynamic> _request(String method, String path) async {
    final response = await _api.request(method, path);
    if (response['success'] != true) {
      final error = response['error'] as Map<String, dynamic>?;
      throw ShoppingMockApiException(
        error?['code']?.toString() ?? 'UNKNOWN',
        error?['message']?.toString() ?? '위시리스트 요청에 실패했습니다.',
      );
    }
    return response['data'];
  }

  @override
  Future<Set<String>> getIds() async {
    final data = await _request('GET', '/wishlist') as List<dynamic>;
    return Set.unmodifiable(data.cast<String>());
  }

  @override
  Future<Set<String>> setSaved(String productId, bool saved) async {
    final data = await _request(
      saved ? 'PUT' : 'DELETE',
      '/wishlist/${Uri.encodeComponent(productId)}',
    ) as List<dynamic>;
    return Set.unmodifiable(data.cast<String>());
  }
}