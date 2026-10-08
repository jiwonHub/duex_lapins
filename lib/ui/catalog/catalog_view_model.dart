import 'package:duex_lapins/core/di/providers.dart';
import 'package:duex_lapins/domain/models/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogState {
  const CatalogState({
    this.products = const [],
    this.loading = true,
    this.query = '',
    this.category = 'ALL',
  });

  final List<Product> products;
  final bool loading;
  final String query;
  final String category;

  CatalogState copyWith({
    List<Product>? products,
    bool? loading,
    String? query,
    String? category,
  }) {
    return CatalogState(
      products: products ?? this.products,
      loading: loading ?? this.loading,
      query: query ?? this.query,
      category: category ?? this.category,
    );
  }

  List<Product> get visibleProducts {
    return products.where((product) {
      final matchesCategory = category == 'ALL' ||
          product.category.toUpperCase() == category.toUpperCase();
      final normalized = query.trim().toLowerCase();
      final matchesQuery = normalized.isEmpty ||
          product.name.toLowerCase().contains(normalized) ||
          product.brand.toLowerCase().contains(normalized) ||
          product.category.toLowerCase().contains(normalized);
      return matchesCategory && matchesQuery;
    }).toList(growable: false);
  }
}

class CatalogViewModel extends Notifier<CatalogState> {
  @override
  CatalogState build() {
    Future<void>.microtask(_load);
    return const CatalogState();
  }

  Future<void> _load() async {
    final products = await ref.read(catalogRepositoryProvider).getProducts();
    state = state.copyWith(products: products, loading: false);
  }

  void search(String value) {
    state = state.copyWith(query: value);
  }

  void selectCategory(String value) {
    state = state.copyWith(category: value);
  }

  Product? byId(String? id) {
    for (final product in state.products) {
      if (product.id == id) return product;
    }
    return state.products.isEmpty ? null : state.products.first;
  }
}

final catalogViewModelProvider =
    NotifierProvider<CatalogViewModel, CatalogState>(CatalogViewModel.new);
