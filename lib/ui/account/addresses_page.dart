import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});

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
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACCOUNT  /  DELIVERY',
              style: AppTypography.label(
                fontSize: 8.5,
                letterSpacing: 1.7,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Addresses',
              style: AppTypography.serif(
                fontSize: mobile ? 42 : 58,
                height: 0.95,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.line,
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '기본 배송지',
                        style: AppTypography.label(
                          fontSize: 8.5,
                          letterSpacing: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '수정',
                        style: AppTypography.label(
                          fontSize: 8.5,
                          letterSpacing: 1.15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '최지원',
                    style: AppTypography.serif(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('010-0000-0000'),
                  const SizedBox(height: 4),
                  const Text(
                    '서울특별시 성동구 성수이로 00, 000동 000호',
                    style: TextStyle(
                      color: AppTheme.muted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: const Text('새 배송지 추가'),
            ),
          ],
        ),
      ),
    );
  }
}
