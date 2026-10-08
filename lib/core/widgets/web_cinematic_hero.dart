import 'dart:math' as math;

import 'package:duex_lapins/core/responsive/app_breakpoints.dart';
import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:duex_lapins/core/utils/effective_scroll_position.dart';
import 'package:duex_lapins/core/widgets/app_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebCinematicHero extends StatefulWidget {
  const WebCinematicHero({
    super.key,
    required this.imageUrl,
    required this.eyebrow,
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String imageUrl;
  final String eyebrow;
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  State<WebCinematicHero> createState() => _WebCinematicHeroState();
}

class _WebCinematicHeroState extends State<WebCinematicHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  ScrollPosition? _scrollPosition;
  double _scrollProgress = 0;

  bool get _webMotionEnabled {
    final mediaQuery = MediaQuery.maybeOf(context);

    if (!kIsWeb || mediaQuery == null) {
      return false;
    }

    return mediaQuery.size.width >= AppBreakpoints.desktop &&
        !mediaQuery.disableAnimations;
  }

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1750),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final nextPosition = findEffectiveVerticalScrollPosition(context);

      if (nextPosition != _scrollPosition) {
        _scrollPosition?.removeListener(_updateScrollProgress);
        _scrollPosition = nextPosition;
        _scrollPosition?.addListener(_updateScrollProgress);
      }

      _updateScrollProgress();
    });

    if (_webMotionEnabled && !_introController.isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _introController.forward();
        }
      });
    } else if (!_webMotionEnabled) {
      _introController.value = 1;
    }
  }

  void _updateScrollProgress() {
    if (!_webMotionEnabled || !mounted) {
      return;
    }

    final renderObject = context.findRenderObject();

    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final top = renderObject.localToGlobal(Offset.zero).dy;
    final height = renderObject.size.height;
    final progress = ((-top) / math.max(height, 1)).clamp(0.0, 1.0).toDouble();

    if ((_scrollProgress - progress).abs() < 0.002) {
      return;
    }

    setState(() {
      _scrollProgress = progress;
    });
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_updateScrollProgress);
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < AppBreakpoints.mobile;

    if (!_webMotionEnabled) {
      return _StaticHero(
        imageUrl: widget.imageUrl,
        eyebrow: widget.eyebrow,
        title: widget.title,
        actionLabel: widget.actionLabel,
        onTap: widget.onTap,
        mobile: mobile,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = math.min(
          820.0,
          math.max(600.0, constraints.maxWidth * 0.60),
        );

        return SizedBox(
          height: height,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _introController,
              builder: (context, _) {
                final intro = Curves.easeOutQuart.transform(
                  _introController.value,
                );
                final imageScale = 1.085 - (0.075 * intro) +
                    (0.014 * _scrollProgress);
                final imageY = -28 * _scrollProgress;
                final overlayOpacity = 0.18 + (0.05 * _scrollProgress);
                final curtainProgress = Curves.easeInOutCubic.transform(
                  const Interval(0, 0.64).transform(_introController.value),
                );

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Transform.translate(
                      offset: Offset(0, imageY),
                      child: Transform.scale(
                        scale: imageScale,
                        child: AppImage(
                          url: widget.imageUrl,
                        ),
                      ),
                    ),
                    ColoredBox(
                      color: Colors.black.withOpacity(overlayOpacity),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: 1 - curtainProgress,
                        heightFactor: 1,
                        child: const ColoredBox(
                          color: AppTheme.background,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 38,
                      right: 38,
                      bottom: 34,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _HeroCopy(
                              controller: _introController,
                              eyebrow: widget.eyebrow,
                              title: widget.title,
                              actionLabel: widget.actionLabel,
                              onTap: widget.onTap,
                              scrollProgress: _scrollProgress,
                            ),
                          ),
                          _HeroStamp(
                            controller: _introController,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.controller,
    required this.eyebrow,
    required this.title,
    required this.actionLabel,
    required this.onTap,
    required this.scrollProgress,
  });

  final AnimationController controller;
  final String eyebrow;
  final String title;
  final String actionLabel;
  final VoidCallback onTap;
  final double scrollProgress;

  @override
  Widget build(BuildContext context) {
    final lines = title.split('\n');
    final eyebrowValue = Curves.easeOutCubic.transform(
      const Interval(0.34, 0.70).transform(controller.value),
    );
    final actionValue = Curves.easeOutCubic.transform(
      const Interval(0.68, 1).transform(controller.value),
    );

    return Transform.translate(
      offset: Offset(0, -10 * scrollProgress),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: eyebrowValue,
            child: Transform.translate(
              offset: Offset(0, 12 * (1 - eyebrowValue)),
              child: Text(
                eyebrow,
                style: AppTypography.label(
                  fontSize: 9.5,
                  letterSpacing: 2.05,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(lines.length, (index) {
            final start = 0.38 + (index * 0.09);
            final end = math.min(1.0, start + 0.34);
            final value = Curves.easeOutQuart.transform(
              Interval(start, end).transform(controller.value),
            );

            return ClipRect(
              child: Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 44 * (1 - value)),
                  child: Text(
                    lines[index],
                    style: AppTypography.serif(
                      fontSize: 68,
                      height: 0.88,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 26),
          Opacity(
            opacity: actionValue,
            child: Transform.translate(
              offset: Offset(0, 16 * (1 - actionValue)),
              child: _HeroAction(
                label: actionLabel,
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStamp extends StatelessWidget {
  const _HeroStamp({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final value = Curves.easeOutCubic.transform(
      const Interval(0.72, 1).transform(controller.value),
    );

    return Opacity(
      opacity: value,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          'DUEX LAPINS  /  SEOUL  /  2026',
          style: AppTypography.label(
            fontSize: 8,
            letterSpacing: 1.55,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _StaticHero extends StatelessWidget {
  const _StaticHero({
    required this.imageUrl,
    required this.eyebrow,
    required this.title,
    required this.actionLabel,
    required this.onTap,
    required this.mobile,
  });

  final String imageUrl;
  final String eyebrow;
  final String title;
  final String actionLabel;
  final VoidCallback onTap;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        AppImage(
          url: imageUrl,
          aspectRatio: mobile ? 0.80 : 1.62,
        ),
        Positioned.fill(
          child: ColoredBox(
            color: Colors.black.withOpacity(0.18),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(mobile ? 20 : 38),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: AppTypography.label(
                  fontSize: 9,
                  letterSpacing: 1.9,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTypography.serif(
                  color: Colors.white,
                  fontSize: mobile ? 42 : 58,
                  height: 0.9,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              _HeroAction(
                label: actionLabel,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroAction extends StatefulWidget {
  const _HeroAction({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  State<_HeroAction> createState() => _HeroActionState();
}

class _HeroActionState extends State<_HeroAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: 190,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: AppTypography.label(
                      fontSize: 9.5,
                      letterSpacing: 1.55,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    offset: _hovered ? const Offset(0.18, 0) : Offset.zero,
                    child: const Text(
                      '→',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                width: _hovered ? 190 : 72,
                height: 1,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
