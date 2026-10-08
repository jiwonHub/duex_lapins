import 'dart:async';
import 'dart:convert';

import 'package:duex_lapins/core/config/kakao_config.dart';
import 'package:duex_lapins/domain/models/auth_user.dart';
import 'package:duex_lapins/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_auth/kakao_flutter_sdk_auth.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoAuthRepositoryImpl implements AuthRepository {
  const KakaoAuthRepositoryImpl(this._config);

  final KakaoConfig _config;

  @override
  Future<AuthUser?> restoreSession() async {
    if (kIsWeb) {
      if (!_config.hasJavaScriptKey || _config.webSessionEndpoint.isEmpty) {
        return null;
      }

      try {
        final response = await http.get(
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
      response = await http
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
      throw StateError(
        '카카오 로그인 처리에 실패했습니다. (${response.statusCode})',
      );
    }

    final user = _authUserFromResponse(response.body);

    if (user == null) {
      throw StateError('서버 응답에서 사용자 정보를 확인할 수 없습니다.');
    }

    return user;
  }

  @override
  Future<void> signOut() async {
    if (kIsWeb) {
      if (!_config.hasJavaScriptKey || _config.webLogoutEndpoint.isEmpty) {
        return;
      }

      try {
        await http.post(
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
          : 'DUEX LAPINS MEMBER',
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
      nickname: nickname ?? 'DUEX LAPINS MEMBER',
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
