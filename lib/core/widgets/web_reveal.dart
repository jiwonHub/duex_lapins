import 'dart:async';

import 'package:deux_lapins/core/responsive/app_breakpoints.dart';
import 'package:deux_lapins/core/utils/effective_scroll_position.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebReveal extends StatefulWidget {
  const WebReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 760),
    this.offset = 30,
    this.scaleFrom = 0.995,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offset;
  final double scaleFrom;

  @override
  State<WebReveal> createState() => _WebRevealState();
}

class _WebRevealState extends State<WebReveal>
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
  void didUpdateWidget(covariant WebReveal oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _bindScrollPosition();
      _checkVisibility();
    });
  }

  void _bindScrollPosition() {
    final nextPosition = findEffectiveVerticalScrollPosition(context);

    if (nextPosition == _scrollPosition) {
      return;
    }

    _scrollPosition?.removeListener(_checkVisibility);
    _scrollPosition = nextPosition;
    _scrollPosition?.addListener(_checkVisibility);
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

    if (top <= viewportHeight * 0.94 && bottom >= 0) {
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

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - value)),
            child: Transform.scale(
              alignment: Alignment.center,
              scale: widget.scaleFrom + ((1 - widget.scaleFrom) * value),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
