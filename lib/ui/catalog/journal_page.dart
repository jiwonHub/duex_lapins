import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/core/responsive/app_breakpoints.dart';
import 'package:deux_lapins/ui/catalog/editorial_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/core/widgets/web_media_reveal.dart';
import 'package:deux_lapins/core/widgets/web_parallax_media.dart';
import 'package:deux_lapins/core/widgets/web_reveal.dart';
import 'package:flutter/material.dart';

class JournalPage extends ConsumerWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < AppBreakpoints.mobile;
    final desktop = width >= AppBreakpoints.desktop;

    final result = ref.watch(publicJournalsProvider);

    if (result.isLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 1.2),
      );
    }

    if (result.hasError) {
      return Center(
        child: TextButton(
          onPressed: () => ref.invalidate(publicJournalsProvider),
          child: Text('저널 조회 실패 · 다시 시도: ${result.error}'),
        ),
      );
    }

    final journals = result.asData!.value;

    if (journals.isEmpty) {
      return const Center(
        child: Text('게시된 저널이 없습니다.'),
      );
    }

    final entries = journals.map((journal) => (
    journal.title,
    journal.preview,
    journal.coverImageDataUrl ??
        'https://images.unsplash.com/photo-1445205170230-053b83016050?auto=format&fit=crop&w=1400&q=90',
    )).toList(growable: false);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 16 : 34,
        30,
        mobile ? 16 : 34,
        84,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WebReveal(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JOURNAL  /  VOLUME 01',
                  style: AppTypography.label(
                    fontSize: 8.5,
                    letterSpacing: 1.75,
                    color: AppTheme.muted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stories in Form',
                  style: AppTypography.serif(
                    fontSize: mobile ? 42 : 60,
                    height: 0.95,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: desktop ? 44 : 28),
          WebMediaReveal(
              child: InkWell(
                onTap: () => context.go(
                  AppRoutePath.journalDetail(journals.first.id),
                ),
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 7,
                  child: WebParallaxMedia(
                    url: entries.first.$3,
                    aspectRatio: desktop ? 1.38 : 0.92,
                    strength: 18,
                    scale: 1.045,
                  ),
                ),
                if (desktop) ...[
                  const SizedBox(width: 48),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FEATURED STORY  /  01',
                            style: AppTypography.label(
                              fontSize: 8.5,
                              letterSpacing: 1.7,
                              color: AppTheme.muted,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            entries.first.$1,
                            style: AppTypography.serif(
                              fontSize: 46,
                              height: 0.94,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            entries.first.$2,
                            style: AppTypography.body(
                              fontSize: 13,
                              height: 1.7,
                              color: AppTheme.muted,
                            ),
                          ),
                          const SizedBox(height: 26),
                          Text(
                            '스토리 읽기  →',
                            style: AppTypography.label(
                              fontSize: 9,
                              letterSpacing: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
                ),
              ),
          ),
          if (!desktop) ...[
            const SizedBox(height: 18),
            Text(
              entries.first.$1,
              style: AppTypography.serif(
                fontSize: 30,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              entries.first.$2,
              style: AppTypography.body(
                fontSize: 12.5,
                color: AppTheme.muted,
              ),
            ),
          ],
          SizedBox(height: desktop ? 92 : 56),
          const Divider(height: 1),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length - 1,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: mobile ? 1 : 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 38,
              childAspectRatio: mobile ? 0.82 : 0.90,
            ),
            itemBuilder: (_, index) {
              final entry = entries[index + 1];

              return InkWell(
                  onTap: () => context.go(
                    AppRoutePath.journalDetail(journals[index + 1].id),
                  ),
                  child: WebReveal(
                    delay: Duration(milliseconds: index * 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: WebMediaReveal(
                        delay: Duration(milliseconds: index * 60),
                        child: WebParallaxMedia(
                          url: entry.$3,
                          aspectRatio: 0.86,
                          strength: 14,
                          scale: 1.035,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      entry.$1,
                      style: AppTypography.serif(
                        fontSize: 26,
                        height: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      entry.$2,
                      style: AppTypography.body(
                        fontSize: 12,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ),
                  ),
              );
            },
          ),
        ],
      ),
    );
  }
}
