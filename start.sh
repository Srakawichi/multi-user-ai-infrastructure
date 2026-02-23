#!/bin/bash
set -e

echo "Starting infrastructure..."
docker-compose up -d

echo "Waiting for model initialization to complete..."
docker-compose logs -f ollama-init &

LOG_PID=$!

# wait until the init container has finished
docker wait multi-user-ai-infrastructure-ollama-init-1 > /dev/null

# stop the log following
kill $LOG_PID 2>/dev/null || true

echo ""
echo "✔ Models successfully installed."
echo "✔ OpenWebUI is ready at: http://localhost:8080"

