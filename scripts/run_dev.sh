#!/bin/bash
#
# PolicyProbe Development Server
#
# This script starts both the frontend and backend servers for development.
# Run from the project root: ./scripts/run_dev.sh
#
# Override Python version: PYTHON_PATH=/path/to/python ./scripts/run_dev.sh
#

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=========================================="
echo "  PolicyProbe Development Server"
echo "=========================================="
echo ""

# Find suitable Python interpreter (3.10+)
source "$PROJECT_ROOT/scripts/python_helper.sh"
echo ""

# Check for required environment variables
if [ -z "$OPENROUTER_API_KEY" ]; then
    echo "WARNING: OPENROUTER_API_KEY not set"
    echo "The LLM features will not work without it."
    echo "Set it with: export OPENROUTER_API_KEY=your_key_here"
    echo ""
fi

# Function to cleanup background processes on exit
cleanup() {
    echo ""
    echo "Shutting down servers..."
    kill $BACKEND_PID 2>/dev/null || true
    kill $FRONTEND_PID 2>/dev/null || true
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start backend
echo "Starting Python backend..."
cd "$PROJECT_ROOT/backend"

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "Creating Python virtual environment..."
    "$PYTHON_CMD" -m venv .venv
    source .venv/bin/activate
    echo "Installing Python dependencies..."
    pip install -r requirements.txt
else
    source .venv/bin/activate
fi

# Start uvicorn in background
uvicorn main:app --reload --host 0.0.0.0 --port 5500 &
BACKEND_PID=$!
echo "Backend started (PID: $BACKEND_PID)"
echo "Backend URL: http://localhost:5500"
echo ""

# Wait for backend to be ready
echo "Waiting for backend to be ready..."
sleep 3

# Start frontend
echo "Starting Next.js frontend..."
cd "$PROJECT_ROOT/frontend"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "Installing npm dependencies..."
    npm install
fi

# Start Next.js in background on port 5000
npm run dev -- -p 5001 &
FRONTEND_PID=$!
echo "Frontend started (PID: $FRONTEND_PID)"
echo ""

echo "=========================================="
echo "  Servers are running!"
echo "=========================================="
echo ""
echo "  Frontend: http://localhost:5001"
echo "  Backend:  http://localhost:5500"
echo "  API Docs: http://localhost:5500/docs"
echo ""
echo "  Press Ctrl+C to stop all servers"
echo "=========================================="
echo ""

# Wait for both processes
wait
