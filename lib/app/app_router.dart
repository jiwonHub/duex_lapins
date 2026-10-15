import 'package:deux_lapins/app/app_routes.dart';
import 'package:deux_lapins/app/app_shell.dart';
import 'package:deux_lapins/ui/account/account_page.dart';
import 'package:deux_lapins/ui/account/addresses_page.dart';
import 'package:deux_lapins/ui/account/order_detail_page.dart';
import 'package:deux_lapins/ui/account/orders_page.dart';
import 'package:deux_lapins/ui/account/profile_page.dart';
import 'package:deux_lapins/ui/account/settings_page.dart';
import 'package:deux_lapins/ui/inquiries/inquiries_page.dart';
import 'package:deux_lapins/ui/auth/kakao_callback_page.dart';
import 'package:deux_lapins/ui/auth/login_page.dart';
import 'package:deux_lapins/ui/auth/auth_gate.dart';
import 'package:deux_lapins/ui/cart/cart_page.dart';
import 'package:deux_lapins/ui/catalog/brands_page.dart';
import 'package:deux_lapins/ui/catalog/catalog_page.dart';
import 'package:deux_lapins/ui/catalog/home_page.dart';
import 'package:deux_lapins/ui/catalog/journal_page.dart';
import 'package:deux_lapins/ui/catalog/journal_detail_page.dart';
import 'package:deux_lapins/ui/catalog/product_detail_page.dart';
import 'package:deux_lapins/ui/catalog/search_page.dart';
import 'package:deux_lapins/ui/checkout/checkout_page.dart';
import 'package:deux_lapins/ui/checkout/order_complete_page.dart';
import 'package:deux_lapins/ui/wishlist/wishlist_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutePath.home,
  routes: [
    GoRoute(
      path: AppRoutePath.kakaoCallback,
      pageBuilder: (context, state) => _page(
        state,
        KakaoCallbackPage(
          code: state.uri.queryParameters['code'],
          error: state.uri.queryParameters['error'],
        ),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(
          currentSection: AppRoutePath.sectionFromUri(state.uri),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: AppRoutePath.home,
          pageBuilder: (context, state) => _page(
            state,
            const HomePage(),
          ),
        ),
        GoRoute(
          path: AppRoutePath.allItems,
          pageBuilder: (context, state) => _page(
            state,
            const CatalogPage(
              title: 'ALL PRODUCTS',
              mode: 'ALL',
            ),
          ),
        ),
        GoRoute(
          path: AppRoutePath.newItems,
          pageBuilder: (context, state) => _page(
            state,
            const CatalogPage(
              title: 'NEW ARRIVALS',
              mode: 'NEW',
            ),
          ),
        ),
        GoRoute(
          path: AppRoutePath.best,
          pageBuilder: (context, state) => _page(
            state,
            const CatalogPage(
              title: 'BEST SELLERS',
              mode: 'BEST',
            ),
          ),
        ),
        GoRoute(
          path: AppRoutePath.premium,
          pageBuilder: (context, state) => _page(
            state,
            const CatalogPage(
              title: 'PREMIUM',
              mode: 'PREMIUM',
            ),
          ),
        ),
        GoRoute(
          path: AppRoutePath.brands,
          pageBuilder: (context, state) => _page(
            state,
            const BrandsPage(),
          ),
        ),
        GoRoute(
          path: AppRoutePath.journal,
          pageBuilder: (context, state) => _page(
            state,
            const JournalPage(),
          ),
        ),
        GoRoute(
          path: '/journal/:journalId',
          pageBuilder: (context, state) => _page(
            state,
            JournalDetailPage(
              journalId: state.pathParameters['journalId']!,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutePath.search,
          pageBuilder: (context, state) => _page(
            state,
            const SearchPage(),
          ),
        ),
        GoRoute(
          path: '/product/:productId',
          pageBuilder: (context, state) => _page(
            state,
            ProductDetailPage(
              productId: state.pathParameters['productId'],
            ),
          ),
        ),
        GoRoute(
          path: AppRoutePath.wishlist,
          pageBuilder: (context, state) => _page(
            state,
            const WishlistPage(),
          ),
        ),
        GoRoute(
          path: AppRoutePath.cart,
          pageBuilder: (context, state) => _page(
            state,
            const CartPage(),
          ),
        ),
        GoRoute(
          path: AppRoutePath.checkout,
          pageBuilder: (context, state) => _page(
            state,
            const CheckoutPage(),
          ),
        ),
        GoRoute(
          path: AppRoutePath.orderComplete,
          pageBuilder: (context, state) => _page(
            state,
            const OrderCompletePage(),
          ),
        ),
        GoRoute(
          path: AppRoutePath.account,
          pageBuilder: (context, state) => _page(
            state,
            const AccountPage(),
          ),
        ),
        GoRoute(
          path: AppRoutePath.join,
          redirect: (context, state) => AppRoutePath.login,
        ),
        GoRoute(
          path: AppRoutePath.login,
          pageBuilder: (context, state) => _page(
            state,
            const LoginPage(),
          ),
        ),
        GoRoute(
          path: AppRoutePath.orders,
          pageBuilder: (context, state) => _page(
            state,
            const AuthGate(
              child: OrdersPage(),
            ),
          ),
        ),
        GoRoute(
          path: '/account/orders/:orderId',
          pageBuilder: (context, state) => _page(
            state,
            AuthGate(
              child: OrderDetailPage(
                orderId: state.pathParameters['orderId'],
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutePath.addresses,
          pageBuilder: (context, state) => _page(
            state,
            const AuthGate(
              child: AddressesPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutePath.profile,
          pageBuilder: (context, state) => _page(
            state,
            const AuthGate(
              child: ProfilePage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutePath.inquiries,
          pageBuilder: (context, state) => _page(
            state,
            AuthGate(
              child: InquiriesPage(
                productId: state.uri.queryParameters['product_id'],
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutePath.settings,
          pageBuilder: (context, state) => _page(
            state,
            const AuthGate(
              child: SettingsPage(),
            ),
          ),
        ),
      ],
    ),
  ],
  errorPageBuilder: (context, state) => _page(
    state,
    const HomePage(),
  ),
);

CustomTransitionPage<void> _page(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      final offset = Tween<Offset>(
        begin: const Offset(0, 0.008),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      );

      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offset,
            child: child,
          ),
        ),
      );
    },
  );
}
