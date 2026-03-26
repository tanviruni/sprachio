# backend/services/whisper_service.py
import os
import openai

_client: openai.OpenAI | None = None

def _get_client() -> openai.OpenAI:
    global _client
    if _client is None:
        _client = openai.OpenAI()  # reads OPENAI_API_KEY from env at call time
    return _client


def transcribe(audio_path: str, language_code: str | None = None) -> str:
    """
    Transcribe a local audio file using OpenAI Whisper.

    Args:
        audio_path: Path to a WAV / MP3 / M4A file.
        language_code: BCP-47 language hint (e.g. "de", "es").
                       Passing the correct language improves accuracy and speed.

    Returns:
        Transcribed text string (empty string if silent / unrecognisable).
    """
    if not os.path.exists(audio_path):
        raise FileNotFoundError(f"Audio file not found: {audio_path}")

    kwargs: dict = {"model": "whisper-1"}
    if language_code:
        kwargs["language"] = language_code

    with open(audio_path, "rb") as f:
        transcript = _get_client().audio.transcriptions.create(file=f, **kwargs)

    return (transcript.text or "").strip()