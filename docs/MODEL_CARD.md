# Model card: SavorLens food classifier

## Summary

| | |
|---|---|
| Task | Recognise one of 12 dishes from a single meal photo |
| Model | MobileNetV2 (TensorFlow/Keras), transfer learning |
| Training data | Food-101 (Bossard et al.), via the Kaggle mirror `kmader/food41` |
| Output | Dish, confidence and the closest other guesses, or "not sure" |
| Threshold | 0.60, chosen on validation data |
| Notebook | [SavorLens Food Classifier on Kaggle](https://www.kaggle.com/code/ailanasirai/savorlens-food-classifier) |
| Model file | `backend/model/savorlens_food.keras` (about 9.8 MB) and `model_report.json` |

## Classes

Pizza, sushi, ramen, tacos, lasagna, hamburger, fried rice, pad thai, pancakes, hummus, samosa, gyoza.

## Results

All numbers are measured on photos the model never saw during training.

| Metric | Value |
|---|---|
| Validation accuracy | 82.2% |
| Test accuracy (3,000 held-out photos) | **84.7%** |
| Photos answered at threshold 0.60 | 83% |
| Accuracy on the photos it answers | 92.5% |

The "not sure" threshold trades coverage for reliability. At 0.60 the model answers 83% of photos and is right 92.5% of the time on those. The other 17% end as "not sure".

## Real examples

| Photo | Result |
|---|---|
| Gyoza | Gyoza, 91% |
| Pizza | Pizza, 65% |
| Shawarma wrap | **Not sure**: Tacos 59%, Samosa 23%, Hamburger 8% |

Shawarma is not one of the 12 dishes, and 59% is below the threshold, so the app correctly refuses to guess. The threshold is not lowered to make demos look better, because that would make the numbers above false.

## Training notes

- Transfer learning from MobileNetV2 with a new classification head for 12 dishes.
- A fine-tuning experiment did not improve accuracy, so it was dropped and is not reported.
- Results come from a held-out test set, not from the training or validation data.

## Known weaknesses

- Hummus is over-predicted.
- Tacos, pancakes and ramen are sometimes mixed up.
- Dishes outside the 12 classes (for example shawarma, biryani, karahi, nihari, haleem, seekh kabab, salads, fruits) can only end as "not sure" or a wrong guess.
- Photos with several dishes, unusual lighting or heavy cropping were not evaluated separately.

## Intended use and limits

- **Intended use:** a hackathon prototype that shows a meal-recognition step followed by a human-approved dietitian booking.
- **Not intended for:** medical or dietary decisions, allergen detection or calorie counting. Nutrition values in the app show "not measured yet".
- This is not medical advice.

## Data and licence

Food-101 is credited to its original authors (Bossard, Guillaumin, Van Gool). It was used through the Kaggle mirror `kmader/food41` (licence listed as "Data files (c) Original Authors") for training and evaluation only. The dataset is not redistributed in this repository.

## Next version

Pakistani dishes (karahi, nihari, haleem, seekh kabab, biryani) trained from our own photos, with the same honest test-set reporting. This is planned, not built yet.
