import 'package:duex_lapins/app/app_routes.dart';
import 'package:duex_lapins/core/di/providers.dart';
import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:duex_lapins/ui/auth/auth_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({
    super.key,
    this.embedded = false,
    this.eyebrow = 'ACCOUNT  /  DUEX LAPINS',
    this.title = 'Welcome Back',
    this.description =
    '로그인하고 주문 내역, 위시리스트, 배송지와\n회원 정보를 한곳에서 관리해보세요.',
    this.actionLabel = '카카오로 계속하기',
  });

  final bool embedded;
  final String eyebrow;
  final String title;
  final String description;
  final String actionLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authViewModelProvider);
    final config = ref.watch(kakaoConfigProvider);
    final mobile = MediaQuery.sizeOf(context).width < 720;
    final configured = kIsWeb
        ? config.canStartWebLogin
        : config.hasNativeKey;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 20 : 40,
        mobile ? 36 : 64,
        mobile ? 20 : 40,
        80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 520,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                eyebrow,
                textAlign: TextAlign.center,
                style: AppTypography.label(
                  fontSize: 8.5,
                  letterSpacing: 1.8,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.serif(
                  fontSize: mobile ? 46 : 64,
                  height: 0.92,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  fontSize: 12,
                  height: 1.7,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 34),
              const Divider(height: 1),
              const SizedBox(height: 34),
              SizedBox(
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: const Color(0xFF191919),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    elevation: 0,
                  ),
                  onPressed: !configured || auth.loading
                      ? null
                      : () async {
                          final success = await ref
                              .read(authViewModelProvider.notifier)
                              .signInWithKakao();

                          if (success && context.mounted) {
                            context.go(AppRoutePath.account);
                          }
                        },
                  child: auth.loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.6,
                            color: Color(0xFF191919),
                          ),
                        )
                      : Text(
                    actionLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (!configured) ...[
                const SizedBox(height: 16),
                Text(
                  '카카오 로그인 설정 파일을 확인해주세요.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    fontSize: 11,
                    color: AppTheme.muted,
                  ),
                ),
              ],
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  auth.errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    fontSize: 11,
                    color: const Color(0xFF8E2F24),
                  ),
                ),
              ],
              const SizedBox(height: 30),
              Text(
                '로그인하면 이용약관 및 개인정보 처리방침에 동의한 것으로 간주됩니다.',
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  fontSize: 10,
                  height: 1.5,
                  color: AppTheme.muted,
                ),
              ),
              if (!embedded) ...[
                const SizedBox(height: 28),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRoutePath.home),
                    child: const Text('쇼핑 계속하기  →'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
