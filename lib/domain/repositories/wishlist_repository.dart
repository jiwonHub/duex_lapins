abstract class WishlistRepository {
  Future<Set<String>> getIds();
  Future<Set<String>> setSaved(String productId, bool saved);
}
