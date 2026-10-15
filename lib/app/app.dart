import 'package:deux_lapins/app/app_router.dart';
import 'package:deux_lapins/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DuexLapinsApp extends StatelessWidget {
  const DuexLapinsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'DEUX LAPINS',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
