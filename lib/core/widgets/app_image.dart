import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.aspectRatio,
  });

  final String url;
  final BoxFit fit;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }

        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return const ColoredBox(
          color: AppTheme.soft,
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: AppTheme.soft,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 30,
            ),
            SizedBox(height: 8),
            Text(
              '이미지를 불러올 수 없습니다',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );

    if (aspectRatio == null) {
      return image;
    }

    return AspectRatio(
      aspectRatio: aspectRatio!,
      child: image,
    );
  }
}
