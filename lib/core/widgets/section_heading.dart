import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.trailing,
    this.index,
  });

  final String title;
  final Widget? trailing;
  final String? index;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (index != null) ...[
              Text(
                index!,
                style: AppTypography.label(
                  fontSize: 9,
                  letterSpacing: 1.45,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(width: 14),
            ],
            Text(
              title,
              style: AppTypography.serif(
                fontSize: 26,
                height: 1,
                letterSpacing: 0.55,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Divider(height: 1),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 14),
              trailing!,
            ],
          ],
        ),
      ],
    );
  }
}
