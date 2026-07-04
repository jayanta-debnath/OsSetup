#!/usr/bin/env bash

set -euo pipefail

COMFYUI_DIR="$HOME/GitRepos/ComfyUI"
URL="http://127.0.0.1:8188"

cd "$COMFYUI_DIR"

is_running() {
    curl -fs "$URL" >/dev/null 2>&1
}

# Already running?
if is_running; then
    echo "ComfyUI is already running."
    echo "Opening browser..."
    xdg-open "$URL" >/dev/null 2>&1 &
    exit 0
fi

echo "Activating virtual environment..."
source .venv/bin/activate

echo "Checking CUDA..."
python -c 'import torch; print(f"CUDA Available: {torch.cuda.is_available()}")'

echo
echo "Starting ComfyUI..."

python main.py &
COMFY_PID=$!

cleanup() {
    echo
    echo "Stopping ComfyUI..."
    kill -SIGINT "$COMFY_PID" 2>/dev/null || true
}

trap cleanup EXIT INT TERM

echo "Waiting for ComfyUI to become ready..."

until curl -fs "$URL" >/dev/null 2>&1; do
    sleep 1
done

echo "Opening browser..."
xdg-open "$URL" >/dev/null 2>&1 &

wait "$COMFY_PID"
