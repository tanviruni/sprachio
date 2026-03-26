# backend/services/claude_service.py
import json
import os
import re
from groq import Groq

_client: Groq | None = None

def _get_client() -> Groq:
    global _client
    if _client is None:
        _client = Groq()  # reads GROQ_API_KEY from env
    return _client


# ─────────────────────────────────────────────────────────────
# System prompt
# ─────────────────────────────────────────────────────────────

def _system_prompt(language: str, level: str) -> str:
    level_desc = {
        "A1": "complete beginner — use only the most basic vocabulary and very short sentences",
        "A2": "elementary — simple everyday phrases, basic grammar",
        "B1": "intermediate — can handle most everyday topics, some complex sentences",
        "B2": "upper-intermediate — discuss abstract topics, near-natural speech",
        "C1": "advanced — wide vocabulary, idiomatic, nuanced expressions",
        "C2": "mastery — native-level fluency, discuss any topic",
    }.get(level, "intermediate")

    return f"""You are Sprachio, a warm and encouraging AI language tutor. \
You help users practice {language} through natural, engaging conversation.

The user's level is {level} ({level_desc}).

## Rules
1. Respond PRIMARILY in {language}. Use English only for brief corrections or if the user seems completely stuck.
2. Keep responses SHORT and CONVERSATIONAL — 2 to 4 sentences. Always end with a follow-up question to keep the dialogue going.
3. Adapt vocabulary and grammar complexity strictly to the {level} level.
4. If the user makes a grammar or vocabulary mistake, gently incorporate the corrected form naturally in your reply.
5. Be encouraging. Never make the learner feel embarrassed.
6. Topic variety: daily life, food, travel, hobbies, culture, weather, family, work.
7. If the message is `__INIT__`, greet the user warmly in {language} and ask them a simple opening question appropriate for {level} level.

## Output format
After your conversational reply, append a JSON block — ALWAYS, even if there are zero corrections:

<corrections>
[
  {{"original": "phrase the user wrote incorrectly", "corrected": "correct version", "explanation": "brief English explanation"}}
]
</corrections>

If there are no corrections, output: <corrections>[]</corrections>

Do NOT include anything after the closing </corrections> tag."""


# ─────────────────────────────────────────────────────────────
# Parse response
# ─────────────────────────────────────────────────────────────

def _parse_response(raw: str) -> tuple[str, list[dict]]:
    corrections: list[dict] = []

    match = re.search(r"<corrections>(.*?)</corrections>", raw, re.DOTALL)
    if match:
        json_str = match.group(1).strip()
        try:
            parsed = json.loads(json_str)
            if isinstance(parsed, list):
                corrections = parsed
        except json.JSONDecodeError:
            pass
        response_text = raw[: match.start()].strip()
    else:
        response_text = raw.strip()

    return response_text, corrections


# ─────────────────────────────────────────────────────────────
# Public function
# ─────────────────────────────────────────────────────────────

def chat(
    message: str,
    history: list[dict],
    language: str,
    level: str,
) -> tuple[str, list[dict]]:
    messages = list(history)

    if message == "__INIT__":
        messages = [{"role": "user", "content": "__INIT__"}]
    else:
        messages.append({"role": "user", "content": message})

    response = _get_client().chat.completions.create(
        model="llama-3.3-70b-versatile",  # best free model on Groq
        max_tokens=512,
        messages=[{"role": "system", "content": _system_prompt(language, level)}] + messages,
    )

    raw = response.choices[0].message.content or ""
    return _parse_response(raw)