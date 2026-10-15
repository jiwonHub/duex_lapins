import 'package:deux_lapins/core/config/kakao_config.dart';
import 'package:deux_lapins/data/repositories/account_repository_impl.dart';
import 'package:deux_lapins/data/repositories/cart_repository_impl.dart';
import 'package:deux_lapins/data/repositories/catalog_repository_impl.dart';
import 'package:deux_lapins/data/repositories/editorial_repository_impl.dart';
import 'package:deux_lapins/data/repositories/kakao_auth_repository_impl.dart';
import 'package:deux_lapins/data/repositories/order_repository_impl.dart';
import 'package:deux_lapins/data/repositories/inquiry_repository_impl.dart';
import 'package:deux_lapins/core/network/shared_mock_api_client.dart';
import 'package:deux_lapins/data/repositories/wishlist_repository_impl.dart';
import 'package:deux_lapins/data/services/catalog_mock_data_source.dart';
import 'package:deux_lapins/data/services/account_mock_api_data_source.dart';
import 'package:deux_lapins/data/services/shopping_mock_api_data_source.dart';
import 'package:deux_lapins/domain/repositories/account_repository.dart';
import 'package:deux_lapins/domain/repositories/auth_repository.dart';
import 'package:deux_lapins/domain/repositories/cart_repository.dart';
import 'package:deux_lapins/domain/repositories/catalog_repository.dart';
import 'package:deux_lapins/domain/repositories/editorial_repository.dart';
import 'package:deux_lapins/domain/repositories/order_repository.dart';
import 'package:deux_lapins/domain/repositories/inquiry_repository.dart';
import 'package:deux_lapins/domain/repositories/wishlist_repository.dart';
import 'package:deux_lapins/ui/auth/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final catalogDataSourceProvider = Provider<CatalogMockDataSource>(
  (ref) => CatalogMockDataSourceImpl(),
);

final editorialRepositoryProvider = Provider<EditorialRepository>(
      (ref) => EditorialRepositoryImpl(SharedMockApiClient.instance),
);

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepositoryImpl(ref.read(catalogDataSourceProvider)),
);

final shoppingMockApiDataSourceProvider = Provider<ShoppingMockApiDataSource>(
      (ref) => ShoppingMockApiDataSource(
    ref.read(catalogRepositoryProvider),
    ref.read(catalogDataSourceProvider),
    currentUserId: () => ref.read(authViewModelProvider).user?.id,
  ),
);

final cartRepositoryProvider = Provider<CartRepository>(
      (ref) => CartRepositoryImpl(
    ref.read(shoppingMockApiDataSourceProvider),
    ref.read(catalogRepositoryProvider),
  ),
);

final accountMockApiDataSourceProvider = Provider<AccountMockApiDataSource>(
      (ref) => AccountMockApiDataSource(),
);

final accountRepositoryProvider = Provider<AccountRepository>(
      (ref) => AccountRepositoryImpl(
    ref.read(accountMockApiDataSourceProvider),
    ref.read(orderRepositoryProvider),
  ),
);

final inquiryRepositoryProvider = Provider<InquiryRepository>(
      (ref) => InquiryRepositoryImpl(SharedMockApiClient.instance),
);

final orderRepositoryProvider = Provider<OrderRepository>(
      (ref) => OrderRepositoryImpl(ref.read(shoppingMockApiDataSourceProvider)),
);

final wishlistRepositoryProvider = Provider<WishlistRepository>(
      (ref) => WishlistRepositoryImpl(ref.read(shoppingMockApiDataSourceProvider)),
);

final kakaoConfigProvider = Provider<KakaoConfig>(
  (ref) => const KakaoConfig.empty(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => KakaoAuthRepositoryImpl(ref.read(kakaoConfigProvider)),
);
