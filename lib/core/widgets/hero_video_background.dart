import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:deux_lapins/core/widgets/app_image.dart';
import 'package:flutter/material.dart';

/// Flutter Web 전용. 관리자에서 등록한 동영상을 배경으로 반복 재생한다.
class HeroVideoBackground extends StatefulWidget {
  const HeroVideoBackground({super.key, required this.url, required this.fallbackImageUrl});

  final String url;
  final String fallbackImageUrl;

  @override
  State<HeroVideoBackground> createState() => _HeroVideoBackgroundState();
}

class _HeroVideoBackgroundState extends State<HeroVideoBackground> {
  static int _nextId = 0;
  late final String _viewType;
  late final html.VideoElement _video;

  @override
  void initState() {
    super.initState();
    _viewType = 'deux-hero-video-${_nextId++}';
    _video = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..loop = true
      ..controls = false
      ..preload = 'metadata'
      ..src = widget.url;
    _video.setAttribute('playsinline', '');
    _video.style
      ..width = '100%'
      ..height = '100%'
      ..pointerEvents = 'none'
      ..display = 'block';
    _video.style.setProperty('object-fit', 'cover');
    _video.onError.listen((_) => _video.style.display = 'none');
    _video.onCanPlay.listen((_) => _video.style.display = 'block');
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) => _video);
  }

  @override
  void didUpdateWidget(covariant HeroVideoBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _video.src = widget.url;
      _video.load();
    }
  }

  @override
  void dispose() {
    _video.pause();
    _video.removeAttribute('src');
    _video.load();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      AppImage(url: widget.fallbackImageUrl),
      HtmlElementView(viewType: _viewType),
    ],
  );
}