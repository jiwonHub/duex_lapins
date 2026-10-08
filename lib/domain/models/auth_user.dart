class AuthUser {
  const AuthUser({
    required this.id,
    required this.nickname,
    this.email,
    this.profileImageUrl,
  });

  final String id;
  final String nickname;
  final String? email;
  final String? profileImageUrl;
}
