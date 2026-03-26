// lib/services/audio_service.dart
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

/// Handles microphone recording and local audio playback.
/// Uses flutter_sound ONLY (audioplayers removed to prevent conflicts).
class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  bool _recorderReady = false;
  bool _playerReady = false;

  // ──────────────────────────────────────────────
  // Init / Dispose
  // ──────────────────────────────────────────────

  Future<void> init() async {
    if (!_recorderReady) {
      await _recorder.openRecorder();
      // Enable progress updates every 100 ms so UI can show a timer
      await _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));
      _recorderReady = true;
    }
    if (!_playerReady) {
      await _player.openPlayer();
      _playerReady = true;
    }
  }

  Future<void> dispose() async {
    try {
      if (_recorderReady && _recorder.isRecording) {
        await _recorder.stopRecorder();
      }
      if (_recorderReady) await _recorder.closeRecorder();

      if (_playerReady && _player.isPlaying) {
        await _player.stopPlayer();
      }
      if (_playerReady) await _player.closePlayer();
    } catch (_) {}

    _recorderReady = false;
    _playerReady = false;
  }

  // ──────────────────────────────────────────────
  // Permissions
  // ──────────────────────────────────────────────

  /// Returns true if microphone permission is granted (requests if needed).
  Future<bool> ensureMicPermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied || status.isRestricted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  // ──────────────────────────────────────────────
  // Recording
  // ──────────────────────────────────────────────

  /// Start recording to a temp WAV file (PCM16, 16 kHz — Whisper-compatible).
  /// Returns the output file path.
  /// Throws [Exception] if permission denied.
  Future<String> startRecording() async {
    if (!_recorderReady) await init();

    final granted = await ensureMicPermission();
    if (!granted) throw Exception('Microphone permission denied');

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${const Uuid().v4()}.wav';

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.pcm16WAV,
      sampleRate: 16000,
      bitRate: 128000,
    );

    return path;
  }

  /// Stop recording and return the final saved path (or null on error).
  Future<String?> stopRecording() async {
    if (!_recorderReady) return null;
    try {
      return await _recorder.stopRecorder();
    } catch (_) {
      return null;
    }
  }

  bool get isRecording => _recorderReady && _recorder.isRecording;

  /// Live progress stream (duration + decibels).
  Stream<RecordingDisposition>? get onProgress =>
      _recorderReady ? _recorder.onProgress : null;

  // ──────────────────────────────────────────────
  // Playback
  // ──────────────────────────────────────────────

  /// Play a local file. Calls [onComplete] when finished.
  Future<void> playFile(String path, {VoidCallback? onComplete}) async {
    if (!_playerReady) await init();
    if (!File(path).existsSync()) throw Exception('File not found: $path');

    if (_player.isPlaying) await _player.stopPlayer();

    await _player.startPlayer(
      fromURI: path,
      whenFinished: onComplete,
    );
  }

  Future<void> stopPlayback() async {
    if (_playerReady && _player.isPlaying) {
      await _player.stopPlayer();
    }
  }

  bool get isPlaying => _playerReady && _player.isPlaying;
}

// Provide a no-op VoidCallback type alias for convenience
typedef VoidCallback = void Function();
