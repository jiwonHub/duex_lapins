import 'dart:math' as math;

import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/core/widgets/app_image.dart';
import 'package:deux_lapins/domain/models/product.dart';
import 'package:deux_lapins/ui/auth/auth_view_model.dart';
import 'package:deux_lapins/ui/cart/cart_view_model.dart';
import 'package:deux_lapins/ui/catalog/catalog_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppHeader extends ConsumerStatefulWidget {
  const AppHeader({super.key, this.onMenu, required this.mobile});

  final VoidCallback? onMenu;
  final bool mobile;

  @override
  ConsumerState<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends ConsumerState<AppHeader> {
  final _controller = TextEditingController();
  final LayerLink _searchLayerLink = LayerLink();

  OverlayEntry? _searchOverlay;

  bool _focused = false;

  void _search(BuildContext context, String value) {
    final viewModel = ref.read(catalogViewModelProvider.notifier);

    viewModel.selectCategory('ALL');
    viewModel.search(value.trim());

    _closeSearchOverlay();

    context.go(AppRoutePath.search);
  }

  void _closeSearchOverlay() {
    _searchOverlay?.remove();
    _searchOverlay = null;
  }

  void _openSearchOverlay(
      BuildContext context,
      double width,
      ) {
    if (_searchOverlay != null) {
      return;
    }

    final catalog = ref.read(catalogViewModelProvider);

    final bestProducts = catalog.products
        .where((product) => product.isBest)
        .take(3)
        .toList(growable: false);

    final popularProducts = bestProducts.isNotEmpty
        ? bestProducts
        : catalog.products.take(3).toList(growable: false);

    _searchOverlay = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeSearchOverlay,
              ),
            ),
            CompositedTransformFollower(
              link: _searchLayerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 52),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: width,
                  child: _DesktopSearchPanel(
                    products: popularProducts,
                    onKeyword: (keyword) {
                      _controller.value = TextEditingValue(
                        text: keyword,
                        selection: TextSelection.collapsed(
                          offset: keyword.length,
                        ),
                      );

                      final viewModel = ref.read(
                        catalogViewModelProvider.notifier,
                      );

                      viewModel.selectCategory('ALL');
                      viewModel.search(keyword);

                      _closeSearchOverlay();

                      context.go(AppRoutePath.search);
                    },
                    onCategory: (category) {
                      _controller.clear();

                      final viewModel = ref.read(
                        catalogViewModelProvider.notifier,
                      );

                      viewModel.search('');
                      viewModel.selectCategory(category);

                      _closeSearchOverlay();

                      context.go(AppRoutePath.search);
                    },
                    onProduct: (product) {
                      _closeSearchOverlay();

                      context.push(
                        AppRoutePath.product(product.id),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(
      _searchOverlay!,
    );
  }

  void _showCustomerService(BuildContext context) {
    context.go(AppRoutePath.inquiries);
  }

  @override
  void dispose() {
    _closeSearchOverlay();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartViewModelProvider).count;
    final auth = ref.watch(authViewModelProvider);

    if (widget.mobile) {
      return Column(
        children: [
          SizedBox(
            height: 62,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: widget.onMenu,
                    icon: const Icon(Icons.menu, size: 21),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () => context.go(AppRoutePath.home),
                    child: SizedBox(
                      width: 100,
                      height: 48,
                      child: Image.asset(
                        'assets/images/deux_lapins_logo2.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: '위시리스트',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => context.go(AppRoutePath.wishlist),
                        icon: const Icon(
                          Icons.favorite_border,
                          size: 19,
                        ),
                      ),
                      IconButton(
                        tooltip: '장바구니',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => context.go(AppRoutePath.cart),
                        icon: Badge(
                          isLabelVisible: cartCount > 0,
                          label: Text('$cartCount'),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 19,
                          ),
                        ),
                      ),
                      _HeaderAccountButton(
                        auth: auth,
                        onPressed: () => context.go(AppRoutePath.account),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => _search(context, value),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '검색',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _controller.clear();
                          ref.read(catalogViewModelProvider.notifier).search('');
                          setState(() {});
                        },
                        icon: const Icon(Icons.close, size: 17),
                      ),
              ),
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;

        final horizontalPadding = compact ? 20.0 : 34.0;
        final sideWidth = compact ? 120.0 : 250.0;
        final leftWidth = kIsWeb ? 0.0 : sideWidth;
        final rightWidth = kIsWeb
            ? math.min(
          220.0,
          math.max(
            0.0,
            constraints.maxWidth - (horizontalPadding * 2) - 260.0,
          ),
        )
            : sideWidth;

        final availableSearchWidth = constraints.maxWidth -
            (horizontalPadding * 2) -
            leftWidth -
            rightWidth;

        final searchWidth = math.min(
          620.0,
          math.max(
            260.0,
            availableSearchWidth,
          ),
        );

        return SizedBox(
          height: kIsWeb && constraints.maxWidth < 540 ? 140 : 94,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: leftWidth,
                ),
                Expanded(
                  child: Center(
                    child: CompositedTransformTarget(
                      link: _searchLayerLink,
                      child: SizedBox(
                        width: searchWidth,
                        child: Focus(
                          onFocusChange: (value) {
                            setState(() {
                              _focused = value;
                            });

                            if (value) {
                              _openSearchOverlay(
                                context,
                                searchWidth,
                              );
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              TextField(
                                controller: _controller,
                                textAlign: TextAlign.center,
                                textInputAction:
                                TextInputAction.search,
                                onTap: () {
                                  _openSearchOverlay(
                                    context,
                                    searchWidth,
                                  );
                                },
                                onSubmitted: (value) =>
                                    _search(
                                      context,
                                      value,
                                    ),
                                onChanged: (_) =>
                                    setState(() {}),
                                decoration:
                                const InputDecoration(
                                  hintText:
                                  '상품, 컬렉션, 스토리를 검색해보세요',
                                  contentPadding:
                                  EdgeInsets.fromLTRB(
                                    34,
                                    14,
                                    34,
                                    14,
                                  ),
                                  hintStyle: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 1.65,
                                    color: AppTheme.muted,
                                  ),
                                ),
                              ),
                              const Positioned(
                                left: 4,
                                child: Icon(
                                  Icons.search,
                                  size: 18,
                                ),
                              ),
                              Positioned(
                                right: 4,
                                child: AnimatedOpacity(
                                  duration: const Duration(
                                    milliseconds: 160,
                                  ),
                                  opacity:
                                  _controller.text.isEmpty
                                      ? 0
                                      : 1,
                                  child: IconButton(
                                    tooltip: '지우기',
                                    visualDensity:
                                    VisualDensity.compact,
                                    onPressed:
                                    _controller.text.isEmpty
                                        ? null
                                        : () {
                                      _controller
                                          .clear();

                                      final viewModel =
                                      ref.read(
                                        catalogViewModelProvider
                                            .notifier,
                                      );

                                      viewModel
                                          .selectCategory(
                                        'ALL',
                                      );

                                      viewModel
                                          .search('');

                                      setState(() {});
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Align(
                                  alignment:
                                  Alignment.center,
                                  child:
                                  AnimatedContainer(
                                    duration:
                                    const Duration(
                                      milliseconds: 240,
                                    ),
                                    curve:
                                    Curves.easeOutCubic,
                                    width: _focused
                                        ? searchWidth
                                        : searchWidth *
                                        0.82,
                                    height: 1,
                                    color: _focused
                                        ? AppTheme.text
                                        : AppTheme.line,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (kIsWeb)
                  SizedBox(
                    width: rightWidth,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (auth.isLoggedIn)
                              _WebHeaderIconButton(
                                tooltip: '위시리스트',
                                icon: const Icon(
                                  Icons.favorite_border,
                                  size: 20,
                                ),
                                onTap: () =>
                                    context.go(AppRoutePath.wishlist),
                              ),
                            _WebHeaderIconButton(
                              tooltip: '장바구니',
                              icon: Badge(
                                isLabelVisible: cartCount > 0,
                                label: Text('$cartCount'),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 20,
                                ),
                              ),
                              onTap: () => context.go(AppRoutePath.cart),
                            ),
                            _WebHeaderIconButton(
                              tooltip: '마이페이지',
                              icon: const Icon(
                                Icons.person_outline,
                                size: 20,
                              ),
                              onTap: () => context.go(AppRoutePath.account),
                            ),
                            _WebHeaderIconButton(
                              tooltip: '1:1문의',
                              icon: const Icon(
                                Icons.chat_bubble_outline,
                                size: 20,
                              ),
                              onTap: () => _showCustomerService(context),
                            ),
                            _WebHeaderIconButton(
                              tooltip: auth.isLoggedIn ? '로그아웃' : '로그인',
                              icon: Icon(
                                auth.isLoggedIn
                                    ? Icons.logout
                                    : Icons.login,
                                size: 20,
                              ),
                              onTap: () async {
                                if (!auth.isLoggedIn) {
                                  context.go(AppRoutePath.login);
                                  return;
                                }

                                try {
                                  await ref
                                      .read(authViewModelProvider.notifier)
                                      .signOut();

                                  if (!mounted) return;
                                  context.go(AppRoutePath.home);
                                } catch (error) {
                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('로그아웃 실패: $error'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: sideWidth,
                    child: Stack(
                      clipBehavior: Clip.none,
                    children: [
                      if (!compact)
                        Positioned(
                          top: 5,
                          right: 0,
                          child: UnconstrainedBox(
                            alignment:
                            Alignment.centerRight,
                            child: Row(
                              mainAxisSize:
                              MainAxisSize.min,
                              children: [
                                if (auth.isLoggedIn)
                                  _UtilityLink(
                                    text: '로그아웃',
                                    onTap: () async {
                                      try {
                                        await ref
                                            .read(authViewModelProvider.notifier)
                                            .signOut();

                                        if (!mounted) return;
                                        context.go(AppRoutePath.home);
                                      } catch (error) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '로그아웃 실패: $error',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  )
                                else
                                  _UtilityLink(
                                    text: '로그인',
                                    onTap: () =>
                                        context.go(
                                          AppRoutePath.login,
                                        ),
                                  ),
                                _UtilityLink(
                                  text: '마이페이지',
                                  onTap: () =>
                                      context.go(
                                        AppRoutePath.account,
                                      ),
                                ),
                                _UtilityLink(
                                  text: '1:1문의',
                                  onTap: () =>
                                      _showCustomerService(
                                        context,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Row(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: '위시리스트',
                              onPressed: () =>
                                  context.go(
                                    AppRoutePath.wishlist,
                                  ),
                              icon: const Icon(
                                Icons.favorite_border,
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: '장바구니',
                              onPressed: () =>
                                  context.go(
                                    AppRoutePath.cart,
                                  ),
                              icon: Badge(
                                isLabelVisible:
                                cartCount > 0,
                                label:
                                Text('$cartCount'),
                                child: const Icon(
                                  Icons
                                      .shopping_bag_outlined,
                                  size: 19,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            _HeaderAccountButton(
                              auth: auth,
                              onPressed: () =>
                                  context.go(
                                    AppRoutePath.account,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DesktopSearchPanel extends StatelessWidget {
  const _DesktopSearchPanel({
    required this.products,
    required this.onKeyword,
    required this.onCategory,
    required this.onProduct,
  });

  static const _keywords = [
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

  final List<Product> products;
  final ValueChanged<String> onKeyword;
  final ValueChanged<String> onCategory;
  final ValueChanged<Product> onProduct;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border.all(
          color: AppTheme.line,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '인기 검색어',
                  style: AppTypography.label(
                    fontSize: 9,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 13),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _keywords.map((keyword) {
                    return InkWell(
                      onTap: () => onKeyword(keyword),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.line,
                          ),
                        ),
                        child: Text(
                          keyword,
                          style: AppTypography.label(
                            fontSize: 8.5,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 23),
                Text(
                  '카테고리',
                  style: AppTypography.label(
                    fontSize: 9,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 13),
                Wrap(
                  spacing: 18,
                  runSpacing: 12,
                  children: _categories.map((category) {
                    return InkWell(
                      onTap: () => onCategory(category),
                      child: Text(
                        category,
                        style: AppTypography.label(
                          fontSize: 9,
                          letterSpacing: 1.2,
                          color: AppTheme.muted,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          if (products.isNotEmpty) ...[
            const SizedBox(width: 22),
            Container(
              width: 1,
              height: 220,
              color: AppTheme.line,
            ),
            const SizedBox(width: 22),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '인기 상품',
                    style: AppTypography.label(
                      fontSize: 9,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...products.map(
                        (product) => Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: InkWell(
                        onTap: () =>
                            onProduct(product),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 42,
                              height: 54,
                              child: AppImage(
                                url:
                                product.imageUrl,
                              ),
                            ),
                            const SizedBox(
                              width: 11,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(
                                    product.name
                                        .toUpperCase(),
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow
                                        .ellipsis,
                                    style:
                                    AppTypography
                                        .serif(
                                      fontSize: 14,
                                      height: 1,
                                      fontWeight:
                                      FontWeight
                                          .w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    product.category,
                                    style:
                                    AppTypography
                                        .label(
                                      fontSize: 7.5,
                                      letterSpacing:
                                      1.05,
                                      color:
                                      AppTheme
                                          .muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons
                                  .arrow_forward,
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WebHeaderIconButton extends StatelessWidget {
  const _WebHeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      constraints: const BoxConstraints.tightFor(
        width: 40,
        height: 40,
      ),
      padding: EdgeInsets.zero,
      icon: icon,
    );
  }
}

class _UtilityLink extends StatelessWidget {
  const _UtilityLink({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        child: Text(
          text,
          style: AppTypography.label(
            fontSize: 12,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.text,
          ),
        ),
      ),
    );
  }
}

class _HeaderAccountButton extends StatelessWidget {
  const _HeaderAccountButton({
    required this.auth,
    required this.onPressed,
  });

  final AuthState auth;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: auth.isLoggedIn ? '마이페이지' : '로그인',
      child: IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        icon: const Icon(
          Icons.person_outline,
          size: 21,
        ),
      ),
    );
  }
}