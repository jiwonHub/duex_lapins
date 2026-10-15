import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/domain/models/product.dart';
import 'package:deux_lapins/ui/catalog/catalog_view_model.dart';
import 'package:deux_lapins/ui/catalog/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  static const _popularKeywords = [
    'WOOL',
    'JACKET',
    'SHIRT',
    'TROUSERS',
    'LEATHER',
    'KNIT',
  ];

  static const _categories = [
    'TOP',
    'SHIRTS',
    'PANTS',
    'OUTER',
    'SET',
    'ACC',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogViewModelProvider);
    final viewModel = ref.read(catalogViewModelProvider.notifier);

    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 720;

    final hasSearch =
        state.query.trim().isNotEmpty || state.category != 'ALL';

    final products = state.visibleProducts;

    final popularProducts = state.products
        .where((product) => product.isBest)
        .take(mobile ? 4 : 8)
        .toList(growable: false);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 16 : 34,
        mobile ? 24 : 36,
        mobile ? 16 : 34,
        70,
      ),
      child: hasSearch
          ? _SearchResult(
        mobile: mobile,
        query: state.query,
        category: state.category,
        products: products,
        onReset: () {
          viewModel.search('');
          viewModel.selectCategory('ALL');
        },
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SEARCH',
            style: AppTypography.label(
              fontSize: 9,
              letterSpacing: 1.9,
              color: AppTheme.muted,
            ),
          ),
          SizedBox(height: mobile ? 18 : 22),
          Text(
            '상품을 찾아보세요.',
            style: AppTypography.serif(
              fontSize: mobile ? 34 : 46,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '상단 검색창을 이용하거나 아래 검색어와 카테고리에서 빠르게 찾아볼 수 있습니다.',
            style: AppTypography.body(
              fontSize: mobile ? 11 : 11.5,
              height: 1.65,
              color: AppTheme.muted,
            ),
          ),
          SizedBox(height: mobile ? 34 : 46),
          _SectionTitle(
            index: '01',
            title: '인기 검색어',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularKeywords.map((keyword) {
              return _SearchChip(
                text: keyword,
                onTap: () {
                  viewModel.selectCategory('ALL');
                  viewModel.search(keyword);
                },
              );
            }).toList(),
          ),
          SizedBox(height: mobile ? 38 : 52),
          _SectionTitle(
            index: '02',
            title: '카테고리',
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: mobile ? 2 : 3,
              crossAxisSpacing: mobile ? 8 : 12,
              mainAxisSpacing: mobile ? 8 : 12,
              childAspectRatio: mobile ? 3.3 : 4.5,
            ),
            itemBuilder: (context, index) {
              final category = _categories[index];

              return _CategoryCard(
                category: category,
                onTap: () {
                  viewModel.search('');
                  viewModel.selectCategory(category);
                },
              );
            },
          ),
          SizedBox(height: mobile ? 42 : 58),
          _SectionTitle(
            index: '03',
            title: '인기 검색 상품',
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: popularProducts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: mobile ? 2 : 4,
              crossAxisSpacing: mobile ? 10 : 18,
              mainAxisSpacing: 34,
              childAspectRatio: mobile ? 0.59 : 0.60,
            ),
            itemBuilder: (_, index) {
              return ProductCard(
                product: popularProducts[index],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SearchResult extends StatelessWidget {
  const _SearchResult({
    required this.mobile,
    required this.query,
    required this.category,
    required this.products,
    required this.onReset,
  });

  final bool mobile;
  final String query;
  final String category;
  final List<Product> products;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final title = query.trim().isNotEmpty
        ? '"${query.trim()}"'
        : category;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '검색 결과',
          style: AppTypography.label(
            fontSize: 9,
            letterSpacing: 1.9,
            color: AppTheme.muted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.serif(
                  fontSize: mobile ? 34 : 46,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: onReset,
              child: const Text('검색 초기화'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${products.length}개의 상품',
          style: AppTypography.body(
            fontSize: 11,
            color: AppTheme.muted,
          ),
        ),
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 24),
        if (products.isEmpty)
          SizedBox(
            width: double.infinity,
            height: 220,
            child: Center(
              child: Text(
                '검색 결과가 없습니다.',
                style: AppTypography.body(
                  fontSize: 12,
                  color: AppTheme.muted,
                ),
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
            itemBuilder: (_, index) {
              return ProductCard(
                product: products[index],
              );
            },
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.index,
    required this.title,
  });

  final String index;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$index.',
          style: AppTypography.label(
            fontSize: 8,
            letterSpacing: 1.5,
            color: AppTheme.muted,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTypography.label(
            fontSize: 10,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SearchChip extends StatelessWidget {
  const _SearchChip({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.line,
          ),
        ),
        child: Text(
          text,
          style: AppTypography.label(
            fontSize: 9,
            letterSpacing: 1.25,
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  final String category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(
            color: AppTheme.line,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                category,
                style: AppTypography.serif(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}