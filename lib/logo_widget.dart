import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 120});

  // gradient colors tuned for good contrast on both light & dark backgrounds
  static const List<Color> gradientColors = [Color(0xFF00BFA5), Color(0xFF00A0C6)];

  @override
  Widget build(BuildContext context) {
    final double bubbleSize = size * 0.62;
    final double sSize = size * 0.48;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Round background with subtle gradient & shadow
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
              borderRadius: BorderRadius.circular(size * 0.25),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 6))],
            ),
          ),

          // speech-bubble circle
          Positioned(
            top: size * 0.14,
            child: Container(
              width: bubbleSize,
              height: bubbleSize,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(bubbleSize * 0.28)),
              child: Icon(Icons.chat_bubble_rounded, size: bubbleSize * 0.56, color: Colors.grey.shade200),
            ),
          ),

          // stylized "S" letter
          Positioned(
            bottom: size * 0.12,
            child: Container(
              width: sSize,
              alignment: Alignment.center,
              child: Text(
                'S',
                style: TextStyle(
                  fontSize: sSize * 0.9,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [Shadow(offset: const Offset(0, 2), blurRadius: 3, color: Colors.black.withValues(alpha: 0.18))],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
