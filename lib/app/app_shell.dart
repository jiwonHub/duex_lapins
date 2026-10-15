import 'package:deux_lapins/ui/shared/app_header.dart';
import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/ui/shared/app_sidebar.dart';
import 'package:deux_lapins/core/responsive/app_breakpoints.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.currentSection,
    required this.child,
  });

  final AppSection currentSection;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop =
            kIsWeb || constraints.maxWidth >= AppBreakpoints.desktop;

        if (desktop) {
          return Scaffold(
            body: Row(
              children: [
                AppSidebar(
                  currentSection: currentSection,
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: Column(
                    children: [
                      const AppHeader(mobile: false),
                      const Divider(height: 1),
                      Expanded(
                        child: ColoredBox(
                          color: AppTheme.background,
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          drawer: Builder(
            builder: (drawerContext) => Drawer(
              width: 272,
              shape: const RoundedRectangleBorder(),
              child: AppSidebar(
                currentSection: currentSection,
                closeDrawer: () => Navigator.of(drawerContext).pop(),
              ),
            ),
          ),
          body: Builder(
            builder: (scaffoldContext) => SafeArea(
              child: Column(
                children: [
                  AppHeader(
                    mobile: true,
                    onMenu: () => Scaffold.of(scaffoldContext).openDrawer(),
                  ),
                  const Divider(height: 1),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
          bottomNavigationBar: kIsWeb
              ? null
              : NavigationBar(
            height: 64,
            selectedIndex: _mobileIndex(currentSection),
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go(AppRoutePath.home);
                  break;
                case 1:
                  context.go(AppRoutePath.search);
                  break;
                case 2:
                  context.go(AppRoutePath.wishlist);
                  break;
                case 3:
                  context.go(AppRoutePath.cart);
                  break;
                case 4:
                  context.go(AppRoutePath.account);
                  break;
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: 'Saved',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: 'Bag',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Account',
              ),
            ],
          ),
        );
      },
    );
  }

  int _mobileIndex(AppSection section) {
    switch (section) {
      case AppSection.search:
        return 1;
      case AppSection.wishlist:
        return 2;
      case AppSection.cart:
      case AppSection.checkout:
      case AppSection.orderComplete:
        return 3;
      case AppSection.account:
      case AppSection.orders:
      case AppSection.orderDetail:
      case AppSection.addresses:
      case AppSection.profile:
      case AppSection.settings:
      case AppSection.inquiries:
        return 4;
      default:
        return 0;
    }
  }
}
