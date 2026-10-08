import 'package:duex_lapins/app/app_routes.dart';
import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:duex_lapins/ui/auth/login_page.dart';
import 'package:duex_lapins/ui/auth/auth_view_model.dart';
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

    final items = [
      (
        'ORDERS',
        '주문 내역과 배송 상태를 확인합니다',
        Icons.inventory_2_outlined,
        AppSection.orders,
      ),
      (
        'WISHLIST',
        '저장해둔 상품을 확인합니다',
        Icons.favorite_border,
        AppSection.wishlist,
      ),
      (
        'ADDRESSES',
        '배송지를 등록하고 관리합니다',
        Icons.location_on_outlined,
        AppSection.addresses,
      ),
      (
        'PROFILE',
        '이름, 이메일, 연락처를 관리합니다',
        Icons.person_outline,
        AppSection.profile,
      ),
      (
        'SETTINGS',
        '알림과 쇼핑 환경을 설정합니다',
        Icons.tune,
        AppSection.settings,
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
              _ProfileImage(
                imageUrl: user.profileImageUrl,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nickname,
                      style: AppTypography.serif(
                        fontSize: mobile ? 27 : 34,
                        height: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (user.email?.isNotEmpty == true) ...[
                      const SizedBox(height: 6),
                      Text(
                        user.email!,
                        style: AppTypography.body(
                          fontSize: 11.5,
                          color: AppTheme.muted,
                        ),
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
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: items.map((item) {
              return SizedBox(
                width: mobile ? double.infinity : 320,
                child: InkWell(
                  onTap: () => context.go(
                    AppRoutePath.forSection(item.$4),
                  ),
                  child: Container(
                    height: 154,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.line,
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(item.$3, size: 20),
                        const Spacer(),
                        Text(
                          item.$1,
                          style: AppTypography.label(
                            fontSize: 9,
                            letterSpacing: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.$2,
                          style: AppTypography.body(
                            fontSize: 11,
                            color: AppTheme.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ProfileImage extends StatelessWidget {
  const _ProfileImage({
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl?.trim().isNotEmpty == true;

    return Container(
      width: 62,
      height: 62,
      clipBehavior: Clip.antiAlias,
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
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person_outline,
                size: 24,
              ),
            )
          : const Icon(
              Icons.person_outline,
              size: 24,
            ),
    );
  }
}
