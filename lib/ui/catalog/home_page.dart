import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/core/responsive/app_breakpoints.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/core/widgets/section_heading.dart';
import 'package:deux_lapins/core/widgets/web_cinematic_hero.dart';
import 'package:deux_lapins/core/widgets/web_media_reveal.dart';
import 'package:deux_lapins/core/widgets/web_parallax_media.dart';
import 'package:deux_lapins/core/widgets/web_reveal.dart';
import 'package:deux_lapins/core/widgets/web_split_editorial.dart';
import 'package:deux_lapins/ui/catalog/catalog_view_model.dart';
import 'package:deux_lapins/ui/catalog/editorial_view_model.dart';
import 'package:deux_lapins/ui/catalog/product_card.dart';
import 'package:deux_lapins/domain/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogViewModelProvider);
    final homeResult = ref.watch(publicHomeContentProvider);
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < AppBreakpoints.mobile;
    final desktop = width >= AppBreakpoints.desktop;

    if (state.loading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 1.2,
        ),
      );
    }

    if (homeResult.isLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 1.2),
      );
    }

    if (homeResult.hasError) {
      return Center(
        child: TextButton(
          onPressed: () => ref.invalidate(publicHomeContentProvider),
          child: Text('홈 콘텐츠 조회 실패 · 다시 시도: ${homeResult.error}'),
        ),
      );
    }

    final home = homeResult.asData?.value;
    final products = state.products.where((product) => product.isVisible).toList();
    final bestProducts = products.where((product) => product.isBest).take(4).toList();

    final newProducts = <Product>[
      for (final id in home?.newArrivalProductIds ?? <String>[])
        ...products.where((product) => product.id == id),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          mobile ? 16 : 32,
          0,
          mobile ? 16 : 32,
          mobile ? 56 : 108,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (home?.hero.visible == true) ...[
              WebCinematicHero(
                videoDataUrl: home!.hero.videoDataUrl,
                imageUrl: home.hero.imageDataUrl ??
                    'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=2200&q=92',
                eyebrow: home.hero.subText,
                title: home.hero.mainText,
                actionLabel: home.hero.buttonText,
                onTap: () {
                  final route = home.hero.buttonRoute;
                  context.go(
                    route.startsWith('/') && !route.startsWith('//')
                        ? route
                        : AppRoutePath.newItems,
                  );
                },
              ),
              SizedBox(height: mobile ? 50 : 96),
            ],
            WebReveal(
              child: SectionHeading(
                index: '01.',
                title: 'New Arrivals',
                trailing: TextButton(
                  onPressed: () => context.go(AppRoutePath.newItems),
                  child: const Text('전체 보기  →'),
                ),
              ),
            ),
            SizedBox(height: mobile ? 18 : 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: newProducts.take(mobile ? 2 : 4).length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: mobile ? 1 : 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 40,
                childAspectRatio: mobile ? 0.69 : 0.72,
              ),
              itemBuilder: (_, index) => WebReveal(
                delay: Duration(
                  milliseconds: index * 70,
                ),
                child: ProductCard(
                  product: newProducts[index],
                ),
              ),
            ),
            SizedBox(height: mobile ? 64 : 118),
            const WebReveal(
              child: SectionHeading(
                index: '02.',
                title: 'Best Sellers',
              ),
            ),
            SizedBox(height: mobile ? 18 : 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bestProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: mobile ? 2 : 4,
                crossAxisSpacing: mobile ? 10 : 16,
                mainAxisSpacing: 30,
                childAspectRatio: mobile ? 0.60 : 0.61,
              ),
              itemBuilder: (_, index) => WebReveal(
                delay: Duration(
                  milliseconds: index * 55,
                ),
                child: ProductCard(
                  product: bestProducts[index],
                ),
              ),
            ),
            SizedBox(height: mobile ? 72 : 142),
            if (home?.classicVisible == true)
              WebSplitEditorial(
                imageUrl: home!.classicImageDataUrl ??
                    'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=1800&q=92',
              eyebrow: '03.  THE EDIT  /  REFINED UTILITY',
              title: 'Shape first.\nDetail later.',
              body:
              '절제된 구조와 부드러운 볼륨, 손끝에 느껴지는 질감에 집중했습니다. 과장하지 않은 실루엣이 자연스럽게 정돈되고, 입을수록 고유한 분위기가 더해지는 옷을 제안합니다.',
              actionLabel: '에디트 보기',
              onTap: () => context.go(AppRoutePath.journal),
            ),
            SizedBox(height: mobile ? 72 : 142),
            const WebReveal(
              child: SectionHeading(
                index: '04.',
                title: 'Editor’s Selection',
              ),
            ),
            SizedBox(height: mobile ? 18 : 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length >= 6 ? 3 : products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: mobile ? 1 : 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 34,
                childAspectRatio: mobile ? 0.68 : 0.67,
              ),
              itemBuilder: (_, index) => WebReveal(
                delay: Duration(
                  milliseconds: index * 80,
                ),
                child: ProductCard(
                  product: products[(index + 2) % products.length],
                ),
              ),
            ),
            SizedBox(height: mobile ? 74 : 146),
            _CollectionStatement(
              desktop: desktop,
              onTap: () => context.go(AppRoutePath.journal),
            ),
            SizedBox(height: mobile ? 74 : 140),
            if (home?.workVisible == true)
              WebSplitEditorial(
                reverse: true,
                imageUrl: home!.workImageDataUrl ??
                    'https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?auto=format&fit=crop&w=1800&q=92',
              eyebrow: '05.  THE STORY  /  SUBTLE STREET',
              title: 'Made to move.\nBuilt to remain.',
              body:
                  '움직임에 따라 옷의 인상은 달라집니다. 길게 떨어지는 선과 차분한 레이어, 균형 잡힌 비율이 장식보다 실루엣 자체를 천천히 드러내도록 설계했습니다.',
              actionLabel: '스토리 보기',
              onTap: () => context.go(AppRoutePath.journal),
            ),
            SizedBox(height: mobile ? 70 : 136),
          ],
        ),
      ),
    );
  }
}

