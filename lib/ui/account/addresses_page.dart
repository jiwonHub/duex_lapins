import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/core/utils/address_search.dart';
import 'package:deux_lapins/domain/models/member_profile.dart';
import 'package:deux_lapins/ui/account/account_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class AddressesPage extends ConsumerWidget {
  const AddressesPage({super.key});

  Future<void> _editAddress(
      BuildContext context, WidgetRef ref, String userId,
      [DeliveryAddress? original]
      ) async {
    final name = TextEditingController(text: original?.recipientName ?? '');
    final phone = TextEditingController(text: original?.phone ?? '');
    final postcode = TextEditingController(text: original?.postcode ?? '');
    final address = TextEditingController(text: original?.address ?? '');
    final detail = TextEditingController(text: original?.detailAddress ?? '');
    final formKey = GlobalKey<FormState>();
    var isDefault = original?.isDefault ?? false;

    final dialogRoute = DialogRoute<DeliveryAddress>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(original == null ? '배송지 추가' : '배송지 수정'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final field in <(String, TextEditingController)>[
                      ('수령인', name),
                      ('연락처', phone),
                      ('우편번호', postcode),
                      ('주소', address),
                      ('상세 주소', detail),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          controller: field.$2,
                          decoration: InputDecoration(labelText: field.$1),
                          validator: (value) {
                            if (field.$1 == '상세 주소') return null;
                            return (value?.trim().isEmpty ?? true)
                                ? '${field.$1}을(를) 입력해주세요.' : null;
                          },
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.search, size: 16),
                        label: const Text('주소 찾기'),
                        onPressed: () async {
                          try {
                            final result =
                            await searchKoreanAddress(dialogContext);

                            if (!dialogContext.mounted || result == null) {
                              return;
                            }

                            postcode.text = result.postcode;
                            address.text = result.address;
                          } catch (error) {
                            if (!dialogContext.mounted) return;

                            ScaffoldMessenger.maybeOf(dialogContext)
                                ?.showSnackBar(
                              SnackBar(
                                content: Text('주소 검색 실패: $error'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('기본 배송지로 설정'),
                      contentPadding: EdgeInsets.zero,
                      value: isDefault,
                      onChanged: (v) => setDialogState(() => isDefault = v ?? false),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                Navigator.pop(dialogContext, DeliveryAddress(
                  id: original?.id ?? '',
                  userId: userId,
                  recipientName: name.text.trim(),
                  phone: phone.text.trim(),
                  postcode: postcode.text.trim(),
                  address: address.text.trim(),
                  detailAddress: detail.text.trim(),
                  isDefault: isDefault,
                ));
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );

    final value = await Navigator.of(context, rootNavigator: true)
        .push<DeliveryAddress>(dialogRoute);

    await dialogRoute.completed;

    name.dispose();
    phone.dispose();
    postcode.dispose();
    address.dispose();
    detail.dispose();

    if (value == null || !context.mounted) return;
    try {
      await ref.read(accountViewModelProvider.notifier).saveAddress(value);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('배송지를 저장했습니다.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('배송지 저장 실패: $error')),
      );
    }
  }

  Future<void> _deleteAddress(
      BuildContext context, WidgetRef ref, String addressId,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('배송지 삭제'),
        content: const Text('선택한 배송지를 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('삭제')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(accountViewModelProvider.notifier).deleteAddress(addressId);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('배송지 삭제 실패: $error')),
      );
    }
  }

  Future<void> _setDefault(
      BuildContext context, WidgetRef ref, String addressId,
      ) async {
    try {
      await ref.read(accountViewModelProvider.notifier).setDefaultAddress(addressId);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('기본 배송지 설정 실패: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountViewModelProvider);
    final mobile = MediaQuery.sizeOf(context).width < 720;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 16 : 40,
        mobile ? 26 : 36,
        mobile ? 16 : 40,
        76,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACCOUNT  /  DELIVERY',
              style: AppTypography.label(
                fontSize: 8.5,
                letterSpacing: 1.7,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Addresses',
              style: AppTypography.serif(
                fontSize: mobile ? 42 : 58,
                height: 0.95,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 22),
            if (state.loading)
              const LinearProgressIndicator(minHeight: 2)
            else if (state.errorMessage != null && state.memberId == null)
              Text('배송지 조회 실패: ${state.errorMessage}')
            else if (state.addresses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Text('등록된 배송지가 없습니다.'),
                ),
            if (state.errorMessage != null && state.memberId != null)
              Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
            for (final item in state.addresses)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.line, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (item.isDefault)
                            Text('기본 배송지', style: AppTypography.label(
                                fontSize: 8.5, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          TextButton(
                            onPressed: state.saving ? null : () =>
                                _editAddress(context, ref, state.memberId!, item),
                            child: const Text('수정'),
                          ),
                          TextButton(
                            onPressed: state.saving ? null : () =>
                                _deleteAddress(context, ref, item.id),
                            child: const Text('삭제'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(item.recipientName, style: AppTypography.serif(
                          fontSize: 22, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text(item.phone),
                      const SizedBox(height: 4),
                      Text('${item.postcode}  ${item.address} ${item.detailAddress}',
                          style: const TextStyle(color: AppTheme.muted, height: 1.5)),
                      if (!item.isDefault)
                        TextButton(
                          onPressed: state.saving ? null : () =>
                              _setDefault(context, ref, item.id),
                          child: const Text('기본 배송지로 지정'),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: state.loading || state.saving || state.memberId == null
                  ? null
                  : () => _editAddress(context, ref, state.memberId!),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('새 배송지 추가'),
            ),
          ],
        ),
      ),
    );
  }
}
