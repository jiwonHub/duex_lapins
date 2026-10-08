import 'package:duex_lapins/app/app.dart';
import 'package:duex_lapins/core/config/kakao_config.dart';
import 'package:duex_lapins/core/di/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final kakaoConfig = await KakaoConfig.load();

  if (kakaoConfig.hasNativeKey || kakaoConfig.hasJavaScriptKey) {
    await KakaoSdk.init(
      nativeAppKey:
          kakaoConfig.hasNativeKey ? kakaoConfig.nativeAppKey : null,
      javaScriptAppKey:
          kakaoConfig.hasJavaScriptKey ? kakaoConfig.javaScriptAppKey : null,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        kakaoConfigProvider.overrideWithValue(kakaoConfig),
      ],
      child: const DuexLapinsApp(),
    ),
  );
}
