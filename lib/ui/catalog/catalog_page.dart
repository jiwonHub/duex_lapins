import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:duex_lapins/core/widgets/web_reveal.dart';
import 'package:duex_lapins/ui/catalog/catalog_view_model.dart';
import 'package:duex_lapins/ui/catalog/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key, required this.title, this.mode = 'ALL'});

  final String title;
  final String mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogViewModelProvider);
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 720;
    var products = state.visibleProducts;

    if (mode == 'NEW') products = products.where((e) => e.isNew).toList();
    if (mode == 'BEST') products = products.where((e) => e.isBest).toList();
    if (mode == 'PREMIUM') {
      products = products.where((e) => e.isPremium).toList();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 16 : 34,
        mobile ? 22 : 34,
        mobile ? 16 : 34,
        70,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WebReveal(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COLLECTION  /  2026',
                        style: AppTypography.label(
                          fontSize: 8.5,
                          letterSpacing: 1.75,
                          color: AppTheme.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _titleCase(title),
                        style: AppTypography.serif(
                          fontSize: mobile ? 40 : 58,
                          height: 0.94,
                          letterSpacing: 0.15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!mobile)
                  Text(
                    'MODERN HERITAGE  ×  REFINED UTILITY',
                    style: AppTypography.label(
                      fontSize: 8,
                      letterSpacing: 1.45,
                      color: AppTheme.muted,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '상품 ${products.length}개',
                style: AppTypography.label(
                  fontSize: 9,
                  letterSpacing: 1.25,
                  color: AppTheme.muted,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showFilters(context, ref),
                icon: const Icon(Icons.tune, size: 15),
                label: const Text('필터'),
              ),
              const SizedBox(width: 12),
              Text(
                '정렬  /  추천순',
                style: AppTypography.label(
                  fontSize: 9,
                  letterSpacing: 1.1,
                  color: AppTheme.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 24),
          if (state.loading)
            const Center(child: CircularProgressIndicator(strokeWidth: 1.2))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: mobile ? 2 : width > 1500 ? 4 : 3,
                crossAxisSpacing: mobile ? 10 : 18,
                mainAxisSpacing: mobile ? 30 : 42,
                childAspectRatio: mobile ? 0.59 : 0.60,
              ),
              itemBuilder: (_, index) => WebReveal(
                delay: Duration(milliseconds: (index % 4) * 50),
                child: ProductCard(product: products[index]),
              ),
            ),
        ],
      ),
    );
  }

  String _titleCase(String value) {
    return value
        .toLowerCase()
        .split(' ')
        .map((word) {
          if (word.isEmpty) {
            return word;
          }

          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }

  void _showFilters(BuildContext context, WidgetRef ref) {
    final categories = [
      'ALL',
      'TOP',
      'SHIRTS',
      'PANTS',
      'OUTER',
      'SET',
      'ACC',
    ];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '필터',
                  style: AppTypography.serif(
                    fontSize: 32,
                    height: 1,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 19),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 18),
            Text(
              '카테고리',
              style: AppTypography.label(
                fontSize: 9,
                letterSpacing: 1.55,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                final selected =
                    ref.read(catalogViewModelProvider).category == category;

                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) {
                    ref
                        .read(catalogViewModelProvider.notifier)
                        .selectCategory(category);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
