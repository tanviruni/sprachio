// lib/widgets/app_logo.dart
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 120});

  static const List<Color> _gradient = [Color(0xFF00BFA5), Color(0xFF0288D1)];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradient,
        ),
        borderRadius: BorderRadius.circular(size * 0.26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00897B).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Chat bubble icon
          Positioned(
            top: size * 0.14,
            child: Icon(
              Icons.chat_bubble_rounded,
              size: size * 0.44,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
          // "S" letter
          Text(
            'S',
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                  color: Colors.black.withValues(alpha: 0.22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
