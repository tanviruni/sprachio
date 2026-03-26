import 'package:flutter/foundation.dart';

/// A grammar/vocabulary correction from the AI tutor.
@immutable
class Correction {
  final String original;
  final String corrected;
  final String explanation;

  const Correction({
    required this.original,
    required this.corrected,
    required this.explanation,
  });

  factory Correction.fromJson(Map<String, dynamic> json) => Correction(
        original: (json['original'] as String? ?? '').trim(),
        corrected: (json['corrected'] as String? ?? '').trim(),
        explanation: (json['explanation'] as String? ?? '').trim(),
      );
}

enum MessageSender { user, ai }

/// A single chat message in the conversation.
@immutable
class Message {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final List<Correction> corrections;

  /// True if this message originated from a voice recording
  final bool fromVoice;

  const Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.corrections = const [],
    this.fromVoice = false,
  });

  bool get isAI => sender == MessageSender.ai;
  bool get isUser => sender == MessageSender.user;
  bool get hasCorrections => corrections.isNotEmpty;

  /// Convert to the format expected by the backend history array.
  Map<String, dynamic> toHistoryJson() => {
        'role': isAI ? 'assistant' : 'user',
        'content': text,
      };
}
