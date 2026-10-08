import 'package:duex_lapins/ui/auth/login_page.dart';
import 'package:duex_lapins/ui/auth/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authViewModelProvider);

    if (auth.initializing) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 1.2,
        ),
      );
    }

    if (!auth.isLoggedIn) {
      return const LoginPage(
        embedded: true,
      );
    }

    return child;
  }
}
