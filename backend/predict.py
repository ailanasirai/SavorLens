import io
import json
from pathlib import Path

import numpy as np
from fastapi import APIRouter, File, HTTPException, UploadFile
from PIL import Image

router = APIRouter()

MODEL_DIR = Path(__file__).parent / "model"
REPORT = json.loads((MODEL_DIR / "model_report.json").read_text())
CLASSES = REPORT["classes"]
THRESHOLD = REPORT["not_sure_threshold"]
IMG = REPORT["image_size"]

_model = None


def get_model():
    global _model
    if _model is None:
        from tensorflow import keras

        _model = keras.models.load_model(MODEL_DIR / "savorlens_food.keras")
    return _model


@router.post("/predict")
async def predict(file: UploadFile = File(...)):
    data = await file.read()
    try:
        img = Image.open(io.BytesIO(data)).convert("RGB").resize((IMG, IMG))
    except Exception:
        raise HTTPException(status_code=400, detail="Could not read the image")

    x = np.expand_dims(np.array(img, dtype="float32"), 0)
    probs = get_model().predict(x, verbose=0)[0]
    order = np.argsort(-probs)[:3]
    top = [
        {"dish": CLASSES[i].replace("_", " "), "confidence": round(float(probs[i]), 3)}
        for i in order
    ]
    sure = float(probs[order[0]]) >= THRESHOLD
    return {
        "sure": sure,
        "dish": top[0]["dish"] if sure else None,
        "confidence": top[0]["confidence"],
        "top3": top,
        "threshold": THRESHOLD,
        "note": "Model v1: 12 dishes. Test accuracy 84.7% on held-out photos.",
    }