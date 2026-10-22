from fastapi import FastAPI

app = FastAPI(title="SavorLens API")

@app.get("/health")
def health():
    return {"status": "ok"}
