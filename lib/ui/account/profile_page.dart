import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:duex_lapins/ui/account/account_view_model.dart';
import 'package:duex_lapins/ui/auth/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    final account = ref.read(accountViewModelProvider);
    final auth = ref.read(authViewModelProvider);
    nameController = TextEditingController(
      text: auth.user?.nickname ?? account.name,
    );
    emailController = TextEditingController(
      text: auth.user?.email ?? account.email,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 720;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 16 : 40,
        mobile ? 26 : 36,
        mobile ? 16 : 40,
        76,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACCOUNT  /  PERSONAL DETAILS',
              style: AppTypography.label(
                fontSize: 8.5,
                letterSpacing: 1.7,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Profile',
              style: AppTypography.serif(
                fontSize: mobile ? 42 : 58,
                height: 0.95,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 28),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            const SizedBox(height: 18),
            const TextField(
              decoration: InputDecoration(
                labelText: '휴대폰 번호',
                hintText: '010-0000-0000',
              ),
            ),
            const SizedBox(height: 34),
            SizedBox(
              width: 220,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(accountViewModelProvider.notifier).updateProfile(
                        nameController.text.trim(),
                        emailController.text.trim(),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('프로필이 저장되었습니다')),
                  );
                },
                child: const Text('변경사항 저장  →'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
