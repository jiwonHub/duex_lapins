class Product {
  const Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.hoverImageUrl,
    required this.description,
    required this.colors,
    required this.sizes,
    this.isNew = false,
    this.isBest = false,
    this.isPremium = false,
    this.productCode = '',
    this.line = 'classic',
    this.saleStatus = 'selling',
    this.publishStatus = 'published',
    this.variants = const [],
    this.detailImageUrls = const [],
  });
  final String id;
  final String brand;
  final String name;
  final String category;
  final int price;
  final String imageUrl;
  final String hoverImageUrl;
  final String description;
  final List<String> colors;
  final List<String> sizes;
  final bool isNew;
  final bool isBest;
  final bool isPremium;
  final String productCode;
  final String line;
  final String saleStatus;
  final String publishStatus;
  final List<ProductVariant> variants;
  final List<String> detailImageUrls;

  bool get isVisible =>
      publishStatus == 'published' && saleStatus != 'hidden';

  bool get isSoldOut =>
      saleStatus != 'selling' ||
          !variants.any((variant) => !variant.isSoldOut);

  ProductVariant? variantFor(String? color, String? size) {
    if (color == null || size == null) return null;
    for (final variant in variants) {
      if (variant.color.trim().toUpperCase() == color.trim().toUpperCase() &&
          variant.size.trim().toUpperCase() == size.trim().toUpperCase() &&
          variant.isActive) {
        return variant;
      }
    }
    return null;
  }
}

class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.color,
    required this.size,
    required this.stockQuantity,
    this.lowStockThreshold = 3,
    this.isActive = true,
  });

  final String id;
  final String color;
  final String size;
  final int stockQuantity;
  final int lowStockThreshold;
  final bool isActive;

  bool get isSoldOut => !isActive || stockQuantity <= 0;
  bool get isLowStock =>
      isActive && stockQuantity > 0 && stockQuantity <= lowStockThreshold;

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
    id: json['id'] as String,
    color: json['color_name'] as String,
    size: json['size_name'] as String,
    stockQuantity: json['stock_quantity'] as int,
    lowStockThreshold: (json['low_stock_threshold'] as int?) ?? 3,
    isActive: (json['is_active'] as bool?) ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'color_name': color,
    'size_name': size,
    'stock_quantity': stockQuantity,
    'low_stock_threshold': lowStockThreshold,
    'is_active': isActive,
  };
}
