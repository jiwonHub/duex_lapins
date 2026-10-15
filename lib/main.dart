import 'package:deux_lapins/app/app.dart';
import 'package:deux_lapins/core/config/kakao_config.dart';
import 'package:deux_lapins/core/di/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  final kakaoConfig = await KakaoConfig.load();

  if (kakaoConfig.hasNativeKey || kakaoConfig.hasJavaScriptKey) {
    try {
      await KakaoSdk.init(
        nativeAppKey:
        kakaoConfig.hasNativeKey ? kakaoConfig.nativeAppKey : null,
        javaScriptAppKey:
        kakaoConfig.hasJavaScriptKey ? kakaoConfig.javaScriptAppKey : null,
      ).timeout(const Duration(seconds: 10));

      debugPrint('[STARTUP] Kakao SDK initialized');
    } catch (error, stackTrace) {
      debugPrint('[STARTUP] Kakao SDK initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  debugPrint('[STARTUP] runApp');

  runApp(
    ProviderScope(
      overrides: [
        kakaoConfigProvider.overrideWithValue(kakaoConfig),
      ],
      child: const DuexLapinsApp(),
    ),
  );
}
