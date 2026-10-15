import 'package:deux_lapins/core/responsive/app_breakpoints.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/core/widgets/web_media_reveal.dart';
import 'package:deux_lapins/core/widgets/web_parallax_media.dart';
import 'package:deux_lapins/core/widgets/web_reveal.dart';
import 'package:flutter/material.dart';

class WebSplitEditorial extends StatelessWidget {
  const WebSplitEditorial({
    super.key,
    required this.imageUrl,
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onTap,
    this.reverse = false,
  });

  final String imageUrl;
  final String eyebrow;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onTap;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= AppBreakpoints.desktop;

    final media = WebMediaReveal(
      child: WebParallaxMedia(
        url: imageUrl,
        aspectRatio: desktop ? 0.88 : 0.86,
        strength: 22,
        scale: 1.055,
      ),
    );

    final copy = WebReveal(
      delay: const Duration(milliseconds: 100),
      offset: 24,
      child: _EditorialCopy(
        eyebrow: eyebrow,
        title: title,
        body: body,
        actionLabel: actionLabel,
        onTap: onTap,
      ),
    );

    if (!desktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          media,
          const SizedBox(height: 28),
          copy,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: reverse
          ? [
              Expanded(flex: 5, child: copy),
              const SizedBox(width: 68),
              Expanded(flex: 7, child: media),
            ]
          : [
              Expanded(flex: 7, child: media),
              const SizedBox(width: 68),
              Expanded(flex: 5, child: copy),
            ],
    );
  }
}

class _EditorialCopy extends StatefulWidget {
  const _EditorialCopy({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  State<_EditorialCopy> createState() => _EditorialCopyState();
}

class _EditorialCopyState extends State<_EditorialCopy> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= AppBreakpoints.desktop;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.eyebrow,
          style: AppTypography.label(
            fontSize: 9,
            letterSpacing: 1.95,
            color: AppTheme.muted,
          ),
        ),
        SizedBox(height: desktop ? 26 : 15),
        Text(
          widget.title,
          style: AppTypography.serif(
            fontSize: desktop ? 58 : 36,
            height: 0.92,
            letterSpacing: 0.15,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: desktop ? 26 : 17),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            widget.body,
            style: AppTypography.body(
              fontSize: 13,
              height: 1.75,
              color: AppTheme.muted,
            ),
          ),
        ),
        SizedBox(height: desktop ? 34 : 24),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: SizedBox(
              width: 205,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.actionLabel,
                        style: AppTypography.label(
                          fontSize: 9.5,
                          letterSpacing: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 9),
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        offset: _hovered
                            ? const Offset(0.18, 0)
                            : Offset.zero,
                        child: const Text('→'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: _hovered ? 205 : 62,
                    height: 1,
                    color: AppTheme.text,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
