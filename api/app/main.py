from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import requests, os

app = FastAPI()

# UI ausliefern
app.mount("/ui", StaticFiles(directory="/app/web", html=True), name="web")

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://ollama:11434")

class ChatRequest(BaseModel):
    prompt: str
    model:  str

@app.get("/")
def root():
    return RedirectResponse(url="/ui/")
    
@app.get("/models")
def list_models():
    r = requests.get(f"{OLLAMA_HOST}/api/tags", timeout=30)
    models = [m["name"] for m in r.json().get("models", [])]
    return {"models": models}


@app.post("/chat")
def chat(req: ChatRequest):
    # System-Anweisung für das Verhalten
    system_instruction = (
        "Respond in the language of the user's prompt (German, English, or Japanese). "
        "Be concise and clear. No long essays. Keep answers brief and to the point."
    )
    
    r = requests.post(
        f"{OLLAMA_HOST}/api/generate",
        json={
            "model": req.model,
            "system": system_instruction,  # Hier setzen wir das Verhalten fest
            "prompt": req.prompt,
            "stream": False
        },
        timeout=120
    )
    
    r.raise_for_status() # Sicherheitshalber Fehler werfen, falls Ollama hakt
    return {"response": r.json()["response"]}

