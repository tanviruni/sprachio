// lib/widgets/chat_bubble.dart
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../theme/app_theme.dart';

class ChatBubble extends StatefulWidget {
  final Message message;
  const ChatBubble({super.key, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  bool _showCorrections = false;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    // Fade the bubble in when it appears
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAI = widget.message.isAI;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: EdgeInsets.only(
          left: isAI ? 12 : 60,
          right: isAI ? 60 : 12,
          bottom: 8,
        ),
        child: Column(
          crossAxisAlignment:
              isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            // ── Avatar + bubble row ──────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment:
                  isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                if (isAI) _aiAvatar(),
                if (isAI) const SizedBox(width: 8),
                Flexible(child: _buildBubble(isAI)),
                if (!isAI && widget.message.fromVoice) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.mic, size: 14, color: Color(0xFF9E9E9E)),
                ],
              ],
            ),

            // ── Corrections toggle ───────────────────
            if (isAI && widget.message.hasCorrections) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showCorrections = !_showCorrections),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showCorrections
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 16,
                            color: const Color(0xFFF57F17),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showCorrections
                                ? 'Hide corrections'
                                : '${widget.message.corrections.length} correction${widget.message.corrections.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFF57F17),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showCorrections) ...[
                      const SizedBox(height: 6),
                      ...widget.message.corrections
                          .map((c) => _CorrectionCard(correction: c)),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _aiAvatar() => Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00BFA5), Color(0xFF0288D1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text('S',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
        ),
      );

  Widget _buildBubble(bool isAI) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isAI ? AppTheme.aiBubble : AppTheme.userBubble,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isAI ? 4 : 18),
          bottomRight: Radius.circular(isAI ? 18 : 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Text(
        widget.message.text,
        style: TextStyle(
          color: isAI ? AppTheme.aiText : AppTheme.userText,
          fontSize: 15,
          height: 1.45,
        ),
      ),
    );
  }
}

// ── Correction card ────────────────────────────────────────────
class _CorrectionCard extends StatelessWidget {
  final Correction correction;
  const _CorrectionCard({required this.correction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.correctionBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.correctionBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                correction.original,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFB71C1C),
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Color(0xFFB71C1C),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward, size: 13, color: Colors.grey),
              ),
              Text(
                correction.corrected,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1B5E20),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (correction.explanation.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              correction.explanation,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF5D4037), height: 1.3),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Typing indicator (AI is thinking) ────────────────────────
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});
  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dot(0),
          const SizedBox(width: 4),
          _dot(0.33),
          const SizedBox(width: 4),
          _dot(0.66),
        ],
      ),
    );
  }

  Widget _dot(double offset) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final phase = (_anim.value + offset) % 1.0;
        final scale = 0.7 + 0.3 * (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
