import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/core/widgets/app_image.dart';
import 'package:deux_lapins/domain/models/editorial_content.dart';
import 'package:deux_lapins/ui/catalog/catalog_view_model.dart';
import 'package:deux_lapins/ui/catalog/editorial_view_model.dart';
import 'package:deux_lapins/ui/catalog/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class JournalDetailPage extends ConsumerWidget {
  const JournalDetailPage({
    super.key,
    required this.journalId,
  });

  final String journalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(publicJournalProvider(journalId));

    return result.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Center(
        child: TextButton(
          onPressed: () =>
              ref.invalidate(publicJournalProvider(journalId)),
          child: Text('저널을 불러올 수 없습니다 · 다시 시도: $error'),
        ),
      ),
      data: (journal) {
        final products = ref.watch(catalogViewModelProvider).products;

        final related = products.where((product) =>
        product.isVisible &&
            journal.relatedProductIds.contains(product.id),
        ).toList(growable: false);

        final narrow = MediaQuery.sizeOf(context).width < 720;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            narrow ? 16 : 34,
            28,
            narrow ? 16 : 34,
            80,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () => context.go(AppRoutePath.journal),
                    icon: const Icon(Icons.arrow_back, size: 15),
                    label: const Text('저널 목록'),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    journal.category,
                    style: AppTypography.label(
                      fontSize: 10,
                      letterSpacing: 1.6,
                      color: AppTheme.muted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    journal.title,
                    style: AppTypography.serif(
                      fontSize: narrow ? 36 : 56,
                      height: 1.06,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (journal.coverImageDataUrl != null) ...[
                    AppImage(
                      url: journal.coverImageDataUrl!,
                      aspectRatio: 1.7,
                    ),
                    const SizedBox(height: 32),
                  ],
                  SelectableText(
                    journal.body,
                    style: AppTypography.body(
                      fontSize: 14,
                      height: 1.9,
                    ),
                  ),
                  for (final image in journal.additionalImageBase64)
                    if (editorialImageDataUrl(image) != null) ...[
                      const SizedBox(height: 28),
                      AppImage(
                        url: editorialImageDataUrl(image)!,
                        aspectRatio: 1.7,
                      ),
                    ],
                  if (related.isNotEmpty) ...[
                    const SizedBox(height: 52),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'RELATED ITEMS',
                      style: AppTypography.serif(fontSize: 30),
                    ),
                    const SizedBox(height: 18),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: related.length,
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: narrow ? 2 : 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 28,
                        childAspectRatio: 0.62,
                      ),
                      itemBuilder: (_, index) =>
                          ProductCard(product: related[index]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}