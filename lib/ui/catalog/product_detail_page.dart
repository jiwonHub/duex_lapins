import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/core/utils/price_formatter.dart';
import 'package:deux_lapins/core/utils/product_label_formatter.dart';
import 'package:deux_lapins/core/widgets/app_image.dart';
import 'package:deux_lapins/core/widgets/web_media_reveal.dart';
import 'package:deux_lapins/ui/cart/cart_view_model.dart';
import 'package:deux_lapins/ui/auth/auth_view_model.dart';
import 'package:deux_lapins/ui/checkout/checkout_view_model.dart';
import 'package:deux_lapins/domain/models/product.dart';
import 'package:deux_lapins/domain/models/selected_product_option.dart';
import 'package:deux_lapins/ui/catalog/catalog_view_model.dart';
import 'package:deux_lapins/ui/wishlist/wishlist_view_model.dart';
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
  final Map<String, int> _selectedQuantities = {};
  int _imageIndex = 0;
  late Future<Product?> _productFuture;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  @override
  void didUpdateWidget(covariant ProductDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      _size = null;
      _color = null;
      _selectedQuantities.clear();
      _imageIndex = 0;
      _fetchProduct();
    }
  }

  void _fetchProduct() {
    final id = widget.productId;
    _productFuture = id == null || id.isEmpty
        ? Future<Product?>.value(null)
        : ref.read(catalogViewModelProvider.notifier).fetchProduct(id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product?>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 1.2),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('상품 조회 실패: ${snapshot.error}'));
        }
        final product = snapshot.data;
        if (product == null) {
          return const Center(child: Text('존재하지 않거나 비공개된 상품입니다.'));
        }
        if (product.colors.isEmpty || product.sizes.isEmpty) {
          return const Center(child: Text('구매 옵션이 등록되지 않았습니다.'));
        }

        // 색상을 고르기 전에는 사이즈 선택을 열지 않는다.
        final width = MediaQuery.sizeOf(context).width;
        final mobile = width < 900;
        return mobile ? _mobile(product) : _desktop(product);
      },
    );
  }

  Widget _desktop(Product product) {
    final images = [
      product.imageUrl,
      product.hoverImageUrl,
      ...product.detailImageUrls,
    ];

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
          AppImage(url: product.imageUrl, aspectRatio: 0.78),
          AppImage(url: product.hoverImageUrl, aspectRatio: 0.78),
          for (final imageUrl in product.detailImageUrls)
            AppImage(url: imageUrl, aspectRatio: 0.78),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
            child: _buyPanel(product),
          ),
        ],
      ),
    );
  }

  Widget _buyPanel(Product product) {
    final wishlistState = ref.watch(wishlistViewModelProvider);
    final cartState = ref.watch(cartViewModelProvider);
    final auth = ref.watch(authViewModelProvider);
    final wished = wishlistState.contains(product.id);
    final selectedOptions = product.variants
        .where((variant) => (_selectedQuantities[variant.id] ?? 0) > 0)
        .map((variant) => SelectedProductOption(
      variant: variant,
      quantity: _selectedQuantities[variant.id]!,
    ))
        .toList(growable: false);
    final totalQuantity = selectedOptions.fold<int>(
      0, (sum, option) => sum + option.quantity,
    );
    final canAdd = !product.isSoldOut && selectedOptions.isNotEmpty;
    final canRequestCart = canAdd && !cartState.loading && !cartState.saving;
    final canRequestWishlist =
        auth.isLoggedIn && !wishlistState.loading && !wishlistState.saving;

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
          style: const TextStyle(fontSize: 13, letterSpacing: 0.2),
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
          style: AppTypography.label(fontSize: 9, letterSpacing: 1.45),
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
                onTap: cartState.saving ? null : () => setState(() {
                  _color = color;
                  _size = null;
                }),
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
        if (_color != null) ...[
          const SizedBox(height: 25),
          Text(
            '사이즈 · 선택 시 아래 목록에 추가됩니다',
            style: AppTypography.label(fontSize: 9, letterSpacing: 1.15),
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.sizes.map((size) {
              final option = product.variantFor(_color, size);
              final unavailable = option == null || option.isSoldOut;
              final selectedQuantity = option == null
                  ? 0 : (_selectedQuantities[option.id] ?? 0);
              final maxed = option != null &&
                  selectedQuantity >= option.stockQuantity;
              final selected = _size == size;

              return GestureDetector(
                onTap: cartState.saving || unavailable || maxed
                    ? null
                    : () => setState(() {
                  _size = size;
                  _selectedQuantities[option!.id] = selectedQuantity + 1;
                }),
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
                    unavailable ? '$size · 품절' : maxed ? '$size · 수량 한도' : size,
                    textAlign: TextAlign.center,
                    style: AppTypography.label(
                      fontSize: 9,
                      letterSpacing: 0.6,
                      color: selected ? AppTheme.background :
                      unavailable || maxed ? AppTheme.muted : AppTheme.text,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        if (selectedOptions.isNotEmpty) ...[
          const SizedBox(height: 26),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Text(
            '선택한 옵션 · $totalQuantity개',
            style: AppTypography.label(fontSize: 10, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),
          ...selectedOptions.map((option) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${formatProductColor(option.variant.color)} / ${option.variant.size}',
                    style: AppTypography.body(fontSize: 12),
                  ),
                ),
                IconButton(
                  tooltip: '수량 감소',
                  icon: const Icon(Icons.remove, size: 15),
                  onPressed: cartState.saving ? null : () => setState(() {
                    final next = option.quantity - 1;
                    if (next == 0) {
                      _selectedQuantities.remove(option.variantId);
                    } else {
                      _selectedQuantities[option.variantId] = next;
                    }
                  }),
                ),
                Text('${option.quantity}'),
                IconButton(
                  tooltip: '수량 증가',
                  icon: const Icon(Icons.add, size: 15),
                  onPressed: cartState.saving || option.quantity >= option.variant.stockQuantity
                      ? null
                      : () => setState(() {
                    _selectedQuantities[option.variantId] = option.quantity + 1;
                  }),
                ),
                IconButton(
                  tooltip: '옵션 삭제',
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: cartState.saving ? null : () => setState(
                        () => _selectedQuantities.remove(option.variantId),
                  ),
                ),
              ],
            ),
          )),
          const Divider(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '합계  ${formatPrice(product.price * totalQuantity)}',
              style: AppTypography.label(fontSize: 11),
            ),
          ),
        ] else ...[
          const SizedBox(height: 18),
          Text(
            _color == null ? '먼저 색상을 선택해주세요.' : '사이즈를 선택해주세요.',
            style: AppTypography.body(fontSize: 11, color: AppTheme.muted),
          ),
        ],
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: !canRequestCart
                ? null
                : () async {
                    try {
                      await ref
                          .read(cartViewModelProvider.notifier)
                          .addOptions(selectedOptions);

                      if (!mounted) return;
                      setState(() {
                        _selectedQuantities.clear();
                        _size = null;
                        _color = null;
                      });

                      final goToCart = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('장바구니 담기 성공'),
                          content: const Text('장바구니로 이동하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('계속 쇼핑'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: const Text('장바구니로 이동'),
                            ),
                          ],
                        ),
                      );

                      if (!mounted) return;

                      if (goToCart == true) {
                        context.go(AppRoutePath.cart);
                      }
                    } catch (error) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('장바구니 추가 실패: $error')),
                      );
                    }
                  },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(canAdd ? '선택한 옵션 모두 장바구니 담기' : '옵션을 선택해주세요'),
                const SizedBox(width: 10),
                const Text('→'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: !canAdd || cartState.saving
                ? null
                : () {
                    if (!auth.isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('구매하려면 먼저 로그인해주세요.')),
                      );
                      context.go(AppRoutePath.login);
                      return;
                    }

                    try {
                      ref
                          .read(checkoutViewModelProvider.notifier)
                          .startDirectPurchaseOptions(product, selectedOptions);
                      context.go(AppRoutePath.checkout);
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('구매 옵션 확인 실패: $error')),
                      );
                    }
                  },
            child: const Text('바로 구매'),
          ),
        ),
        if (auth.isLoggedIn) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: TextButton.icon(
              onPressed: !canRequestWishlist
                  ? null
                  : () async {
                      try {
                        await ref
                            .read(wishlistViewModelProvider.notifier)
                            .toggle(product.id);
                      } catch (error) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('위시리스트 변경 실패: $error')),
                        );
                      }
                    },
              icon: Icon(
                wished ? Icons.favorite : Icons.favorite_border,
                size: 17,
              ),
              label: Text(wished ? '저장됨' : '위시리스트에 추가'),
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Divider(height: 1),
        _infoRow('상품 정보', '여유로운 핏 · 고급 소재 · 일상적인 레이어링을 고려한 디자인'),
        _infoRow('배송 안내', '20만원 이상 무료배송 · 일반 배송은 영업일 기준 2~4일 소요'),
        _infoRow('교환 및 반품', '상품 수령 후 14일 이내, 상품이 훼손되지 않은 경우 교환 및 반품 가능'),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => context.push(
            '${AppRoutePath.inquiries}?product_id=${Uri.encodeQueryComponent(product.id)}',
          ),
          icon: const Icon(Icons.chat_bubble_outline, size: 16),
          label: const Text('이 상품 문의하기'),
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
      data: Theme.of(context).copyWith(dividerColor: AppTheme.line),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 18),
        iconColor: AppTheme.text,
        collapsedIconColor: AppTheme.text,
        title: Text(
          title,
          style: AppTypography.label(fontSize: 9, letterSpacing: 1.25),
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
