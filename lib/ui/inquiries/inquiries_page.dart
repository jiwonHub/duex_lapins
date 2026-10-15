import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/domain/models/customer_inquiry.dart';
import 'package:deux_lapins/ui/catalog/catalog_view_model.dart';
import 'package:deux_lapins/ui/inquiries/inquiries_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InquiriesPage extends ConsumerStatefulWidget {
  const InquiriesPage({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<InquiriesPage> createState() =>
      _InquiriesPageState();
}

class _InquiriesPageState extends ConsumerState<InquiriesPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _question = TextEditingController();

  late CustomerInquiryType _type;
  String? _productId;

  @override
  void initState() {
    super.initState();

    _productId = widget.productId;
    _type = _productId == null
        ? CustomerInquiryType.oneToOne
        : CustomerInquiryType.product;

    Future<void>.microtask(() {
      if (mounted) {
        ref.read(customerInquiriesViewModelProvider.notifier).refresh();
      }
    });
  }

  @override
  void didUpdateWidget(covariant InquiriesPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.productId != widget.productId &&
        widget.productId != null) {
      setState(() {
        _productId = widget.productId;
        _type = CustomerInquiryType.product;
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _question.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    try {
      await ref.read(customerInquiriesViewModelProvider.notifier).create(
        type: _type,
        title: _title.text,
        question: _question.text,
        productId: _type == CustomerInquiryType.product
            ? _productId
            : null,
      );

      if (!mounted) return;

      _title.clear();
      _question.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문의가 접수되었습니다.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('문의 등록 실패: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerInquiriesViewModelProvider);
    final products = ref.watch(catalogViewModelProvider).products;

    final productOptions = <String, String>{
      for (final product in products.where((p) => p.isVisible))
        product.id: product.name,
      if (_productId != null &&
          !products.any((p) => p.id == _productId))
        _productId!: '선택한 상품',
    };

    final mobile = MediaQuery.sizeOf(context).width < 720;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 20 : 40,
        34,
        mobile ? 20 : 40,
        76,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CUSTOMER SERVICE / DEUX LAPINS',
                style: AppTypography.label(
                  fontSize: 9,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Customer Inquiry',
                style: AppTypography.serif(
                  fontSize: mobile ? 36 : 48,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<CustomerInquiryType>(
                      value: _type,
                      decoration: const InputDecoration(
                        labelText: '문의 유형',
                      ),
                      items: CustomerInquiryType.values.map(
                            (type) => DropdownMenuItem<CustomerInquiryType>(
                          value: type,
                          child: Text(type.label),
                        ),
                      ).toList(),
                      onChanged: state.saving
                          ? null
                          : (value) => setState(() {
                        _type = value ??
                            CustomerInquiryType.oneToOne;

                        if (_type ==
                            CustomerInquiryType.oneToOne) {
                          _productId = null;
                        }
                      }),
                    ),

                    if (_type == CustomerInquiryType.product) ...[
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: productOptions.containsKey(_productId)
                            ? _productId
                            : null,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: '문의할 상품',
                        ),
                        items: productOptions.entries.map(
                              (entry) => DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ).toList(),
                        onChanged: state.saving
                            ? null
                            : (value) => setState(
                              () => _productId = value,
                        ),
                        validator: (value) => value == null
                            ? '상품을 선택해주세요.'
                            : null,
                      ),
                    ],

                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _title,
                      maxLength: 200,
                      decoration: const InputDecoration(
                        labelText: '제목',
                      ),
                      validator: (value) =>
                      (value?.trim().length ?? 0) < 2
                          ? '제목을 2자 이상 입력해주세요.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _question,
                      minLines: 4,
                      maxLines: 8,
                      maxLength: 5000,
                      decoration: const InputDecoration(
                        labelText: '문의 내용',
                      ),
                      validator: (value) =>
                      (value?.trim().length ?? 0) < 2
                          ? '문의 내용을 2자 이상 입력해주세요.'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.saving ? null : _submit,
                        child: Text(
                          state.saving ? '접수 중...' : '문의 등록',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 38),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '내 문의내역',
                      style: AppTypography.serif(fontSize: 27),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: state.loading || state.saving
                        ? null
                        : () => ref
                        .read(
                      customerInquiriesViewModelProvider.notifier,
                    )
                        .refresh(),
                    icon: const Icon(Icons.refresh, size: 17),
                    label: const Text('새로고침'),
                  ),
                ],
              ),

              if (state.loading)
                const LinearProgressIndicator(minHeight: 2),

              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '문의 조회 오류: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              if (!state.loading && state.inquiries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('등록된 문의가 없습니다.'),
                ),

              ...state.inquiries.map(
                    (inquiry) => Container(
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.line),
                  ),
                  child: ExpansionTile(
                    title: Text(inquiry.title),
                    subtitle: Text(
                      '${inquiry.type.label} · '
                          '${inquiry.createdAt.toLocal().toString().substring(0, 16)} · '
                          '${inquiry.isAnswered ? "답변완료" : "답변대기"}',
                    ),
                    childrenPadding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 18),
                    expandedCrossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      if (inquiry.productName != null)
                        Text('상품: ${inquiry.productName}'),
                      const SizedBox(height: 8),
                      Text('문의: ${inquiry.question}'),
                      const Divider(height: 28),
                      Text(
                        inquiry.isAnswered
                            ? '답변: ${inquiry.answer}'
                            : '관리자 답변을 기다리고 있습니다.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}