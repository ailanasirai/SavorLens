# SavorLens

**Photograph a meal. AI recognises the dish. An agent prepares a dietitian booking. PayPal payment happens only after you approve it.**

![License: MIT](https://img.shields.io/badge/license-MIT-green)
![Flutter](https://img.shields.io/badge/app-Flutter-02569B)
![FastAPI](https://img.shields.io/badge/backend-FastAPI-009688)
![TensorFlow](https://img.shields.io/badge/model-MobileNetV2-FF6F00)
![PayPal](https://img.shields.io/badge/payments-PayPal%20Sandbox-003087)

Built for the **PayPal AI Hackathon** on Devpost by Aila Nasir and David Ekeu.

SavorLens is built around one rule: **the AI can recognise and prepare, but only the person can approve a payment.** If the model is not confident, it says "not sure" instead of guessing.

## Screenshots

| Home | Scan: gyoza | Scan: burger |
|---|---|---|
| ![Home](docs/screenshots/01-home.png) | ![Gyoza](docs/screenshots/02-scan-gyoza.png) | ![Burger](docs/screenshots/04-scan-hamburger.png) |

| Scan: pizza | "Not sure" | Dietitian care |
|---|---|---|
| ![Pizza](docs/screenshots/03-scan-pizza.png) | ![Not sure](docs/screenshots/05-not-sure.png) | ![Care](docs/screenshots/06-care-for-you.png) |

| Demo dietitians | Approval |
|---|---|
| ![Dietitians](docs/screenshots/07-dietitians-demo.png) | ![Approval](docs/screenshots/08-approval.png) |

## How it works

```mermaid
flowchart LR
    A[Photo of a meal] --> B[MobileNetV2 classifier]
    B -->|confidence 0.60 or higher| C[Dish, confidence, other guesses]
    B -->|confidence below 0.60| D[Not sure]
    C --> E[Choose dietitian and time slot]
    D --> E
    E --> F[Booking agent prepares summary: who, when, how much]
    F --> G{User approves?}
    G -->|No| H[Nothing is charged]
    G -->|Yes| I[PayPal sandbox order]
    I --> J[Buyer approves in PayPal]
    J --> K[Capture order]
    K -->|COMPLETED| L[Booking confirmed]
```

## Architecture

```mermaid
flowchart TB
    subgraph Client
        APP[Flutter web app]
    end
    subgraph Local backend
        PRED[FastAPI /predict]
        MODEL[MobileNetV2 Keras model]
        PRED --> MODEL
    end
    subgraph Hosted backend on Render
        PAY[FastAPI /paypal endpoints]
    end
    PP[PayPal Orders API v2, sandbox]
    APP -->|meal photo| PRED
    APP -->|create and capture order| PAY
    PAY --> PP
```

The payment backend runs on Render. The scan endpoint (`/predict`) runs on the local backend, because the food model is not deployed to the free Render plan. If the model code is missing, `/predict` is switched off and the PayPal endpoints keep working (`/health` reports `predict_enabled`).

### Payment sequence

```mermaid
sequenceDiagram
    participant U as User
    participant A as Flutter app
    participant B as FastAPI backend
    participant P as PayPal sandbox
    U->>A: Approve and pay
    A->>B: POST /paypal/create-order
    B->>P: Create order
    P-->>B: Order id and approve link
    B-->>A: Order id and approve link
    A->>U: Open PayPal checkout
    U->>P: Approve with sandbox buyer account
    U->>A: I approved in PayPal
    A->>B: POST /paypal/capture-order/{order_id}
    B->>P: Capture order
    P-->>B: Status
    B-->>A: Status
    A->>U: Confirmed only if status is COMPLETED
```

## How PayPal is used

- **PayPal Orders API v2**, sandbox environment only. No real money is used.
- After the user approves a booking, the FastAPI backend creates a PayPal order. The user approves it in PayPal checkout with a sandbox buyer account. The backend then captures the order.
- The booking is confirmed **only if PayPal returns `COMPLETED`**. Real errors are shown, not hidden.
- PayPal keys live only in environment variables (Render) and a local `backend/.env`. They are never committed.

## How AI is used

- **Dish recognition:** MobileNetV2 (TensorFlow/Keras), transfer learning on Food-101, 12 dishes: pizza, sushi, ramen, tacos, lasagna, hamburger, fried rice, pad thai, pancakes, hummus, samosa, gyoza.
- **Honest confidence:** below a threshold of 0.60 the app answers "not sure". The threshold was chosen on validation data.
- **Booking agent step:** the booking summary (who, when, how much) is prepared by a **rule-based** step. It does not use a language model.
- Training notebook: [SavorLens Food Classifier on Kaggle](https://www.kaggle.com/code/ailanasirai/savorlens-food-classifier)

### Measured results

| Metric | Value |
|---|---|
| Validation accuracy | 82.2% |
| Test accuracy (3,000 held-out photos) | 84.7% |
| Photos answered at threshold 0.60 | 83% |
| Accuracy on the photos it answers | 92.5% |

Known weakness: hummus is over-predicted, and tacos, pancakes and ramen get mixed up. All numbers come from a test set the model never saw during training.

## Honest limits

- The six dietitian profiles are **demo profiles**. Real dietitian onboarding with licence verification is future work.
- Payments run in the **PayPal sandbox** only.
- Nutrition values show "not measured yet". We do not invent numbers.
- The model knows 12 dishes. Dishes outside them (for example shawarma or biryani) end as "not sure".
- The free AI coach button is a placeholder.
- SavorLens is not medical advice.

## Getting started

**Requirements:** Python 3.10 or newer, Flutter SDK, and a PayPal Developer sandbox app (client id and secret).

### 1. Backend

```bash
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
uvicorn main:app --reload --port 8000
```

Open `http://127.0.0.1:8000/health`. You should see `{"status":"ok","predict_enabled":true}`.

Fill `backend/.env` with your own sandbox values:

```
PAYPAL_CLIENT_ID=your_sandbox_client_id
PAYPAL_CLIENT_SECRET=your_sandbox_client_secret
PAYPAL_BASE_URL=https://api-m.sandbox.paypal.com
```

For a PayPal-only setup without TensorFlow, install `requirements-paypal.txt` instead. `/predict` is then disabled and `/health` shows `predict_enabled: false`.

### 2. Flutter app

```bash
cd app
flutter pub get
flutter run -d web-server --web-port 8080
```

Open `http://localhost:8080` in Chrome.

- The scan screen calls `http://localhost:8000/predict` (your local backend).
- The approval screen calls the hosted payment backend at `https://savorlens.onrender.com`. It runs on a free plan, so the first request can take about a minute to wake up.

### 3. Testing a payment

Use a PayPal sandbox **Personal** (buyer) account at checkout, ideally in a private window and with "Pay in full" (not "Pay in 4"). Logging in with the sandbox Business account shows a "merchant account" error.

<!-- Add the judge sandbox buyer note here after David creates that account. -->

## Backend endpoints

| Method | Path | Purpose |
|---|---|---|
| GET | `/health` | Status and whether `/predict` is enabled |
| POST | `/predict` | Meal photo in, dish, confidence, top 3 and threshold out |
| POST | `/paypal/create-order` | Create a PayPal sandbox order |
| POST | `/paypal/capture-order/{order_id}` | Capture an approved order |

## Project structure

```
SavorLens/
  app/        Flutter web app (scan, dietitian and approval screens)
  backend/    FastAPI backend (PayPal endpoints and /predict)
    model/    MobileNetV2 Keras model and model_report.json
  docs/
    screenshots/
  LICENSE     MIT
```

## Team

- **Aila Nasir** (team lead): Flutter app, backend and AI model.
- **David Ekeu**: PayPal developer account, sandbox setup, testing and backend deployment on Render.

## Credits

- Food images for training: [Food-101](https://data.vision.ee.ethz.ch/cvl/datasets_extra/food-101/) (Bossard et al.), used through the Kaggle mirror `kmader/food41`, for training and evaluation only.
- Dish photos shown in the app come from Pixabay contributors.
- Built with Flutter, FastAPI, TensorFlow/Keras and the PayPal Orders API.

## Future work

Pakistani dishes (karahi, nihari, haleem, seekh kabab, biryani) from our own photo dataset, nutrition estimates with a clear source, and real dietitian onboarding with licence verification. These are planned, not built yet.

## License

[MIT](LICENSE)
