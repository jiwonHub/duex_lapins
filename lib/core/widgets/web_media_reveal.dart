import 'dart:async';

import 'package:duex_lapins/core/responsive/app_breakpoints.dart';
import 'package:duex_lapins/core/utils/effective_scroll_position.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebMediaReveal extends StatefulWidget {
  const WebMediaReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 900),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  @override
  State<WebMediaReveal> createState() => _WebMediaRevealState();
}

class _WebMediaRevealState extends State<WebMediaReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ScrollPosition? _scrollPosition;
  Timer? _delayTimer;
  bool _started = false;

  bool get _enabled {
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
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
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
        _scrollPosition?.removeListener(_checkVisibility);
        _scrollPosition = nextPosition;
        _scrollPosition?.addListener(_checkVisibility);
      }

      _checkVisibility();
    });
  }

  void _checkVisibility() {
    if (_started || !_enabled || !mounted) {
      return;
    }

    final renderObject = context.findRenderObject();

    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final viewportHeight = MediaQuery.sizeOf(context).height;
    final top = renderObject.localToGlobal(Offset.zero).dy;
    final bottom = top + renderObject.size.height;

    if (top <= viewportHeight * 0.93 && bottom >= 0) {
      _started = true;
      _scrollPosition?.removeListener(_checkVisibility);

      _delayTimer = Timer(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _scrollPosition?.removeListener(_checkVisibility);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final value = Curves.easeOutQuart.transform(_controller.value);

        return ClipRect(
          clipper: _VerticalRevealClipper(value),
          child: Transform.scale(
            alignment: Alignment.center,
            scale: 1.045 - (0.045 * value),
            child: child,
          ),
        );
      },
    );
  }
}

class _VerticalRevealClipper extends CustomClipper<Rect> {
  const _VerticalRevealClipper(this.progress);

  final double progress;

  @override
  Rect getClip(Size size) {
    final value = progress.clamp(0.0, 1.0).toDouble();

    return Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height * value,
    );
  }

  @override
  bool shouldReclip(covariant _VerticalRevealClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}
