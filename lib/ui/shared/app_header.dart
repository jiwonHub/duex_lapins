import 'package:duex_lapins/app/app_routes.dart';
import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:duex_lapins/ui/auth/auth_view_model.dart';
import 'package:duex_lapins/ui/cart/cart_view_model.dart';
import 'package:duex_lapins/ui/catalog/catalog_view_model.dart';
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
  bool _focused = false;

  void _search(BuildContext context, String value) {
    ref.read(catalogViewModelProvider.notifier).search(value);
    context.go(AppRoutePath.search);
  }

  void _showCustomerService(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Service',
                  style: AppTypography.serif(
                    fontSize: 32,
                    height: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 18),
                Text(
                  '주문 · 배송 · 교환 · 반품 · 상품 관련 문의를 확인할 수 있는 CS 영역입니다.',
                  style: AppTypography.body(
                    fontSize: 11.5,
                    height: 1.7,
                    color: AppTheme.muted,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '정식 문의 채널은 오픈 전 연결 예정입니다.',
                  style: AppTypography.label(
                    fontSize: 9,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
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
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onMenu,
                  icon: const Icon(Icons.menu, size: 21),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => context.go(AppRoutePath.home),
                  child: ClipRect(
                    child: SizedBox(
                      width: 100,
                      height: 44,
                      child: Image.asset(
                        'assets/images/duex_lapins_logo2.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
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

    return SizedBox(
      height: 94,
      child: Row(
        children: [
          const SizedBox(width: 180),
          const Spacer(),
          SizedBox(
            width: 620,
            child: Focus(
              onFocusChange: (value) => setState(() => _focused = value),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) => _search(context, value),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: '상품, 컬렉션, 스토리를 검색해보세요',
                      contentPadding: EdgeInsets.fromLTRB(34, 14, 34, 14),
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
                      duration: const Duration(milliseconds: 160),
                      opacity: _controller.text.isEmpty ? 0 : 1,
                      child: IconButton(
                        tooltip: '지우기',
                        visualDensity: VisualDensity.compact,
                        onPressed: _controller.text.isEmpty
                            ? null
                            : () {
                          _controller.clear();
                          ref
                              .read(
                            catalogViewModelProvider.notifier,
                          )
                              .search('');
                          setState(() {});
                        },
                        icon: const Icon(Icons.close, size: 16),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        width: _focused ? 620 : 510,
                        height: 1,
                        color: _focused ? AppTheme.text : AppTheme.line,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 180,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 5,
                  right: 20,
                  child: UnconstrainedBox(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _UtilityLink(
                          text: '회원가입',
                          onTap: () => context.go(AppRoutePath.join),
                        ),
                        _UtilityLink(
                          text: '로그인',
                          onTap: () => context.go(AppRoutePath.login),
                        ),
                        _UtilityLink(
                          text: '주문조회',
                          onTap: () => context.go(AppRoutePath.orders),
                        ),
                        _UtilityLink(
                          text: '마이페이지',
                          onTap: () => context.go(AppRoutePath.account),
                        ),
                        _UtilityLink(
                          text: 'CS 문의',
                          onTap: () => _showCustomerService(context),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: '위시리스트',
                        onPressed: () =>
                            context.go(AppRoutePath.wishlist),
                        icon: const Icon(
                          Icons.favorite_border,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        tooltip: '장바구니',
                        onPressed: () =>
                            context.go(AppRoutePath.cart),
                        icon: Badge(
                          isLabelVisible: cartCount > 0,
                          label: Text('$cartCount'),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 19,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      _HeaderAccountButton(
                        auth: auth,
                        onPressed: () =>
                            context.go(AppRoutePath.account),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          horizontal: 7,
          vertical: 4,
        ),
        child: Text(
          text,
          style: AppTypography.label(
            fontSize: 8,
            letterSpacing: 0.85,
            color: AppTheme.muted,
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
    final user = auth.user;
    final loggedIn = auth.isLoggedIn;
    final imageUrl = user?.profileImageUrl;
    final hasImage = imageUrl?.trim().isNotEmpty == true;

    String initial = '';

    if (user?.nickname.trim().isNotEmpty == true) {
      initial = user!.nickname.trim().substring(0, 1).toUpperCase();
    }

    return Tooltip(
      message: loggedIn
          ? user!.nickname
          : '로그인',
      child: IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        icon: loggedIn
            ? Container(
          width: 24,
          height: 24,
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border.all(
              color: AppTheme.line,
              width: 0.8,
            ),
          ),
          child: hasImage
              ? Image.network(
            imageUrl!,
            width: 24,
            height: 24,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Text(
                initial,
                style: AppTypography.label(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          )
              : Text(
            initial,
            style: AppTypography.label(
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
            : const Icon(
          Icons.person_outline,
          size: 19,
        ),
      ),
    );
  }
}
