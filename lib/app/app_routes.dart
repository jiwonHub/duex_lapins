enum AppSection {
  home,
  allItems,
  newItems,
  best,
  premium,
  brands,
  journal,
  search,
  productDetail,
  wishlist,
  cart,
  checkout,
  orderComplete,
  account,
  orders,
  orderDetail,
  addresses,
  profile,
  settings,
  inquiries,
}

class AppRoutePath {
  const AppRoutePath._();

  static const String home = '/';
  static const String allItems = '/all';
  static const String newItems = '/new';
  static const String best = '/best';
  static const String premium = '/premium';
  static const String brands = '/brands';
  static const String journal = '/journal';

  static String journalDetail(String id) =>
      '/journal/${Uri.encodeComponent(id)}';
  static const String search = '/search';
  static const String wishlist = '/wishlist';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderComplete = '/order-complete';
  static const String account = '/account';
  static const String join = '/join';
  static const String login = '/login';
  static const String orders = '/account/orders';
  static const String addresses = '/account/addresses';
  static const String profile = '/account/profile';
  static const String settings = '/account/settings';
  static const String inquiries = '/account/inquiries';
  static const String kakaoCallback = '/auth/kakao/callback';

  static String product(String productId) => '/product/$productId';

  static String orderDetail(String orderId) => '/account/orders/$orderId';

  static String forSection(AppSection section) {
    switch (section) {
      case AppSection.home:
        return home;
      case AppSection.allItems:
        return allItems;
      case AppSection.newItems:
        return newItems;
      case AppSection.best:
        return best;
      case AppSection.premium:
        return premium;
      case AppSection.brands:
        return brands;
      case AppSection.journal:
        return journal;
      case AppSection.search:
        return search;
      case AppSection.wishlist:
        return wishlist;
      case AppSection.cart:
        return cart;
      case AppSection.checkout:
        return checkout;
      case AppSection.orderComplete:
        return orderComplete;
      case AppSection.account:
        return account;
      case AppSection.orders:
        return orders;
      case AppSection.addresses:
        return addresses;
      case AppSection.profile:
        return profile;
      case AppSection.settings:
        return settings;
      case AppSection.inquiries:
        return inquiries;
      case AppSection.productDetail:
      case AppSection.orderDetail:
        return home;
    }
  }

  static AppSection sectionFromUri(Uri uri) {
    final path = uri.path;

    if (path.startsWith('/journal/')) {
      return AppSection.journal;
    }

    if (path.startsWith('/product/')) {
      return AppSection.productDetail;
    }

    if (path.startsWith('/account/orders/')) {
      return AppSection.orderDetail;
    }

    switch (path) {
      case home:
        return AppSection.home;
      case allItems:
        return AppSection.allItems;
      case newItems:
        return AppSection.newItems;
      case best:
        return AppSection.best;
      case premium:
        return AppSection.premium;
      case brands:
        return AppSection.brands;
      case journal:
        return AppSection.journal;
      case search:
        return AppSection.search;
      case wishlist:
        return AppSection.wishlist;
      case cart:
        return AppSection.cart;
      case checkout:
        return AppSection.checkout;
      case orderComplete:
        return AppSection.orderComplete;
      case account:
      case join:
      case login:
        return AppSection.account;
      case orders:
        return AppSection.orders;
      case addresses:
        return AppSection.addresses;
      case profile:
        return AppSection.profile;
      case settings:
        return AppSection.settings;
      case inquiries:
        return AppSection.inquiries;
      default:
        return AppSection.home;
    }
  }
}
