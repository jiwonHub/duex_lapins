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
}
