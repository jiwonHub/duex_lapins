abstract class WishlistRepository {
  Set<String> getIds();
  Set<String> toggle(String productId);
}
