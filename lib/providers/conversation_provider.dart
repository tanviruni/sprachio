// lib/providers/conversation_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';

// Supported languages (add more as you expand)
class Language {
  final String name;
  final String code; // BCP-47 for Whisper
  final String flag;
  const Language({required this.name, required this.code, required this.flag});
}

const List<Language> kSupportedLanguages = [
  Language(name: 'German', code: 'de', flag: '🇩🇪'),
  Language(name: 'Spanish', code: 'es', flag: '🇪🇸'),
  Language(name: 'French', code: 'fr', flag: '🇫🇷'),
  Language(name: 'Italian', code: 'it', flag: '🇮🇹'),
  Language(name: 'Portuguese', code: 'pt', flag: '🇵🇹'),
  Language(name: 'Japanese', code: 'ja', flag: '🇯🇵'),
];

const List<String> kLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

class ConversationProvider extends ChangeNotifier {
  final ApiService _api;
  final AudioService _audio;
  final _uuid = const Uuid();

  ConversationProvider({ApiService? api, AudioService? audio})
      : _api = api ?? ApiService(),
        _audio = audio ?? AudioService();

  // ── Selection state ─────────────────────────────
  Language _language = kSupportedLanguages.first;
  String _level = 'A1';

  Language get language => _language;
  String get level => _level;

  void setLanguage(Language lang) {
    _language = lang;
    notifyListeners();
  }

  void setLevel(String lvl) {
    _level = lvl;
    notifyListeners();
  }

  // ── Conversation state ───────────────────────────
  final List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Recording state ──────────────────────────────
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  // ignore: unused_field
  String? _recordingPath;

  bool get isRecording => _isRecording;
  Duration get recordDuration => _recordDuration;

  // ────────────────────────────────────────────────
  // Start / reset conversation
  // ────────────────────────────────────────────────

  /// Clears history and asks Claude to open the conversation.
  Future<void> startConversation() async {
    _messages.clear();
    _error = null;
    await _initAudio();
    await _setLoading(true);

    try {
      final result = await _api.chat(
        message: '__INIT__', // sentinel; backend ignores content, starts fresh
        history: [],
        language: _language.name,
        level: _level,
      );
      _addAiMessage(result.response, result.corrections);
    } catch (e) {
      _error = _friendlyError(e);
    } finally {
      await _setLoading(false);
    }
  }

  // ────────────────────────────────────────────────
  // Send a typed message
  // ────────────────────────────────────────────────

  Future<void> sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _addUserMessage(trimmed);
    await _callClaude(trimmed);
  }

  // ────────────────────────────────────────────────
  // Voice recording
  // ────────────────────────────────────────────────

  Future<void> startRecording() async {
    if (_isRecording) return;
    try {
      await _initAudio();
      _recordingPath = await _audio.startRecording();
      _isRecording = true;
      _recordDuration = Duration.zero;
      notifyListeners();

      // Tick every second so the UI can show elapsed time
      _startRecordTicker();
    } catch (e) {
      _error = _friendlyError(e);
      notifyListeners();
    }
  }

  Future<void> stopRecordingAndSend() async {
    if (!_isRecording) return;
    _stopRecordTicker();

    try {
      final path = await _audio.stopRecording();
      _isRecording = false;
      notifyListeners();

      if (path == null || path.isEmpty) {
        _error = 'Recording was empty. Please try again.';
        notifyListeners();
        return;
      }

      await _setLoading(true);

      // 1. Transcribe
      final transcript = await _api.transcribeAudio(path, languageCode: _language.code);

      if (transcript.isEmpty) {
        _error = 'Could not understand audio. Please speak clearly.';
        await _setLoading(false);
        return;
      }

      // 2. Show user message (from voice)
      _addUserMessage(transcript, fromVoice: true);

      // 3. Get AI response
      await _callClaude(transcript);
    } catch (e) {
      _error = _friendlyError(e);
      _isRecording = false;
      await _setLoading(false);
    }
  }

  void cancelRecording() {
    if (!_isRecording) return;
    _stopRecordTicker();
    _audio.stopRecording();
    _isRecording = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ────────────────────────────────────────────────
  // Internal helpers
  // ────────────────────────────────────────────────

  bool _audioInited = false;
  Future<void> _initAudio() async {
    if (_audioInited) return;
    await _audio.init();
    _audioInited = true;
  }

  Future<void> _callClaude(String userText) async {
    await _setLoading(true);
    try {
      final result = await _api.chat(
        message: userText,
        history: _messages,
        language: _language.name,
        level: _level,
      );
      _addAiMessage(result.response, result.corrections);
    } catch (e) {
      _error = _friendlyError(e);
    } finally {
      await _setLoading(false);
    }
  }

  void _addUserMessage(String text, {bool fromVoice = false}) {
    _messages.add(Message(
      id: _uuid.v4(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      fromVoice: fromVoice,
    ));
    notifyListeners();
  }

  void _addAiMessage(String text, List<Correction> corrections) {
    _messages.add(Message(
      id: _uuid.v4(),
      text: text,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      corrections: corrections,
    ));
    notifyListeners();
  }

  Future<void> _setLoading(bool v) async {
    _isLoading = v;
    notifyListeners();
  }

  // Record ticker
  bool _ticking = false;
  void _startRecordTicker() {
    _ticking = true;
    _tick();
  }

  void _tick() async {
    while (_ticking && _isRecording) {
      await Future.delayed(const Duration(seconds: 1));
      if (_ticking && _isRecording) {
        _recordDuration += const Duration(seconds: 1);
        notifyListeners();
      }
    }
  }

  void _stopRecordTicker() {
    _ticking = false;
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('permission')) return 'Microphone permission is required.';
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Cannot reach server. Is the backend running?';
    }
    if (msg.contains('TimeoutException')) return 'Request timed out. Please try again.';
    return 'Something went wrong. Please try again.';
  }

  @override
  void dispose() {
    _stopRecordTicker();
    _audio.dispose();
    _api.dispose();
    super.dispose();
  }
}
