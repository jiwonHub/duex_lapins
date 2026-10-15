import 'package:deux_lapins/core/di/providers.dart';
import 'package:deux_lapins/domain/models/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogState {
  const CatalogState({
    this.products = const [],
    this.loading = true,
    this.query = '',
    this.category = 'ALL',
    this.line = 'ALL',
    this.errorMessage,
  });

  final List<Product> products;
  final bool loading;
  final String query;
  final String category;
  final String line;
  final String? errorMessage;

  CatalogState copyWith({
    List<Product>? products,
    bool? loading,
    String? query,
    String? category,
    String? line,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CatalogState(
      products: products ?? this.products,
      loading: loading ?? this.loading,
      query: query ?? this.query,
      category: category ?? this.category,
      line: line ?? this.line,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
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
      final matchesLine = line == 'ALL' ||
          product.line.toUpperCase() == line.toUpperCase();
      return product.isVisible && matchesCategory && matchesLine && matchesQuery;
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
    state = state.copyWith(loading: true, clearError: true);
    try {
      final products = await ref.read(catalogRepositoryProvider).getProducts();
      state = state.copyWith(products: products, loading: false);
    } catch (error) {
      state = state.copyWith(loading: false, errorMessage: '$error');
    }
  }

  Future<void> refresh() => _load();

  Future<Product?> fetchProduct(String productId) async {
    final product = await ref.read(catalogRepositoryProvider).getProduct(productId);
    if (product != null) {
      final products = [...state.products];
      final index = products.indexWhere((item) => item.id == product.id);
      if (index >= 0) {
        products[index] = product;
      } else {
        products.add(product);
      }
      state = state.copyWith(products: products);
    }
    return product;
  }

  void search(String value) {
    state = state.copyWith(query: value);
  }

  void selectCategory(String value) {
    state = state.copyWith(category: value);
  }

  void selectLine(String value) {
    state = state.copyWith(line: value);
  }

  Product? byId(String? id) {
    for (final product in state.products) {
      if (product.id == id) return product;
    }
    return null;
  }
}

final catalogViewModelProvider =
    NotifierProvider<CatalogViewModel, CatalogState>(CatalogViewModel.new);
