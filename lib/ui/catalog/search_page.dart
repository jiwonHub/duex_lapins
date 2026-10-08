import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:duex_lapins/ui/catalog/catalog_view_model.dart';
import 'package:duex_lapins/ui/catalog/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: ref.read(catalogViewModelProvider).query,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogViewModelProvider);
    final mobile = MediaQuery.sizeOf(context).width < 720;
    final products = state.visibleProducts;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 16 : 34,
        mobile ? 24 : 36,
        mobile ? 16 : 34,
        70,
      ),
      child: Column(
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
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            autofocus: true,
            onChanged: ref.read(catalogViewModelProvider.notifier).search,
            style: AppTypography.serif(
              fontSize: mobile ? 40 : 62,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '어떤 상품을 찾고 계신가요?',
              hintStyle: AppTypography.serif(
                fontSize: mobile ? 40 : 62,
                height: 1,
                fontWeight: FontWeight.w400,
                color: AppTheme.muted.withOpacity(0.45),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            state.query.isEmpty
                ? '인기 검색 상품'
                : '검색 결과 ${products.length}개',
            style: AppTypography.label(
              fontSize: 9,
              letterSpacing: 1.55,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 24),
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
