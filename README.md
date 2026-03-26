# Sprachio 🗣️

AI-powered language learning through natural conversation. Talk to Claude, get corrected in real-time, and build fluency without the social anxiety.

---

## Project Structure

```
sprachio/
├── flutter/                  # Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   ├── models/
│   │   │   └── message.dart
│   │   ├── providers/
│   │   │   └── conversation_provider.dart
│   │   ├── services/
│   │   │   ├── audio_service.dart
│   │   │   └── api_service.dart
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   └── practice_screen.dart
│   │   └── widgets/
│   │       ├── app_logo.dart
│   │       └── chat_bubble.dart
│   └── pubspec.yaml
│
└── backend/                  # Python FastAPI backend
    ├── main.py
    ├── requirements.txt
    ├── .env.example
    └── services/
        ├── claude_service.py   # Anthropic Claude integration
        └── whisper_service.py  # OpenAI Whisper STT
```

---

## Architecture

```
Flutter App
    │
    ├─ POST /transcribe ──► Whisper API (speech → text)
    │
    └─ POST /chat ────────► Claude API (text → AI response + corrections)
```

**Voice flow:**
1. User holds mic button → `flutter_sound` records 16kHz PCM WAV
2. WAV is uploaded to `/transcribe` → Whisper returns transcript
3. Transcript is sent to `/chat` with conversation history
4. Claude replies in the target language + JSON corrections block
5. UI renders AI bubble; corrections shown on tap

---

## Backend Setup

### 1. Install dependencies

```bash
cd backend
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Configure environment

```bash
cp .env.example .env
# Edit .env and add your keys:
#   ANTHROPIC_API_KEY=sk-ant-...
#   OPENAI_API_KEY=sk-...        (Whisper STT only — no GPT needed)
```

### 3. Run

```bash
python main.py
# Server starts at http://0.0.0.0:8000
# Docs at http://localhost:8000/docs
```

---

## Flutter Setup

### 1. Install packages

```bash
cd flutter
flutter pub get
```

### 2. ⚠️ Android permissions (REQUIRED)

Add to `android/app/src/main/AndroidManifest.xml` inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />

<!-- Required by flutter_sound on Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
```

Also add `android:usesCleartextTraffic="true"` to `<application>` for local dev
(HTTP, not HTTPS):

```xml
<application
    android:label="sprachio"
    android:usesCleartextTraffic="true"
    ...>
```

### 3. ⚠️ iOS permissions (REQUIRED)

Add to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Sprachio needs the microphone to hear your practice sentences.</string>
```

### 4. Set your backend URL

In `lib/services/api_service.dart`, change `_base` to match your setup:

| Scenario | URL |
|---|---|
| Android emulator | `http://10.0.2.2:8000` |
| iOS simulator | `http://127.0.0.1:8000` |
| Real device (same WiFi) | `http://192.168.x.x:8000` |

### 5. Run

```bash
flutter run
```

---

## API Reference

### `POST /chat`
```json
{
  "message": "Ich habe gestern ins Kino gegangen",
  "history": [
    { "role": "assistant", "content": "Hallo! Was machst du gern?" }
  ],
  "language": "German",
  "level": "B1"
}
```
**Response:**
```json
{
  "response": "Oh, interessant! Ich gehe auch gerne ins Kino. Welchen Film hast du gesehen?",
  "corrections": [
    {
      "original": "ins Kino gegangen",
      "corrected": "ins Kino gegangen → bin ... gegangen",
      "explanation": "Movement verbs use 'sein' as auxiliary: 'Ich bin ins Kino gegangen'"
    }
  ]
}
```

### `POST /transcribe`
Multipart form upload:
- `audio` — WAV/MP3 file
- `language` — optional BCP-47 code (`de`, `es`, `fr`, …)

**Response:** `{ "transcript": "Ich habe gestern ins Kino gegangen" }`

---

## Adding More Languages

1. Add to `kSupportedLanguages` in `lib/providers/conversation_provider.dart`
2. No backend changes needed — Claude handles any language

---

## Roadmap

- [ ] Text-to-speech playback of AI responses (`flutter_tts`)
- [ ] Vocabulary notebook — save unknown words per session
- [ ] Progress tracking — streaks, session history (PostgreSQL)
- [ ] User auth (Supabase or Firebase)
- [ ] Offline mode — on-device Whisper (whisper.cpp)
- [ ] Pronunciation scoring

---

## Why Two API Keys?

| Key | Used for |
|---|---|
| `ANTHROPIC_API_KEY` | Claude — the tutor's brain (conversation + corrections) |
| `OPENAI_API_KEY` | Whisper — speech-to-text only |

Whisper is currently the most accurate open STT model. You can swap it for a self-hosted `whisper.cpp` later to remove the OpenAI dependency entirely.
