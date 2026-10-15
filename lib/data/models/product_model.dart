import 'package:deux_lapins/domain/models/product.dart';

class ProductModel {
  const ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    String imageUrl(String kind) {
      for (final image in images) {
        if (image['image_type'] == kind) {
          return image['image_url'] as String;
        }
      }
      return '';
    }

    final mainImage = imageUrl('main');
    final hoverImage = imageUrl('hover');
    return ProductModel(
      id: json['id'] as String,
      brand: json['brand'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: json['price'] as int,
      imageUrl: mainImage,
      hoverImageUrl: hoverImage.isEmpty ? mainImage : hoverImage,
      description: json['description'] as String,
      colors: (json['colors'] as List<dynamic>).cast<String>(),
      sizes: (json['sizes'] as List<dynamic>).cast<String>(),
      isNew: (json['is_new'] as bool?) ?? false,
      isBest: (json['is_best'] as bool?) ?? false,
      isPremium: (json['is_premium'] as bool?) ?? false,
      productCode: (json['product_code'] as String?) ?? '',
      line: (json['line'] as String?) ?? 'classic',
      saleStatus: (json['sale_status'] as String?) ?? 'selling',
      publishStatus: (json['publish_status'] as String?) ?? 'draft',
      variants: (json['variants'] as List<dynamic>? ?? const [])
          .map((row) => ProductVariant.fromJson(row as Map<String, dynamic>))
          .toList(growable: false),
      detailImageUrls: images
          .where((image) => image['image_type'] == 'detail')
          .map((image) => image['image_url'] as String)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_code': productCode.isEmpty ? id.toUpperCase() : productCode,
    'brand': brand,
    'name': name,
    'category': category,
    'line': line,
    'price': price,
    'description': description,
    'colors': colors,
    'sizes': sizes,
    'sale_status': saleStatus,
    'publish_status': publishStatus,
    'is_new': isNew,
    'is_best': isBest,
    'is_premium': isPremium,
    'variants': variants.map((variant) => variant.toJson()).toList(),
    'images': [
      {'image_type': 'main', 'image_url': imageUrl, 'sort_order': 0},
      {'image_type': 'hover', 'image_url': hoverImageUrl, 'sort_order': 0},
      for (var index = 0; index < detailImageUrls.length; index++)
        {
          'image_type': 'detail',
          'image_url': detailImageUrls[index],
          'sort_order': index,
        },
    ],
  };

  Product toEntity() => Product(
        id: id,
        brand: brand,
        name: name,
        category: category,
        price: price,
        imageUrl: imageUrl,
        hoverImageUrl: hoverImageUrl,
        description: description,
        colors: colors,
        sizes: sizes,
    isNew: isNew,
    isBest: isBest,
    isPremium: isPremium,
    productCode: productCode,
    line: line,
    saleStatus: saleStatus,
    publishStatus: publishStatus,
    variants: variants,
    detailImageUrls: detailImageUrls,
  );
}
