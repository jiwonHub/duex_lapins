import 'package:duex_lapins/core/config/kakao_config.dart';
import 'package:duex_lapins/data/repositories/account_repository_impl.dart';
import 'package:duex_lapins/data/repositories/cart_repository_impl.dart';
import 'package:duex_lapins/data/repositories/catalog_repository_impl.dart';
import 'package:duex_lapins/data/repositories/kakao_auth_repository_impl.dart';
import 'package:duex_lapins/data/repositories/wishlist_repository_impl.dart';
import 'package:duex_lapins/data/services/catalog_mock_data_source.dart';
import 'package:duex_lapins/domain/repositories/account_repository.dart';
import 'package:duex_lapins/domain/repositories/auth_repository.dart';
import 'package:duex_lapins/domain/repositories/cart_repository.dart';
import 'package:duex_lapins/domain/repositories/catalog_repository.dart';
import 'package:duex_lapins/domain/repositories/wishlist_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final catalogDataSourceProvider = Provider<CatalogMockDataSource>(
  (ref) => CatalogMockDataSourceImpl(),
);

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepositoryImpl(ref.read(catalogDataSourceProvider)),
);

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepositoryImpl(),
);

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepositoryImpl(),
);

final wishlistRepositoryProvider = Provider<WishlistRepository>(
  (ref) => WishlistRepositoryImpl(),
);

final kakaoConfigProvider = Provider<KakaoConfig>(
  (ref) => const KakaoConfig.empty(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => KakaoAuthRepositoryImpl(ref.read(kakaoConfigProvider)),
);