class _CollectionStatement extends StatefulWidget {
  const _CollectionStatement({
    required this.desktop,
    required this.onTap,
  });

  final bool desktop;
  final VoidCallback onTap;

  @override
  State<_CollectionStatement> createState() => _CollectionStatementState();
}

class _CollectionStatementState extends State<_CollectionStatement> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const WebParallaxMedia(
              url:
                  'https://images.unsplash.com/photo-1445205170230-053b83016050?auto=format&fit=crop&w=2200&q=92',
              aspectRatio: 2.10,
              strength: 20,
              scale: 1.05,
            ),
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withOpacity(0.23),
              ),
            ),
            Positioned(
              left: widget.desktop ? 38 : 20,
              right: widget.desktop ? 38 : 20,
              top: widget.desktop ? 34 : 20,
              child: Row(
                children: [
                  Text(
                    'COLLECTION  /  AW26',
                    style: AppTypography.label(
                      fontSize: 8.5,
                      letterSpacing: 1.85,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'DUEX LAPINS',
                    style: AppTypography.label(
                      fontSize: 8.5,
                      letterSpacing: 1.7,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.desktop ? 42 : 20,
                vertical: widget.desktop ? 74 : 42,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'A Quiet Heritage',
                    textAlign: TextAlign.center,
                    style: AppTypography.serif(
                      color: Colors.white,
                      fontSize: widget.desktop ? 64 : 38,
                      height: 0.92,
                      letterSpacing: 0.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: widget.desktop ? 13 : 9),
                  Text(
                    'FORM / FUNCTION / TIME',
                    style: AppTypography.label(
                      fontSize: 8.5,
                      letterSpacing: 2.1,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: widget.desktop ? 26 : 18),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: _hovered && widget.desktop ? 170 : 64,
                    height: 1,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
