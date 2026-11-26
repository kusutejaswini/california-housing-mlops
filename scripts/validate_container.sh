#!/usr/bin/env bash
set -euo pipefail

curl --fail --silent --show-error \
  http://127.0.0.1:8501/_stcore/health >/dev/null
curl --fail --silent --show-error \
  http://127.0.0.1:8501/ >/dev/null

docker compose exec -T california-housing-ui python -c \
  'import math, mlflow.sklearn; model = mlflow.sklearn.load_model("/app/model"); predictions = model.predict([[5.0, 20.0, 5.0, 1.0, 1000.0, 3.0, 36.0, -120.0]]); assert len(predictions) == 1 and math.isfinite(float(predictions[0]))'
