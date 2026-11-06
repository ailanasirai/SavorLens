# API reference

The backend is a FastAPI app. When it is running, FastAPI serves interactive documentation with the exact request and response schemas at `/docs` (Swagger UI).

| Environment | Base URL |
|---|---|
| Local | `http://127.0.0.1:8000` |
| Hosted payment backend (Render) | `https://savorlens.onrender.com` |

> [!NOTE]
> The hosted backend runs on a free Render plan. After a pause the first request can take about a minute while the service wakes up.

## Endpoints

| Method | Path | Purpose |
|---|---|---|
| GET | `/health` | Status and whether `/predict` is enabled |
| POST | `/predict` | Meal photo in; dish, confidence, top guesses and threshold out |
| POST | `/paypal/create-order` | Create a PayPal sandbox order |
| POST | `/paypal/capture-order/{order_id}` | Capture an approved order |

### GET /health

```json
{"status": "ok", "predict_enabled": true}
```

`predict_enabled` is `true` when the model code is available (local backend) and `false` on the light Render deployment.

### POST /predict

Upload a meal photo as `multipart/form-data` (open `/docs` for the exact field name). The response contains:

| Field | Meaning |
|---|---|
| `sure` | `true` when the top confidence is at or above the threshold, `false` for "not sure" |
| `dish` | The most likely dish |
| `confidence` | The model's confidence for that dish |
| `top3` | The three most likely dishes with their confidences |
| `threshold` | The confidence threshold used (0.60) |

Only available when `predict_enabled` is `true`.

### POST /paypal/create-order

Creates a PayPal sandbox order. The response contains the order id, the order status (`CREATED`) and an `approve_url` on `sandbox.paypal.com`. The buyer must open that link and approve the payment.

### POST /paypal/capture-order/{order_id}

Captures the order after the buyer approved it. A successful response has the status `COMPLETED`.

If PayPal cannot capture the order, the backend returns HTTP 502 with a message like:

```json
{"detail": "PayPal could not capture the order"}
```

## Testing the payment from /docs

1. Open `/docs` and run `POST /paypal/create-order`. Copy the order id and the `approve_url`.
2. Open the `approve_url` in a private window and approve with a sandbox **Personal** (buyer) account. Choose "Pay in full".
3. Run `POST /paypal/capture-order/{order_id}` with the same order id. Expect `COMPLETED`.

## Environment variables

Set these in `backend/.env` locally, or as environment variables on Render. Never commit them.

| Variable | Value |
|---|---|
| `PAYPAL_CLIENT_ID` | Client id of your PayPal sandbox app |
| `PAYPAL_CLIENT_SECRET` | Secret of your PayPal sandbox app |
| `PAYPAL_BASE_URL` | `https://api-m.sandbox.paypal.com` |

## Common problems

| Problem | Cause and fix |
|---|---|
| "PayPal could not capture the order" | The order was not approved yet, or was already used. Create a new order, approve it, then capture with the same order id. |
| Checkout says the account is associated with the merchant | You logged in with the sandbox **Business** account. Use the **Personal** buyer account. |
| Checkout page keeps spinning, or "Pay in 4" gets stuck | Use a private window or another browser, and choose "Pay in full". |
| First request is slow or fails | The free Render service is waking up. Open `/health` and wait about a minute. |
| `404 Not Found` on `/` | Normal. The backend has no page at `/`. |
| `predict_enabled` is `false` | Expected on Render. Run the full backend locally for `/predict`. |
