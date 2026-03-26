// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/conversation_provider.dart';
import 'screens/home_screen.dart';
import 'screens/practice_screen.dart';
import 'theme/app_theme.dart';

class SprachioApp extends StatelessWidget {
  const SprachioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConversationProvider(),
      child: MaterialApp(
        title: 'Sprachio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: '/',
        routes: {
          '/': (_) => const HomeScreen(),
          '/practice': (_) => const PracticeScreen(),
        },
      ),
    );
  }
}
