import os

import httpx
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

load_dotenv()

CLIENT_ID = os.getenv("PAYPAL_CLIENT_ID", "")
CLIENT_SECRET = os.getenv("PAYPAL_CLIENT_SECRET", "")
BASE_URL = os.getenv("PAYPAL_BASE_URL", "https://api-m.sandbox.paypal.com")

app = FastAPI(title="SavorLens API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # for local testing only
    allow_methods=["*"],
    allow_headers=["*"],
)


class OrderRequest(BaseModel):
    amount: str = "10.00"
    description: str = "Dietitian consultation"


async def get_access_token() -> str:
    if not CLIENT_ID or not CLIENT_SECRET:
        raise HTTPException(status_code=500, detail="PayPal keys are missing in .env")
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{BASE_URL}/v1/oauth2/token",
            auth=(CLIENT_ID, CLIENT_SECRET),
            data={"grant_type": "client_credentials"},
        )
    if response.status_code != 200:
        raise HTTPException(status_code=502, detail="Could not get PayPal token")
    return response.json()["access_token"]


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/paypal/create-order")
async def create_order(order: OrderRequest):
    token = await get_access_token()
    body = {
        "intent": "CAPTURE",
        "purchase_units": [
            {
                "description": order.description,
                "amount": {"currency_code": "USD", "value": order.amount},
            }
        ],
    }
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{BASE_URL}/v2/checkout/orders",
            json=body,
            headers={"Authorization": f"Bearer {token}"},
        )
    if response.status_code not in (200, 201):
        raise HTTPException(status_code=502, detail="PayPal could not create the order")
    data = response.json()
    approve_url = next(
        (
            link["href"]
            for link in data.get("links", [])
            if link["rel"] in ("approve", "payer-action")
        ),
        None,
    )
    return {
        "order_id": data["id"],
        "status": data["status"],
        "approve_url": approve_url,
    }


@app.post("/paypal/capture-order/{order_id}")
async def capture_order(order_id: str):
    token = await get_access_token()
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{BASE_URL}/v2/checkout/orders/{order_id}/capture",
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json",
            },
        )
    if response.status_code not in (200, 201):
        raise HTTPException(status_code=502, detail="PayPal could not capture the order")
    data = response.json()
    return {"order_id": data["id"], "status": data["status"]}