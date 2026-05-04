import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'data/datasources/local_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage (Hive)
  await LocalDb.init();
  
  // Initialize date formatting for Indonesia locale (intl)
  await initializeDateFormatting('id_ID', null);

  runApp(
    const ProviderScope(
      child: AntigravityApp(),
    ),
  );
}

class AntigravityApp extends StatelessWidget {
  const AntigravityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Antigravity',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Uses system settings for light/dark mode
      routerConfig: appRouter,
    );
  }
}
