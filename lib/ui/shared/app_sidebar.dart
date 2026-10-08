import 'package:duex_lapins/app/app_routes.dart';
import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:duex_lapins/ui/catalog/catalog_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({
    super.key,
    required this.currentSection,
    this.closeDrawer,
  });

  final AppSection currentSection;
  final VoidCallback? closeDrawer;

  static const _shopCategories = [
    'TOP',
    'SHIRTS',
    'PANTS',
    'OUTER',
    'SET',
    'ACC',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogViewModelProvider);
    void open(AppSection section, {String category = 'ALL'}) {
      ref.read(catalogViewModelProvider.notifier).selectCategory(category);
      context.go(AppRoutePath.forSection(section));
      closeDrawer?.call();
    }

    Widget menu(
        String text,
        AppSection section, {
          String category = 'ALL',
        }) {
      return _SidebarMenuItem(
        text: text,
        selected: currentSection == section,
        onTap: () => open(section, category: category),
      );
    }

    Widget categoryMenu(AppSection section) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 14,
          top: 2,
          bottom: 6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _shopCategories.map((category) {
            return _SidebarSubMenuItem(
              text: category,
              selected:
              currentSection == section && catalog.category == category,
              onTap: () => open(
                section,
                category: category,
              ),
            );
          }).toList(),
        ),
      );
    }

    return SafeArea(
      child: Container(
        width: 244,
        padding: const EdgeInsets.fromLTRB(30, 31, 26, 26),
        color: AppTheme.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => open(AppSection.home),
              child: SizedBox(
                width: double.infinity,
                height: 96,
                child: Image.asset(
                  'assets/images/duex_lapins_logo2.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'MODERN HERITAGE  /  EST. 2026',
              style: AppTypography.label(
                fontSize: 8,
                letterSpacing: 1.35,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 31),
            const Divider(height: 1),
            const SizedBox(height: 21),
            _groupLabel('SHOP'),
            const SizedBox(height: 7),
            menu('NEW', AppSection.newItems),
            menu('BEST', AppSection.best),
            if (currentSection == AppSection.best)
              categoryMenu(AppSection.best),
            menu('PREMIUM', AppSection.premium),
            if (currentSection == AppSection.premium)
              categoryMenu(AppSection.premium),
            const SizedBox(height: 23),
            _groupLabel('DISCOVER'),
            const SizedBox(height: 7),
            menu('BRANDS', AppSection.brands),
            menu('CURATION', AppSection.home),
            menu('JOURNAL', AppSection.journal),
            const Spacer(),
            const Divider(height: 1),
            const SizedBox(height: 18),
            Text(
              'REFINED UTILITY  ×  SUBTLE STREET',
              style: AppTypography.label(
                fontSize: 7.5,
                letterSpacing: 1.05,
                color: AppTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupLabel(String value) {
    return Text(
      value,
      style: AppTypography.label(
        fontSize: 8.5,
        letterSpacing: 1.65,
        color: AppTheme.muted,
      ),
    );
  }
}

class _SidebarMenuItem extends StatefulWidget {
  const _SidebarMenuItem({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SidebarMenuItem> createState() => _SidebarMenuItemState();
}

class _SidebarMenuItemState extends State<_SidebarMenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7.5),
          child: Row(
            children: [
              Expanded(
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  offset: active ? const Offset(0.018, 0) : Offset.zero,
                  child: Text(
                    widget.text,
                    style: AppTypography.label(
                      fontSize: 11,
                      letterSpacing: 1.55,
                      fontWeight: widget.selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: active ? 26 : 0,
                height: 1,
                color: AppTheme.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarSubMenuItem extends StatefulWidget {
  const _SidebarSubMenuItem({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SidebarSubMenuItem> createState() => _SidebarSubMenuItemState();
}

class _SidebarSubMenuItemState extends State<_SidebarSubMenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            offset: active ? const Offset(0.018, 0) : Offset.zero,
            child: Text(
              widget.text,
              style: AppTypography.label(
                fontSize: 9,
                letterSpacing: 1.35,
                color: widget.selected ? AppTheme.text : AppTheme.muted,
                fontWeight:
                widget.selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
