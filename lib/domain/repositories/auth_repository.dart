import 'package:duex_lapins/domain/models/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser?> restoreSession();

  Future<AuthUser?> signInWithKakao();

  Future<AuthUser?> completeWebKakaoLogin(String code);

  Future<void> signOut();
}
