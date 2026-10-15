import 'dart:convert';

import 'package:deux_lapins/core/network/shared_mock_api_client.dart';
import 'package:deux_lapins/data/models/product_model.dart';

abstract class CatalogMockDataSource {
  Future<Map<String, dynamic>> request(String method, String path);
  Future<void> deductStock(Map<String, int> quantities);
}

class CatalogMockDataSourceImpl implements CatalogMockDataSource {
  // 한 DataSource 인스턴스에서 목록/상세가 같은 JSON 원본을 조회한다.
  late final Future<List<Map<String, dynamic>>> _records = _seed();

  Future<List<Map<String, dynamic>>> _seed() async {
    final products = await getProducts();
    return products.map((product) {
      final row = product.toJson();
      row['variants'] = [
        for (final color in product.colors)
          for (final size in product.sizes)
            {
              'id': '${product.id}:${color.trim().toUpperCase()}:${size.trim().toUpperCase()}',
              'product_id': product.id,
              'color_name': color,
              'size_name': size,
              'stock_quantity': product.id == 'p05' ||
                  (product.id == 'p01' && color == 'Black' && size == 'XS')
                  ? 0
                  : (product.id == 'p03' && color == 'White' && size == 'S'
                  ? 2
                  : 8),
              'low_stock_threshold': 3,
              'is_active': true,
            },
      ];
      return row;
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> request(String method, String path) async {
    if (SharedMockApiClient.enabled) {
      return SharedMockApiClient.instance.request(
        method,
        '/shop$path',
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 80));
    final records = await _records;
    final segments = Uri.parse(path).pathSegments;

    Map<String, dynamic> response;
    if (method.toUpperCase() != 'GET') {
      response = {
        'success': false,
        'error': {'code': 'METHOD_NOT_ALLOWED', 'message': '지원하지 않는 요청입니다.'},
      };
    } else if (path == '/products') {
      response = {'success': true, 'data': records.where(_isPublic).toList()};
    } else if (segments.length == 2 && segments.first == 'products') {
      Map<String, dynamic>? result;
      for (final record in records) {
        if (record['id'] == segments[1] && _isPublic(record)) {
          result = record;
          break;
        }
      }
      response = result == null
          ? {
        'success': false,
        'error': {'code': 'NOT_FOUND', 'message': '상품을 찾을 수 없습니다.'},
      }
          : {'success': true, 'data': result};
    } else {
      response = {
        'success': false,
        'error': {'code': 'NOT_FOUND', 'message': 'API 경로가 존재하지 않습니다.'},
      };
    }

    // HTTP 응답과 같은 직렬화 경계를 통과시킨다.
    return (jsonDecode(jsonEncode(response)) as Map<String, dynamic>);
  }

  @override
  Future<void> deductStock(Map<String, int> quantities) async {
    final products = await _records;
    final matched = <String, Map<String, dynamic>>{};
    for (final product in products) {
      if (!_isPublic(product) || product['sale_status'] != 'selling') continue;
      for (final raw in (product['variants'] as List<dynamic>)) {
        final variant = raw as Map<String, dynamic>;
        matched[variant['id'] as String] = variant;
      }
    }
    // 먼저 전 옵션을 검증한 뒤 한 번에 차감한다.
    for (final entry in quantities.entries) {
      final variant = matched[entry.key];
      if (entry.value <= 0 || variant == null ||
          variant['is_active'] != true ||
          (variant['stock_quantity'] as int) < entry.value) {
        throw StateError('상품 옵션의 재고가 부족하거나 판매할 수 없습니다: ${entry.key}');
      }
    }
    for (final entry in quantities.entries) {
      final variant = matched[entry.key]!;
      variant['stock_quantity'] = (variant['stock_quantity'] as int) - entry.value;
    }
  }

  bool _isPublic(Map<String, dynamic> record) =>
      record['publish_status'] == 'published' &&
          record['sale_status'] != 'hidden';

  Future<List<ProductModel>> getProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return const [
      ProductModel(
        id: 'p01',
        brand: 'DUEX LAPINS',
        name: 'Structured Wool Coat',
        category: 'OUTER',
        price: 489000,
        isNew: true,
        isPremium: true,
        imageUrl: 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=1400&q=90',
        hoverImageUrl: 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=format&fit=crop&w=1400&q=90',
        description: '정돈된 숄더 라인과 여유로운 볼륨, 절제된 디테일이 특징인 울 코트입니다.',
        colors: ['Black', 'Taupe', 'Ivory'],
        sizes: ['XS', 'S', 'M', 'L'],
      ),
      ProductModel(
        id: 'p02',
        brand: 'DUEX LAPINS',
        name: 'Fluid Tailored Jacket',
        category: 'OUTER',
        price: 329000,
        isBest: true,
        isPremium: true,
        imageUrl: 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=1400&q=90',
        hoverImageUrl: 'https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?auto=format&fit=crop&w=1400&q=90',
        description: '유연하게 떨어지는 드레이프와 히든 여밈, 길게 뻗은 비율이 특징인 여유로운 테일러드 재킷입니다.',
        colors: ['Black', 'Stone'],
        sizes: ['S', 'M', 'L'],
      ),
      ProductModel(
        id: 'p03',
        brand: 'DUEX LAPINS',
        name: 'Soft Cotton Shirt',
        category: 'SHIRTS',
        price: 159000,
        isNew: true,
        isBest: true,
        imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=1400&q=90',
        hoverImageUrl: 'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1400&q=90',
        description: '드롭 숄더와 자연스러운 곡선형 밑단으로 완성한 가벼운 코튼 셔츠입니다.',
        colors: ['White', 'Blue', 'Charcoal'],
        sizes: ['XS', 'S', 'M', 'L'],
      ),
      ProductModel(
        id: 'p04',
        brand: 'DUEX LAPINS',
        name: 'Wide Pleated Trousers',
        category: 'PANTS',
        price: 219000,
        isBest: true,
        imageUrl: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=1400&q=90',
        hoverImageUrl: 'https://images.unsplash.com/photo-1485968579580-b6d095142e6e?auto=format&fit=crop&w=1400&q=90',
        description: '부드러운 프런트 플리츠와 하이 라이즈, 절제된 테일러링이 특징인 와이드 팬츠입니다.',
        colors: ['Black', 'Graphite', 'Sand'],
        sizes: ['S', 'M', 'L'],
      ),
      ProductModel(
        id: 'p05',
        brand: 'DUEX LAPINS',
        name: 'Leather Shoulder Bag',
        category: 'ACC',
        price: 379000,
        isBest: true,
        isPremium: true,
        imageUrl: 'https://images.unsplash.com/photo-1559563458-527698bf5295?auto=format&fit=crop&w=1400&q=90',
        hoverImageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1400&q=90',
        description: '몸에 자연스럽게 밀착되는 실루엣과 최소한의 하드웨어로 완성한 소프트 레더 숄더백입니다.',
        colors: ['Black', 'Dark Brown'],
        sizes: ['ONE SIZE'],
      ),
      ProductModel(
        id: 'p06',
        brand: 'DUEX LAPINS',
        name: 'Minimal Leather Shoes',
        category: 'ACC',
        price: 289000,
        isPremium: true,
        imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=1400&q=90',
        hoverImageUrl: 'https://images.unsplash.com/photo-1560343090-f0409e92791a?auto=format&fit=crop&w=1400&q=90',
        description: '낮은 프로파일의 솔과 톤온톤 스티치로 정제된 인상을 완성한 레더 슈즈입니다.',
        colors: ['Black', 'Brown'],
        sizes: ['250', '260', '270', '280'],
      ),
      ProductModel(
        id: 'p07',
        brand: 'DUEX LAPINS',
        name: 'Fine Gauge Knit',
        category: 'TOP',
        price: 189000,
        isBest: true,
        imageUrl: 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?auto=format&fit=crop&w=1400&q=90',
        hoverImageUrl: 'https://images.unsplash.com/photo-1581044777550-4cfa60707c03?auto=format&fit=crop&w=1400&q=90',
        description: '부드러운 촉감과 탄탄한 립 마감, 살짝 길게 떨어지는 소매가 특징인 파인 게이지 니트입니다.',
        colors: ['Black', 'Grey', 'Cream'],
        sizes: ['S', 'M', 'L'],
      ),
      ProductModel(
        id: 'p08',
        brand: 'DUEX LAPINS',
        line: 'work',
        name: 'Relaxed Denim',
        category: 'PANTS',
        price: 179000,
        isNew: true,
        imageUrl: 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=1400&q=90',
        hoverImageUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=1400&q=90',
        description: '자연스러운 워싱과 깔끔한 허리 마감으로 완성한 여유로운 스트레이트 데님입니다.',
        colors: ['Indigo', 'Washed Black'],
        sizes: ['28', '30', '32', '34'],
      ),
      ProductModel(
        id: 'p09',
        brand: 'DUEX LAPINS',
        line: 'work',
        name: 'Utility Layered Set',
        category: 'SET',
        price: 548000,
        isNew: true,
        isPremium: true,
        imageUrl:
        'https://images.unsplash.com/photo-1445205170230-053b83016050?auto=format&fit=crop&w=1400&q=90',
        hoverImageUrl:
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=1400&q=90',
        description: '아우터와 팬츠의 비율을 하나의 실루엣으로 설계한 레이어드 셋업입니다.',
        colors: ['Black', 'Charcoal'],
        sizes: ['S', 'M', 'L'],
      ),
    ];
  }
}
