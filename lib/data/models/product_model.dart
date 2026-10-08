import 'package:duex_lapins/domain/models/product.dart';

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
  );
}
