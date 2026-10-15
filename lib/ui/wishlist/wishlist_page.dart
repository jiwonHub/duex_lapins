import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/ui/catalog/catalog_view_model.dart';
import 'package:deux_lapins/ui/catalog/product_card.dart';
import 'package:deux_lapins/ui/wishlist/wishlist_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogViewModelProvider);
    final ids = ref.watch(wishlistViewModelProvider);
    final products = catalog.products
        .where((e) => e.isVisible && ids.contains(e.id))
        .toList();
    final mobile = MediaQuery.sizeOf(context).width < 720;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 16 : 34,
        mobile ? 24 : 34,
        mobile ? 16 : 34,
        70,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SAVED  /  PERSONAL SELECTION',
            style: AppTypography.label(
              fontSize: 8.5,
              letterSpacing: 1.7,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wishlist',
            style: AppTypography.serif(
              fontSize: mobile ? 42 : 58,
              height: 0.95,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          const Divider(height: 1),
          const SizedBox(height: 24),
          if (ids.loading || catalog.loading)
            const LinearProgressIndicator(minHeight: 2),
          if (ids.errorMessage != null || catalog.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                ids.errorMessage ??
                    catalog.errorMessage ??
                    '위시리스트를 불러오지 못했습니다.',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (ids.loading || catalog.loading)
            const SizedBox(height: 40)
          else if (ids.errorMessage != null || catalog.errorMessage != null)
            const SizedBox.shrink()
          else if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 88),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '아직 저장한 상품이 없습니다.',
                      style: AppTypography.serif(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton(
                      onPressed: () => context.go(AppRoutePath.newItems),
                      child: const Text('상품 둘러보기  →'),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: mobile ? 2 : 4,
                crossAxisSpacing: mobile ? 10 : 18,
                mainAxisSpacing: 34,
                childAspectRatio: mobile ? 0.59 : 0.60,
              ),
              itemBuilder: (_, index) => ProductCard(
                product: products[index],
              ),
            ),
        ],
      ),
    );
  }
}
