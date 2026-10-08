import 'package:duex_lapins/core/theme/app_theme.dart';
import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class BrandsPage extends StatelessWidget {
  const BrandsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 720;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 20 : 40,
        30,
        mobile ? 20 : 40,
        76,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BRAND  /  DUEX LAPINS',
            style: AppTypography.label(
              fontSize: 8.5,
              letterSpacing: 1.65,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Duex Lapins',
            style: AppTypography.serif(
              fontSize: mobile ? 42 : 58,
              height: 0.96,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: mobile ? 28 : 42),
          const Divider(height: 1),
          SizedBox(height: mobile ? 34 : 54),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 940,
            ),
            child: Text(
              '익숙한 남성복의 구조를 오늘의 균형으로 다시 다듬습니다.',
              style: AppTypography.serif(
                fontSize: mobile ? 31 : 48,
                height: 1.05,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 22),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 760,
            ),
            child: Text(
              'DUEX LAPINS는 유행을 빠르게 소비하기보다 오래 입을 수 있는 실루엣과 소재, '
                  '실용적인 디테일을 중심으로 옷을 만듭니다. 클래식한 남성복의 기반 위에 '
                  '현대적인 비율과 절제된 스트리트 감각을 더해 매일 자연스럽게 손이 가는 옷을 제안합니다.',
              style: AppTypography.body(
                fontSize: mobile ? 12 : 13,
                height: 1.85,
                color: AppTheme.muted,
              ),
            ),
          ),
          SizedBox(height: mobile ? 46 : 72),
          const Divider(height: 1),
          _philosophy(
            index: '01',
            title: 'Modern Heritage',
            body:
            '전통적인 남성복의 구조와 균형을 존중하되, 지금의 생활 방식에 맞는 비율과 착용감으로 다시 해석합니다.',
            mobile: mobile,
          ),
          _philosophy(
            index: '02',
            title: 'Refined Utility',
            body:
            '보여주기 위한 장식보다 실제로 입었을 때 의미가 있는 기능과 디테일을 우선합니다.',
            mobile: mobile,
          ),
          _philosophy(
            index: '03',
            title: 'Subtle Street',
            body:
            '과도한 표현 대신 실루엣과 레이어, 소재의 질감만으로 은근한 존재감을 만드는 것을 지향합니다.',
            mobile: mobile,
          ),
        ],
      ),
    );
  }

  Widget _philosophy({
    required String index,
    required String title,
    required String body,
    required bool mobile,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: mobile ? 24 : 30,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.line,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: mobile ? 38 : 54,
            child: Text(
              '$index.',
              style: AppTypography.label(
                fontSize: 8.5,
                letterSpacing: 1.35,
                color: AppTheme.muted,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.serif(
                    fontSize: mobile ? 25 : 32,
                    height: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 680,
                  ),
                  child: Text(
                    body,
                    style: AppTypography.body(
                      fontSize: 11.5,
                      height: 1.75,
                      color: AppTheme.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
