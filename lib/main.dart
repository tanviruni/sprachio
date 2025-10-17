import 'package:flutter/material.dart';
import 'package:sprachio/german_practice_screen.dart';
import 'package:sprachio/home_screen.dart';

void main() {
  runApp(const SprachioApp());
}

class SprachioApp extends StatelessWidget {
  const SprachioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sprachio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: Colors.teal, centerTitle: true),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {'/': (_) => const HomeScreen(), '/practice': (_) => const GermanPracticeScreen()},
    );
  }
}
