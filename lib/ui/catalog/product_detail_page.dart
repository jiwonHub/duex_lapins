import 'package:duex_lapins/app/app_routes.dart';
import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:duex_lapins/core/utils/price_formatter.dart';
import 'package:duex_lapins/core/utils/product_label_formatter.dart';
import 'package:duex_lapins/core/widgets/app_image.dart';
import 'package:duex_lapins/core/widgets/web_media_reveal.dart';
import 'package:duex_lapins/ui/cart/cart_view_model.dart';
import 'package:duex_lapins/domain/models/product.dart';
import 'package:duex_lapins/ui/catalog/catalog_view_model.dart';
import 'package:duex_lapins/ui/wishlist/wishlist_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String? productId;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  String? _size;
  String? _color;
  int _imageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogViewModelProvider);
    final product =
        ref.read(catalogViewModelProvider.notifier).byId(widget.productId);

    if (catalog.loading || product == null) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 1.2),
      );
    }

    _size ??= product.sizes.first;
    _color ??= product.colors.first;

    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 900;

    if (mobile) {
      return _mobile(product);
    }

    return _desktop(product);
  }

  Widget _desktop(Product product) {
    final images = [product.imageUrl, product.hoverImageUrl];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 26, 34, 76),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'COLLECTION  /  ${product.category.toUpperCase()}',
                style: AppTypography.label(
                  fontSize: 8.5,
                  letterSpacing: 1.55,
                  color: AppTheme.muted,
                ),
              ),
              const Spacer(),
              Text(
                'DUEX LAPINS  /  2026',
                style: AppTypography.label(
                  fontSize: 8.5,
                  letterSpacing: 1.45,
                  color: AppTheme.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 82,
                child: Column(
                  children: List.generate(images.length, (index) {
                    final selected = index == _imageIndex;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _imageIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.all(selected ? 1 : 0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selected
                                  ? AppTheme.text
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: AppImage(
                            url: images[index],
                            aspectRatio: 0.78,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 7,
                child: WebMediaReveal(
                  child: AspectRatio(
                    aspectRatio: 0.82,
                    child: ClipRect(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 420),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeOutCubic,
                        child: AppImage(
                          key: ValueKey(_imageIndex),
                          url: images[_imageIndex],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _buyPanel(product),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mobile(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 54),
      child: Column(
        children: [
          AppImage(
            url: product.imageUrl,
            aspectRatio: 0.78,
          ),
          AppImage(
            url: product.hoverImageUrl,
            aspectRatio: 0.78,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
            child: _buyPanel(product),
          ),
        ],
      ),
    );
  }

  Widget _buyPanel(Product product) {
    final wished = ref.watch(wishlistViewModelProvider).contains(product.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.brand,
          style: AppTypography.label(
            fontSize: 8.5,
            letterSpacing: 1.75,
            color: AppTheme.muted,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          product.name.toUpperCase(),
          style: AppTypography.serif(
            fontSize: 36,
            height: 0.94,
            letterSpacing: 0.1,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          formatPrice(product.price),
          style: const TextStyle(
            fontSize: 13,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 26),
        const Divider(height: 1),
        const SizedBox(height: 20),
        Text(
          product.description,
          style: AppTypography.body(
            fontSize: 12.5,
            height: 1.7,
            color: AppTheme.muted,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          '색상',
          style: AppTypography.label(
            fontSize: 9,
            letterSpacing: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: product.colors.map((color) {
            final selected = _color == color;
            final swatch = _colorValue(color);

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _color = color),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 25,
                      height: 25,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? AppTheme.text : AppTheme.line,
                          width: selected ? 1.2 : 0.8,
                        ),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: swatch,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatProductColor(color),
                      style: AppTypography.label(
                        fontSize: 7.5,
                        letterSpacing: 0.7,
                        color: selected ? AppTheme.text : AppTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 25),
        Text(
          '사이즈',
          style: AppTypography.label(
            fontSize: 9,
            letterSpacing: 1.45,
          ),
        ),
        const SizedBox(height: 11),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: product.sizes.map((size) {
            final selected = _size == size;

            return GestureDetector(
              onTap: () => setState(() => _size = size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                constraints: const BoxConstraints(minWidth: 42),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.text : Colors.transparent,
                  border: Border.all(
                    color: selected ? AppTheme.text : AppTheme.line,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  size,
                  textAlign: TextAlign.center,
                  style: AppTypography.label(
                    fontSize: 9,
                    letterSpacing: 0.6,
                    color: selected ? AppTheme.background : AppTheme.text,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              ref
                  .read(cartViewModelProvider.notifier)
                  .add(product, _size!, _color!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('장바구니에 담았습니다')),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('장바구니 담기'),
                SizedBox(width: 10),
                Text('→'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: TextButton.icon(
            onPressed: () => ref
                .read(wishlistViewModelProvider.notifier)
                .toggle(product.id),
            icon: Icon(
              wished ? Icons.favorite : Icons.favorite_border,
              size: 17,
            ),
            label: Text(wished ? '저장됨' : '위시리스트에 추가'),
          ),
        ),
        const SizedBox(height: 24),
        const Divider(height: 1),
        _infoRow(
          '상품 정보',
          '여유로운 핏 · 고급 소재 · 일상적인 레이어링을 고려한 디자인',
        ),
        _infoRow(
          '배송 안내',
          '20만원 이상 무료배송 · 일반 배송은 영업일 기준 2~4일 소요',
        ),
        _infoRow(
          '교환 및 반품',
          '상품 수령 후 14일 이내, 상품이 훼손되지 않은 경우 교환 및 반품 가능',
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go(AppRoutePath.cart),
          child: const Text('장바구니 보기  →'),
        ),
      ],
    );
  }

  Color _colorValue(String value) {
    switch (value.toLowerCase()) {
      case 'black':
      case 'washed black':
        return const Color(0xFF1B1917);
      case 'dark brown':
      case 'brown':
        return const Color(0xFF4A392E);
      case 'taupe':
      case 'stone':
      case 'sand':
        return const Color(0xFFB5A998);
      case 'ivory':
      case 'cream':
      case 'white':
        return const Color(0xFFEDE8DE);
      case 'grey':
      case 'graphite':
      case 'charcoal':
        return const Color(0xFF5B5B56);
      case 'blue':
      case 'indigo':
        return const Color(0xFF35404B);
      default:
        return const Color(0xFF6B665E);
    }
  }

  Widget _infoRow(String title, String body) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: AppTheme.line,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 18),
        iconColor: AppTheme.text,
        collapsedIconColor: AppTheme.text,
        title: Text(
          title,
          style: AppTypography.label(
            fontSize: 9,
            letterSpacing: 1.25,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              body,
              style: AppTypography.body(
                fontSize: 12,
                height: 1.6,
                color: AppTheme.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
