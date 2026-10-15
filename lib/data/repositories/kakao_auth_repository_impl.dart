import 'dart:async';
import 'dart:convert';

import 'package:deux_lapins/core/config/kakao_config.dart';
import 'package:deux_lapins/core/network/kakao_http_client.dart';
import 'package:deux_lapins/domain/models/auth_user.dart';
import 'package:deux_lapins/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_auth/kakao_flutter_sdk_auth.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoAuthRepositoryImpl implements AuthRepository {
  const KakaoAuthRepositoryImpl(this._config);

  final KakaoConfig _config;
  static final http.Client _webClient = createKakaoHttpClient();

  @override
  Future<AuthUser?> restoreSession() async {
    if (kIsWeb) {
      if (!_config.hasJavaScriptKey || _config.webSessionEndpoint.isEmpty) {
        return null;
      }

      try {
        final response = await _webClient.get(
          Uri.parse(_config.webSessionEndpoint),
          headers: const {
            'Accept': 'application/json',
          },
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          return null;
        }

        return _authUserFromResponse(response.body);
      } catch (_) {
        return null;
      }
    }

    if (!_config.hasNativeKey) {
      return null;
    }

    if (!await AuthApi.instance.hasToken()) {
      return null;
    }

    try {
      await UserApi.instance.accessTokenInfo();
      final user = await UserApi.instance.me();
      return _authUserFromKakao(user);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthUser?> signInWithKakao() async {
    if (kIsWeb) {
      if (!_config.canStartWebLogin) {
        throw StateError('카카오 웹 로그인 설정이 완료되지 않았습니다.');
      }

      await AuthCodeClient.instance.authorize(
        redirectUri: _config.webRedirectUri,
      );

      return null;
    }

    if (!_config.hasNativeKey) {
      throw StateError('카카오 네이티브 앱 키가 설정되지 않았습니다.');
    }

    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
      } catch (_) {
        await UserApi.instance.loginWithKakaoAccount();
      }
    } else {
      await UserApi.instance.loginWithKakaoAccount();
    }

    final user = await UserApi.instance.me();
    return _authUserFromKakao(user);
  }

  @override
  Future<AuthUser?> completeWebKakaoLogin(String code) async {
    if (!kIsWeb) {
      return null;
    }

    if (!_config.canCompleteWebLogin) {
      throw StateError(
        '웹 로그인 토큰 교환 서버 주소가 설정되지 않았습니다.',
      );
    }

    final exchangeUri = Uri.parse(
      _config.webExchangeEndpoint,
    );

    if (Uri.base.host != 'localhost' &&
        Uri.base.host != '127.0.0.1' &&
        (exchangeUri.host == 'localhost' ||
            exchangeUri.host == '127.0.0.1')) {
      throw StateError(
        '배포된 웹에서는 localhost 카카오 로그인 서버를 사용할 수 없습니다.',
      );
    }

    late final http.Response response;

    try {
      response = await _webClient
          .post(
        exchangeUri,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'code': code,
          'redirectUri': _config.webRedirectUri,
        }),
      )
          .timeout(
        const Duration(seconds: 10),
      );
    } on TimeoutException {
      throw StateError(
        '카카오 로그인 서버 응답 시간이 초과되었습니다.',
      );
    } catch (_) {
      throw StateError(
        '카카오 로그인 서버에 연결할 수 없습니다.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      var message = '카카오 로그인 처리에 실패했습니다.';
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final error = data['error'];
        if (error is Map && error['message'] is String) {
          message = error['message'] as String;
        }
      } catch (_) {
        // 오류 응답이 JSON이 아니면 기본 메시지를 사용한다.
      }
      throw StateError('$message (${response.statusCode})');
    }

    final user = _authUserFromResponse(response.body);

    if (user == null) {
      throw StateError('서버 응답에서 사용자 정보를 확인할 수 없습니다.');
    }

    // 로그인 성공 판정 전에 브라우저에 세션 쿠키가 저장되었는지 확인한다.
    final sessionUser = await restoreSession();
    if (sessionUser == null || sessionUser.id != user.id) {
      throw StateError(
        '카카오 인증은 완료됐지만 로그인 세션이 유지되지 않습니다. '
            '브라우저 쿠키, 서버 CORS 및 127.0.0.1 주소를 확인해주세요.',
      );
    }

    return sessionUser;
  }

  @override
  Future<void> signOut() async {
    if (kIsWeb) {
      if (!_config.hasJavaScriptKey || _config.webLogoutEndpoint.isEmpty) {
        return;
      }

      try {
        await _webClient.post(
          Uri.parse(_config.webLogoutEndpoint),
          headers: const {
            'Accept': 'application/json',
          },
        );
      } catch (_) {
        // Local auth state is cleared even if the server logout request fails.
      }

      return;
    }

    if (!_config.hasNativeKey) {
      return;
    }

    try {
      await UserApi.instance.logout();
    } catch (_) {
      // Kakao SDK removes local tokens even when logout fails.
    }
  }

  AuthUser _authUserFromKakao(User user) {
    final profile = user.kakaoAccount?.profile;
    final nickname = profile?.nickname?.trim();

    return AuthUser(
      id: user.id.toString(),
      nickname: nickname?.isNotEmpty == true
          ? nickname!
          : '카카오 닉네임 미제공',
      email: user.kakaoAccount?.email,
      profileImageUrl: profile?.thumbnailImageUrl?.toString(),
    );
  }

  AuthUser? _authUserFromResponse(String body) {
    final decoded = jsonDecode(body);

    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final dynamic rawUser = decoded['user'] ?? decoded['data'] ?? decoded;

    if (rawUser is! Map) {
      return null;
    }

    final user = Map<String, dynamic>.from(rawUser);
    final id = user['id'] ?? user['kakaoId'] ?? user['userId'];

    if (id == null) {
      return null;
    }

    final nickname = _firstNonEmptyString([
      user['nickname'],
      user['name'],
      user['displayName'],
    ]);

    return AuthUser(
      id: id.toString(),
      nickname: nickname ?? '카카오 닉네임 미제공',
      email: _firstNonEmptyString([
        user['email'],
        user['accountEmail'],
      ]),
      profileImageUrl: _firstNonEmptyString([
        user['profileImageUrl'],
        user['profileImage'],
        user['thumbnailImageUrl'],
      ]),
    );
  }

  String? _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }
}
