# Sprachio 🗣️

AI-powered language learning through natural conversation. Talk to an AI tutor, get real-time corrections, and build fluency without the social anxiety.

## Stack

- **Flutter** — iOS, Android, Windows, Web
- **FastAPI** — Python backend
- **Groq (Llama 3)** — AI conversation + corrections
- **OpenAI Whisper** — speech to text

## Project Structure

```
sprachio/
├── flutter/        # Flutter app
└── backend/        # Python API
    ├── main.py
    └── services/
        ├── claude_service.py   # AI tutor logic
        └── whisper_service.py  # Speech to text
```

## Getting Started

### Backend

```bash
cd backend
python -m venv venv
venv\Scripts\activate        # Windows
source venv/bin/activate     # Mac/Linux

pip install -r requirements.txt
cp .env.example .env         # Add your API keys
python main.py               # Runs on http://localhost:8000
```

### Flutter

```bash
cd flutter
flutter pub get
flutter run
```

> Set the backend URL in `lib/services/api_service.dart` to match your environment.

## API Keys

| Key | Where to get it |
|---|---|
| `GROQ_API_KEY` | https://console.groq.com |
| `OPENAI_API_KEY` | https://platform.openai.com (Whisper STT only) |

## Features

- 🌍 6 languages — German, Spanish, French, Italian, Portuguese, Japanese
- 📊 CEFR levels A1 → C2
- 🎙️ Voice input with live transcription
- ✅ Inline grammar corrections
- 💬 Natural conversation flow