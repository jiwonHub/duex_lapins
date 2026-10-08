import 'package:duex_lapins/core/di/providers.dart';
import 'package:duex_lapins/domain/models/auth_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  const AuthState({
    this.user,
    this.initializing = true,
    this.loading = false,
    this.errorMessage,
  });

  final AuthUser? user;
  final bool initializing;
  final bool loading;
  final String? errorMessage;

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    AuthUser? user,
    bool clearUser = false,
    bool? initializing,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      initializing: initializing ?? this.initializing,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future<void>.microtask(_restoreSession);
    return const AuthState();
  }

  Future<void> _restoreSession() async {
    try {
      final user = await ref.read(authRepositoryProvider).restoreSession();

      state = state.copyWith(
        user: user,
        clearUser: user == null,
        initializing: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        clearUser: true,
        initializing: false,
      );
    }
  }

  Future<bool> signInWithKakao() async {
    if (state.loading) {
      return false;
    }

    state = state.copyWith(
      loading: true,
      clearError: true,
    );

    try {
      final user = await ref.read(authRepositoryProvider).signInWithKakao();

      if (user == null) {
        state = state.copyWith(
          loading: false,
        );
        return false;
      }

      state = state.copyWith(
        user: user,
        initializing: false,
        loading: false,
        clearError: true,
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: _messageFor(error),
      );
      return false;
    }
  }

  Future<bool> completeWebKakaoLogin(String code) async {
    state = state.copyWith(
      loading: true,
      clearError: true,
    );

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .completeWebKakaoLogin(code);

      if (user == null) {
        throw StateError('카카오 사용자 정보를 확인할 수 없습니다.');
      }

      state = state.copyWith(
        user: user,
        initializing: false,
        loading: false,
        clearError: true,
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: _messageFor(error),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    if (state.loading) {
      return;
    }

    state = state.copyWith(
      loading: true,
      clearError: true,
    );

    await ref.read(authRepositoryProvider).signOut();

    state = const AuthState(
      initializing: false,
    );
  }

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }

  String _messageFor(Object error) {
    final message = error.toString();

    if (message.startsWith('Bad state: ')) {
      return message.substring('Bad state: '.length);
    }

    return '카카오 로그인 중 오류가 발생했습니다. 다시 시도해주세요.';
  }
}

final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);
