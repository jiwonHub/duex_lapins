import 'dart:convert';

import 'package:flutter/services.dart';

class KakaoConfig {
  const KakaoConfig({
    required this.nativeAppKey,
    required this.javaScriptAppKey,
    required this.webRedirectUri,
    required this.webExchangeEndpoint,
    required this.webSessionEndpoint,
    required this.webLogoutEndpoint,
  });

  const KakaoConfig.empty()
      : nativeAppKey = '',
        javaScriptAppKey = '',
        webRedirectUri = '',
        webExchangeEndpoint = '',
        webSessionEndpoint = '',
        webLogoutEndpoint = '';

  final String nativeAppKey;
  final String javaScriptAppKey;
  final String webRedirectUri;
  final String webExchangeEndpoint;
  final String webSessionEndpoint;
  final String webLogoutEndpoint;

  bool get hasNativeKey => nativeAppKey.trim().isNotEmpty;

  bool get hasJavaScriptKey => javaScriptAppKey.trim().isNotEmpty;

  bool get canStartWebLogin =>
      hasJavaScriptKey && webRedirectUri.trim().isNotEmpty;

  bool get canCompleteWebLogin =>
      canStartWebLogin && webExchangeEndpoint.trim().isNotEmpty;

  static Future<KakaoConfig> load() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/config/kakao_config.json',
      );
      final decoded = jsonDecode(raw);

      if (decoded is! Map<String, dynamic>) {
        return const KakaoConfig.empty();
      }

      return KakaoConfig(
        nativeAppKey: _readString(decoded, 'nativeAppKey'),
        javaScriptAppKey: _readString(decoded, 'javaScriptAppKey'),
        webRedirectUri: _readString(decoded, 'webRedirectUri'),
        webExchangeEndpoint: _readString(decoded, 'webExchangeEndpoint'),
        webSessionEndpoint: _readString(decoded, 'webSessionEndpoint'),
        webLogoutEndpoint: _readString(decoded, 'webLogoutEndpoint'),
      );
    } catch (_) {
      return const KakaoConfig.empty();
    }
  }

  static String _readString(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    return value is String ? value.trim() : '';
  }
}
