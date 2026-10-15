import 'package:deux_lapins/core/di/providers.dart';
import 'package:deux_lapins/ui/auth/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WishlistState {
  const WishlistState({
    this.ids = const <String>{},
    this.loading = false,
    this.saving = false,
    this.errorMessage,
  });

  final Set<String> ids;
  final bool loading;
  final bool saving;
  final String? errorMessage;

  bool contains(String productId) => ids.contains(productId);

  WishlistState copyWith({
    Set<String>? ids,
    bool? loading,
    bool? saving,
    String? errorMessage,
    bool clearError = false,
  }) => WishlistState(
    ids: ids ?? this.ids,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

class WishlistViewModel extends Notifier<WishlistState> {
  @override
  WishlistState build() {
    ref.watch(
      authViewModelProvider.select((auth) => auth.user?.id),
    );

    Future<void>.microtask(refresh);

    return const WishlistState(loading: true);
  }

  Future<void> refresh() async {
    if (state.saving) return;

    final userId = ref.read(authViewModelProvider).user?.id;
    state = state.copyWith(loading: true, clearError: true);

    try {
      final ids = await ref.read(wishlistRepositoryProvider).getIds();

      if (ref.read(authViewModelProvider).user?.id != userId) {
        return;
      }

      state = state.copyWith(ids: ids, loading: false);
    } catch (error) {
      if (ref.read(authViewModelProvider).user?.id != userId) {
        return;
      }

      state = state.copyWith(
        loading: false,
        errorMessage: '$error',
      );
    }
  }

  Future<void> toggle(String productId) async {
    if (state.loading || state.saving) {
      throw StateError('위시리스트 요청이 진행 중입니다.');
    }
    final shouldSave = !state.contains(productId);
    state = state.copyWith(saving: true, clearError: true);
    try {
      final ids = await ref.read(wishlistRepositoryProvider)
          .setSaved(productId, shouldSave);
      state = state.copyWith(ids: ids, saving: false);
    } catch (error) {
      state = state.copyWith(saving: false, errorMessage: '$error');
      rethrow;
    }
  }

  bool contains(String productId) => state.contains(productId);
}

final wishlistViewModelProvider =
NotifierProvider<WishlistViewModel, WishlistState>(WishlistViewModel.new);