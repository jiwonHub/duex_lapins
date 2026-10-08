import 'package:duex_lapins/core/responsive/app_breakpoints.dart';
import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:duex_lapins/core/widgets/web_media_reveal.dart';
import 'package:duex_lapins/core/widgets/web_parallax_media.dart';
import 'package:duex_lapins/core/widgets/web_reveal.dart';
import 'package:flutter/material.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < AppBreakpoints.mobile;
    final desktop = width >= AppBreakpoints.desktop;

    final entries = [
      (
        'Volume and Restraint',
        '새 시즌의 인상을 만드는 비율과 실루엣에 대한 이야기.',
        'https://images.unsplash.com/photo-1445205170230-053b83016050?auto=format&fit=crop&w=1400&q=90',
      ),
      (
        'Objects for Daily Life',
        '시간이 지날수록 자연스럽게 깊어지는 가죽과 코튼, 그리고 형태.',
        'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&w=1400&q=90',
      ),
      (
        'Autumn in Layers',
        '절제된 색과 서로 다른 질감을 겹쳐 완성한 가을의 레이어링.',
        'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=1400&q=90',
      ),
    ];

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

              return WebReveal(
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
              );
            },
          ),
        ],
      ),
    );
  }
}
