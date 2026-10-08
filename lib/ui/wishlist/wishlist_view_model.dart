import 'package:duex_lapins/core/di/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WishlistViewModel extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.read(wishlistRepositoryProvider).getIds();

  void toggle(String productId) {
    state = ref.read(wishlistRepositoryProvider).toggle(productId);
  }

  bool contains(String productId) => state.contains(productId);
}

final wishlistViewModelProvider =
    NotifierProvider<WishlistViewModel, Set<String>>(WishlistViewModel.new);
