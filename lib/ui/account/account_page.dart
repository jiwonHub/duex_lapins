import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/ui/account/account_orders_overview.dart';
import 'package:deux_lapins/ui/auth/login_page.dart';
import 'package:deux_lapins/ui/account/account_view_model.dart';
import 'package:deux_lapins/ui/auth/auth_view_model.dart';
import 'package:deux_lapins/ui/catalog/catalog_view_model.dart';
import 'package:deux_lapins/ui/wishlist/wishlist_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authViewModelProvider);
    final mobile = MediaQuery.sizeOf(context).width < 720;

    if (auth.initializing) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 1.2,
        ),
      );
    }

    if (!auth.isLoggedIn) {
      return const LoginPage(
        embedded: true,
      );
    }

    final user = auth.user!;
    final account = ref.watch(accountViewModelProvider);

    final displayName = account.name.trim().isNotEmpty
        ? account.name
        : user.nickname;

    final displayEmail = account.email.trim().isNotEmpty
        ? account.email
        : (user.email ?? '');

    if (kDebugMode) {
      debugPrint('========== [ACCOUNT DEBUG] ==========');
      debugPrint('[KAKAO] id: ${user.id}');
      debugPrint('[KAKAO] nickname: ${user.nickname}');
      debugPrint('[KAKAO] email: ${user.email}');
      debugPrint('[KAKAO] profileImageUrl: ${user.profileImageUrl}');
      debugPrint('[AUTH] isLoggedIn: ${auth.isLoggedIn}');
      debugPrint('[PROFILE] memberId: ${account.memberId}');
      debugPrint('[PROFILE] name: ${account.name}');
      debugPrint('[PROFILE] email: ${account.email}');
      debugPrint('[PROFILE] phone: ${account.phone}');
      debugPrint('[PROFILE] loading: ${account.loading}');
      debugPrint('[PROFILE] error: ${account.errorMessage}');
      debugPrint('[DISPLAY] name: $displayName');
      debugPrint('[DISPLAY] email: $displayEmail');
      debugPrint('=====================================');
    }

    final wishlist = ref.watch(wishlistViewModelProvider);
    final catalog = ref.watch(catalogViewModelProvider);

    final selectedAddress = account.defaultAddress ??
        (account.addresses.isNotEmpty ? account.addresses.first : null);

    final wishlistNames = catalog.products
        .where(
          (product) =>
      product.isVisible && wishlist.ids.contains(product.id),
    )
        .take(2)
        .map((product) => product.name)
        .join(' · ');

    final items = <({
    String title,
    IconData icon,
    AppSection section,
    String primary,
    String secondary,
    String tertiary,
    })>[
      (
      title: 'WISHLIST',
      icon: Icons.favorite_border,
      section: AppSection.wishlist,
      primary: wishlist.loading
          ? '위시리스트 확인 중'
          : '저장한 상품 ${wishlist.ids.length}개',
      secondary: wishlist.loading
          ? '불러오는 중입니다.'
          : wishlist.ids.isEmpty
          ? '아직 저장한 상품이 없습니다.'
          : wishlistNames.isEmpty
          ? '저장된 상품 정보를 확인해보세요.'
          : wishlistNames,
      tertiary: '관심상품 전체 보기',
      ),
      (
      title: 'ADDRESSES',
      icon: Icons.location_on_outlined,
      section: AppSection.addresses,
      primary: account.loading
          ? '배송지 확인 중'
          : '등록 배송지 ${account.addresses.length}곳',
      secondary: selectedAddress == null
          ? '등록된 배송지가 없습니다.'
          : '${selectedAddress.isDefault ? "기본 배송지 · " : ""}'
          '${selectedAddress.recipientName}',
      tertiary: selectedAddress == null
          ? '배송지를 등록해주세요.'
          : '${selectedAddress.postcode} '
          '${selectedAddress.address} '
          '${selectedAddress.detailAddress}'.trim(),
      ),
      (
      title: 'PROFILE',
      icon: Icons.person_outline,
      section: AppSection.profile,
      primary: displayName.isEmpty ? '이름 미등록' : displayName,
      secondary: displayEmail.isEmpty
          ? '이메일 미등록'
          : displayEmail,
      tertiary: account.phone.trim().isEmpty
          ? '휴대폰 번호 미등록'
          : account.phone,
      ),
      (
      title: 'INQUIRIES',
      icon: Icons.chat_bubble_outline,
      section: AppSection.inquiries,
      primary: '1:1 · 상품 문의',
      secondary: '문의 접수 및 답변 확인',
      tertiary: '내 문의내역 보기',
      ),
      (
      title: 'SETTINGS',
      icon: Icons.tune,
      section: AppSection.settings,
      primary: '대한민국 · KRW ₩',
      secondary: '주문 상태 · 신상품 · 혜택 알림',
      tertiary: '알림 및 쇼핑 환경 설정',
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 20 : 40,
        mobile ? 26 : 36,
        mobile ? 20 : 40,
        76,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERSONAL  /  DUEX LAPINS',
            style: AppTypography.label(
              fontSize: 8.5,
              letterSpacing: 1.7,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'My Account',
            style: AppTypography.serif(
              fontSize: mobile ? 42 : 58,
              height: 0.95,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTypography.serif(
                        fontSize: mobile ? 27 : 34,
                        height: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      displayEmail.isNotEmpty
                          ? displayEmail
                          : '이메일 미등록',
                      style: AppTypography.body(
                        fontSize: 11.5,
                        color: AppTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      account.phone.trim().isNotEmpty
                          ? account.phone
                          : '휴대폰 번호 미등록',
                      style: AppTypography.body(
                        fontSize: 11.5,
                        color: AppTheme.muted,
                      ),
                    ),
                    if (account.loading) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(minHeight: 2),
                    ],
                    if (account.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '회원정보 조회 실패: ${account.errorMessage}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(accountViewModelProvider.notifier)
                            .refresh(),
                        child: const Text('다시 조회'),
                      ),
                    ],
                  ],
                ),
              ),
              TextButton(
                onPressed: auth.loading
                    ? null
                    : () async {
                        await ref
                            .read(authViewModelProvider.notifier)
                            .signOut();
                      },
                child: const Text('로그아웃'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Divider(height: 1),
          const SizedBox(height: 22),
          const AccountOrdersOverview(),
          const SizedBox(height: 34),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 14.0;

              final columns = constraints.maxWidth >= 1050
                  ? 3
                  : constraints.maxWidth >= 660
                  ? 2
                  : 1;

              final cardWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) /
                      columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: cardWidth,
                      child: InkWell(
                        onTap: () => context.go(
                          AppRoutePath.forSection(item.section),
                        ),
                        child: Container(
                          height: 222,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.line,
                              width: 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 20,
                                    color: AppTheme.text,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: AppTypography.label(
                                        fontSize: 10,
                                        letterSpacing: 1.3,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: AppTheme.muted,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                item.primary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.serif(
                                  fontSize: 23,
                                  height: 1.1,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.secondary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.body(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: AppTheme.text,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.tertiary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.body(
                                  fontSize: 11,
                                  height: 1.4,
                                  color: AppTheme.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
