import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/ui/account/notification_settings_view_model.dart';
import 'package:deux_lapins/ui/account/account_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mobile = MediaQuery.sizeOf(context).width < 720;
    final account = ref.watch(accountViewModelProvider);
    final settings = ref.watch(notificationSettingsViewModelProvider);
    final viewModel = ref.read(notificationSettingsViewModelProvider.notifier);
    final disabled = account.loading || account.memberId == null ||
        settings.loading || settings.saving || settings.error != null;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 16 : 40,
        mobile ? 26 : 36,
        mobile ? 16 : 40,
        76,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACCOUNT  /  PREFERENCES',
              style: AppTypography.label(
                fontSize: 8.5,
                letterSpacing: 1.7,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Settings',
              style: AppTypography.serif(
                fontSize: mobile ? 42 : 58,
                height: 0.95,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 24),
            Text(
              '알림',
              style: AppTypography.label(
                fontSize: 9,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            if (settings.loading || settings.saving)
              const LinearProgressIndicator(minHeight: 2),
            if (settings.error != null)
              Row(children: [
                Expanded(child: Text('설정 저장/조회 실패: ${settings.error}',
                    style: const TextStyle(color: Colors.red))),
                TextButton(onPressed: account.memberId == null ? null :
                    () => viewModel.load(account.memberId!), child: const Text('재시도')),
              ]),
            _tile(
              '주문 상태 알림',
              '배송 준비부터 완료까지 상태를 알려드립니다',
              settings.preferences.orderUpdates,
              disabled ? null : (v) => viewModel.update(
                  settings.preferences.copyWith(orderUpdates: v)),
            ),
            _tile(
              '신상품 알림',
              '새 컬렉션과 신상품 출시 소식을 알려드립니다',
              settings.preferences.newArrivals,
              disabled ? null : (v) => viewModel.update(
                  settings.preferences.copyWith(newArrivals: v)),
            ),
            _tile(
              '혜택 알림',
              '세일 및 회원 전용 혜택을 알려드립니다',
              settings.preferences.promotions,
              disabled ? null : (v) => viewModel.update(
                  settings.preferences.copyWith(promotions: v)),
            ),
            const Divider(height: 42),
            Text(
              '지역 설정',
              style: AppTypography.label(
                fontSize: 9,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(child: Text('국가 / 지역')),
                Text(
                  '대한민국',
                  style: TextStyle(color: AppTheme.muted),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(child: Text('통화')),
                Text(
                  'KRW ₩',
                  style: TextStyle(color: AppTheme.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    String title,
    String subtitle,
    bool value,
      ValueChanged<bool>? onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: const TextStyle(fontSize: 13),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.muted,
        ),
      ),
    );
  }
}
