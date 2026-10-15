import 'package:deux_lapins/core/di/providers.dart';
import 'package:deux_lapins/domain/models/customer_inquiry.dart';
import 'package:deux_lapins/ui/auth/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerInquiriesState {
  const CustomerInquiriesState({
    this.inquiries = const [],
    this.loading = false,
    this.saving = false,
    this.error,
  });

  final List<CustomerInquiry> inquiries;
  final bool loading;
  final bool saving;
  final String? error;

  CustomerInquiriesState copyWith({
    List<CustomerInquiry>? inquiries,
    bool? loading,
    bool? saving,
    String? error,
    bool clearError = false,
  }) => CustomerInquiriesState(
    inquiries: inquiries ?? this.inquiries,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    error: clearError ? null : error ?? this.error,
  );
}

final customerInquiriesViewModelProvider =
NotifierProvider<CustomerInquiriesViewModel, CustomerInquiriesState>(
  CustomerInquiriesViewModel.new,
);

class CustomerInquiriesViewModel extends Notifier<CustomerInquiriesState> {
  String? _pendingSignature;
  String? _pendingRequestId;

  @override
  CustomerInquiriesState build() {
    ref.watch(
      authViewModelProvider.select((auth) => auth.user?.id),
    );

    _pendingSignature = null;
    _pendingRequestId = null;

    return const CustomerInquiriesState();
  }

  Future<void> refresh() async {
    if (state.loading || state.saving) return;

    final userId = ref.read(authViewModelProvider).user?.id;
    if (userId == null) return;

    state = state.copyWith(loading: true, clearError: true);

    try {
      final list = await ref
          .read(inquiryRepositoryProvider)
          .getInquiries(userId);

      if (ref.read(authViewModelProvider).user?.id != userId) {
        return;
      }

      state = state.copyWith(
        inquiries: list,
        loading: false,
      );
    } catch (error) {
      state = state.copyWith(
        loading: false,
        error: '$error',
      );
    }
  }

  Future<void> create({
    required CustomerInquiryType type,
    required String title,
    required String question,
    String? productId,
  }) async {
    if (state.saving) {
      throw StateError('문의 등록 중입니다.');
    }

    final auth = ref.read(authViewModelProvider).user;

    if (auth == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final userId = auth.id;

    final signature = [
      userId,
      type.name,
      title.trim(),
      question.trim(),
      productId ?? '',
    ].join('|');

    if (_pendingSignature != signature) {
      _pendingSignature = signature;
      _pendingRequestId =
      'inquiry-${DateTime.now().microsecondsSinceEpoch}';
    }

    state = state.copyWith(
      saving: true,
      clearError: true,
    );

    try {
      final row = await ref
          .read(inquiryRepositoryProvider)
          .createInquiry(
        userId: userId,
        requestId: _pendingRequestId!,
        customerName: auth.nickname.trim().isEmpty
            ? '고객'
            : auth.nickname,
        type: type,
        title: title,
        question: question,
        productId: productId,
      );

      _pendingSignature = null;
      _pendingRequestId = null;

      if (ref.read(authViewModelProvider).user?.id != userId) {
        return;
      }

      state = state.copyWith(
        inquiries: [
          row,
          ...state.inquiries.where((i) => i.id != row.id),
        ],
        saving: false,
      );
    } catch (error) {
      state = state.copyWith(
        saving: false,
        error: '$error',
      );
      rethrow;
    }
  }
}