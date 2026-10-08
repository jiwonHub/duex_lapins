import 'package:duex_lapins/domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final Set<String> _ids = {'p02', 'p05'};

  @override
  Set<String> getIds() => Set.unmodifiable(_ids);

  @override
  Set<String> toggle(String productId) {
    if (!_ids.add(productId)) {
      _ids.remove(productId);
    }
    return getIds();
  }
}
