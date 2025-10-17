# Sprachio 🗣️  
**An AI-powered conversational language learning app**

Sprachio helps users overcome the fear of speaking by offering an AI conversation partner that listens, responds, and adapts — making language learning feel natural and interactive.  
Initially focused on **German**, Sprachio will expand to support multiple languages in future versions.

---

## 🌍 Overview
Many language learners struggle with *speaking confidence*. Sprachio uses **AI-driven voice interaction** to let users:
- Talk freely to an AI tutor.
- Get real-time feedback on pronunciation and grammar.
- Practice conversation through natural voice-based interactions.

No need for human partners — just speak, learn, and improve anytime.

---

## ✨ Features (MVP)
- 🎤 **Voice Recording & Recognition:** Speak German, and the app transcribes what you say.  
- 🤖 **AI Conversation Partner:** The app replies in German naturally.  
- 🧩 **Learning Context Awareness:** The AI maintains the context of your conversation.  
- 🔈 **Text-to-Speech Responses:** Hear the AI’s responses in realistic German pronunciation.  
- 🎯 **Cross-Platform Flutter App:** Runs seamlessly on **Android** and **iOS**.

---

## 🚀 Tech Stack

| Layer | Technology |
|-------|-------------|
| Frontend | [Flutter](https://flutter.dev/) |
| AI / LLM | OpenAI GPT-4/5 API (or compatible) |
| Speech-to-Text | Whisper / Google Speech API |
| Text-to-Speech | ElevenLabs / Google Cloud TTS |
| Backend (Optional) | Firebase / Supabase (for storing sessions) |

---

## 🛠️ Setup & Installation

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / Xcode
- OpenAI API key
- Git & SSH set up for GitHub access

### Steps
```bash
# Clone the repository
git clone git@github.com:tanviruni/sprachio.git

# Navigate to the project
cd sprachio

# Get dependencies
flutter pub get

# Run on your device
flutter run
