import 'package:deux_lapins/domain/models/product.dart';

/// 상품 상세에서 선택한 옵션과 수량. 장바구니 저장 전에는 서버 상태를 변경하지 않는다.
class SelectedProductOption {
  const SelectedProductOption({
    required this.variant,
    required this.quantity,
  });

  final ProductVariant variant;
  final int quantity;

  String get variantId => variant.id;
}