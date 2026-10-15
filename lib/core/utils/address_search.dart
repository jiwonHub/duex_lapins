import 'package:flutter/material.dart';

import 'address_search_result.dart';
import 'address_search_stub.dart'
if (dart.library.js_interop) 'address_search_web.dart'
as implementation;

export 'address_search_result.dart';

Future<AddressSearchResult?> searchKoreanAddress(BuildContext context) {
  return implementation.searchKoreanAddress(context);
}