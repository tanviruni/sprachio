// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

/// Result of a /chat call.
class ChatResult {
  final String response;
  final List<Correction> corrections;
  const ChatResult({required this.response, required this.corrections});
}

/// Communicates with the Sprachio FastAPI backend.
class ApiService {
  // ── Change this to your machine's local IP when testing on a real device ──
  // Android emulator → 10.0.2.2
  // iOS simulator    → 127.0.0.1
  // Real device      → your LAN IP, e.g. 192.168.1.42
  static const String _base = 'http://localhost:8000';

  final http.Client _client;
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // ──────────────────────────────────────────────
  // POST /transcribe — audio file → transcript
  // ──────────────────────────────────────────────

  /// Uploads a local WAV file and returns the Whisper transcript.
  Future<String> transcribeAudio(String filePath, {String? languageCode}) async {
    final uri = Uri.parse('$_base/transcribe');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('audio', filePath, filename: 'recording.wav'));

    if (languageCode != null) {
      request.fields['language'] = languageCode;
    }

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      throw Exception('Transcription failed (${streamed.statusCode}): $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return (json['transcript'] as String? ?? '').trim();
  }

  // ──────────────────────────────────────────────
  // POST /chat — message → AI response
  // ──────────────────────────────────────────────

  /// Sends a user message and conversation history to Claude.
  /// Returns the AI response text and any corrections.
  Future<ChatResult> chat({
    required String message,
    required List<Message> history,
    required String language,
    required String level,
  }) async {
    final uri = Uri.parse('$_base/chat');

    // Build history (exclude loading placeholders, keep last 20 for context window)
    final historyJson = history.take(history.length > 20 ? history.length - 1 : history.length).map((m) => m.toHistoryJson()).toList();

    final payload = jsonEncode({
      'message': message,
      'history': historyJson,
      'language': language,
      'level': level,
    });

    final response =
        await _client.post(uri, headers: {'Content-Type': 'application/json'}, body: payload).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Chat failed (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    final corrections = (json['corrections'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>().map(Correction.fromJson).toList();

    return ChatResult(
      response: (json['response'] as String? ?? '').trim(),
      corrections: corrections,
    );
  }

  void dispose() => _client.close();
}
