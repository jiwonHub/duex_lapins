import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/ui/auth/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class KakaoCallbackPage extends ConsumerStatefulWidget {
  const KakaoCallbackPage({
    super.key,
    required this.code,
    this.error,
  });

  final String? code;
  final String? error;

  @override
  ConsumerState<KakaoCallbackPage> createState() =>
      _KakaoCallbackPageState();
}

class _KakaoCallbackPageState extends ConsumerState<KakaoCallbackPage> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) {
      return;
    }

    _started = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _complete();
    });
  }

  Future<void> _complete() async {
    if (widget.error != null || widget.code == null || widget.code!.isEmpty) {
      return;
    }

    final success = await ref
        .read(authViewModelProvider.notifier)
        .completeWebKakaoLogin(widget.code!);

    if (!mounted) {
      return;
    }

    if (success) {
      context.go(AppRoutePath.account);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authViewModelProvider);
    final hasRequestError = widget.error != null ||
        widget.code == null ||
        widget.code!.isEmpty;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DUEX LAPINS',
                  style: AppTypography.serif(
                    fontSize: 34,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                if (!hasRequestError && auth.errorMessage == null)
                  const CircularProgressIndicator(
                    strokeWidth: 1.4,
                  )
                else
                  Text(
                    auth.errorMessage ??
                        '카카오 로그인을 완료하지 못했습니다. 다시 시도해주세요.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      fontSize: 12,
                      height: 1.6,
                      color: AppTheme.muted,
                    ),
                  ),
                if (hasRequestError || auth.errorMessage != null) ...[
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => context.go(AppRoutePath.account),
                    child: const Text('로그인 화면으로 돌아가기'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
