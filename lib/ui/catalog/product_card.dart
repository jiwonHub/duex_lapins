import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/core/responsive/app_breakpoints.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:deux_lapins/core/theme/app_typography.dart';
import 'package:deux_lapins/core/utils/price_formatter.dart';
import 'package:deux_lapins/core/widgets/app_image.dart';
import 'package:deux_lapins/domain/models/product.dart';
import 'package:deux_lapins/ui/auth/auth_view_model.dart';
import 'package:deux_lapins/ui/wishlist/wishlist_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final wishlistState = ref.watch(wishlistViewModelProvider);
    final auth = ref.watch(authViewModelProvider);
    final wished = wishlistState.contains(widget.product.id);
    final wishlistBusy = wishlistState.loading || wishlistState.saving;
    final mediaQuery = MediaQuery.maybeOf(context);
    final webHover = kIsWeb &&
        mediaQuery != null &&
        mediaQuery.size.width >= AppBreakpoints.desktop &&
        !mediaQuery.disableAnimations;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (webHover) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (webHover) {
          setState(() => _hovered = false);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push(
          AppRoutePath.product(widget.product.id),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRect(
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 520),
                      curve: Curves.easeOutCubic,
                      scale: webHover && _hovered ? 1.025 : 1,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AppImage(
                            url: widget.product.imageUrl,
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 430),
                            curve: Curves.easeOutCubic,
                            opacity: webHover && _hovered ? 1 : 0,
                            child: AppImage(
                              url: widget.product.hoverImageUrl,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (auth.isLoggedIn)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IgnorePointer(
                      ignoring: webHover && !_hovered && !wished,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 170),
                        opacity: webHover
                            ? (_hovered || wished ? 1 : 0)
                            : 1,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: wishlistBusy
                              ? null
                              : () async {
                            try {
                              await ref
                                  .read(wishlistViewModelProvider.notifier)
                                  .toggle(widget.product.id);
                            } catch (error) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '위시리스트 변경 실패: $error',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            wished
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                            size: 18,
                            shadows: const [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.product.isNew || widget.product.isBest)
                    Positioned(
                      left: 11,
                      top: 12,
                      child: Text(
                        widget.product.isNew ? 'NEW' : 'BEST',
                        style: AppTypography.label(
                          fontSize: 8.5,
                          letterSpacing: 1.45,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ).copyWith(
                          shadows: const [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (webHover)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 190),
                          opacity: _hovered ? 1 : 0,
                          child: AnimatedSlide(
                            duration: const Duration(milliseconds: 230),
                            curve: Curves.easeOutCubic,
                            offset: _hovered
                                ? Offset.zero
                                : const Offset(0, 0.10),
                            child: Row(
                              children: [
                                Text(
                                  '상품 보기',
                                  style: AppTypography.label(
                                    fontSize: 8.5,
                                    letterSpacing: 1.35,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ).copyWith(
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black45,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.74),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '+',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSlide(
              duration: const Duration(milliseconds: 230),
              curve: Curves.easeOutCubic,
              offset: webHover && _hovered
                  ? const Offset(0, -0.018)
                  : Offset.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.serif(
                            fontSize: 18,
                            height: 0.98,
                            letterSpacing: 0.15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        turns: webHover && _hovered ? 0.125 : 0,
                        child: const Text(
                          '+',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.product.brand,
                    style: AppTypography.label(
                      fontSize: 8.5,
                      letterSpacing: 1.25,
                      color: AppTheme.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(widget.product.price),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
