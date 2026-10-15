import 'package:deux_lapins/core/responsive/app_breakpoints.dart';
import 'package:deux_lapins/core/utils/effective_scroll_position.dart';
import 'package:deux_lapins/core/widgets/app_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebParallaxMedia extends StatefulWidget {
  const WebParallaxMedia({
    super.key,
    required this.url,
    required this.aspectRatio,
    this.strength = 34,
    this.scale = 1.10,
  });

  final String url;
  final double aspectRatio;
  final double strength;
  final double scale;

  @override
  State<WebParallaxMedia> createState() => _WebParallaxMediaState();
}

class _WebParallaxMediaState extends State<WebParallaxMedia> {
  ScrollPosition? _scrollPosition;
  double _offset = 0;

  bool get _enabled {
    final mediaQuery = MediaQuery.maybeOf(context);

    if (!kIsWeb || mediaQuery == null) {
      return false;
    }

    return mediaQuery.size.width >= AppBreakpoints.desktop &&
        !mediaQuery.disableAnimations;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _bindScrollPosition();
      _updateOffset();
    });
  }

  void _bindScrollPosition() {
    final nextPosition = findEffectiveVerticalScrollPosition(context);

    if (nextPosition == _scrollPosition) {
      return;
    }

    _scrollPosition?.removeListener(_updateOffset);
    _scrollPosition = nextPosition;
    _scrollPosition?.addListener(_updateOffset);
  }

  void _updateOffset() {
    if (!_enabled || !mounted) {
      return;
    }

    final renderObject = context.findRenderObject();

    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final viewportHeight = MediaQuery.sizeOf(context).height;
    final top = renderObject.localToGlobal(Offset.zero).dy;
    final center = top + (renderObject.size.height / 2);
    final normalized = ((center - (viewportHeight / 2)) / viewportHeight)
        .clamp(-1.0, 1.0)
        .toDouble();
    final next = -normalized * widget.strength;

    if ((_offset - next).abs() < 0.15) {
      return;
    }

    setState(() {
      _offset = next;
    });
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_updateOffset);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled) {
      return AppImage(
        url: widget.url,
        aspectRatio: widget.aspectRatio,
      );
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: ClipRect(
        child: Transform.translate(
          offset: Offset(0, _offset),
          child: Transform.scale(
            scale: widget.scale,
            child: AppImage(
              url: widget.url,
            ),
          ),
        ),
      ),
    );
  }
}
