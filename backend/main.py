# backend/main.py
import os
import tempfile
import traceback
from contextlib import asynccontextmanager

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from dotenv import load_dotenv

from services import claude_service, whisper_service

load_dotenv()


@asynccontextmanager
async def lifespan(app: FastAPI):
    if not os.getenv("ANTHROPIC_API_KEY"):
        raise RuntimeError("ANTHROPIC_API_KEY not set in environment")
    if not os.getenv("OPENAI_API_KEY"):
        raise RuntimeError("OPENAI_API_KEY not set in environment")
    print("✅  Sprachio backend started")
    yield


app = FastAPI(title="Sprachio API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


class HistoryItem(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    message: str
    history: list[HistoryItem] = Field(default_factory=list)
    language: str = "German"
    level: str = "A1"


class CorrectionOut(BaseModel):
    original: str
    corrected: str
    explanation: str


class ChatResponse(BaseModel):
    response: str
    corrections: list[CorrectionOut]


class TranscriptResponse(BaseModel):
    transcript: str


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    try:
        print(f"[chat] message='{req.message}' language={req.language} level={req.level} history_len={len(req.history)}")
        history = [{"role": h.role, "content": h.content} for h in req.history]
        response_text, corrections = claude_service.chat(
            message=req.message,
            history=history,
            language=req.language,
            level=req.level,
        )
        print(f"[chat] response='{response_text[:80]}' corrections={len(corrections)}")
        return ChatResponse(
            response=response_text,
            corrections=[CorrectionOut(**c) for c in corrections],
        )
    except Exception as e:
        print(f"[chat] ERROR: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/transcribe", response_model=TranscriptResponse)
async def transcribe(
    audio: UploadFile = File(...),
    language: str | None = Form(default=None),
):
    suffix = os.path.splitext(audio.filename or "audio.wav")[1] or ".wav"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        tmp.write(await audio.read())
        tmp_path = tmp.name

    try:
        print(f"[transcribe] file={tmp_path} language={language}")
        text = whisper_service.transcribe(tmp_path, language_code=language)
        print(f"[transcribe] result='{text}'")
        return TranscriptResponse(transcript=text)
    except Exception as e:
        print(f"[transcribe] ERROR: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=int(os.getenv("PORT", 8000)), reload=True)
