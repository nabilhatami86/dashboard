#!/bin/bash

echo "🚀 Starting Dashboard Application..."
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping all services..."
    kill $(jobs -p) 2>/dev/null
    exit
}

trap cleanup SIGINT SIGTERM

# Start ngrok in background
echo "📡 Starting ngrok tunnel..."
cd backend-dashboard-python/backend-dashboard-python.backup
ngrok http 8000 > /dev/null 2>&1 &
NGROK_PID=$!
sleep 3

# Start backend
echo "🐍 Starting FastAPI backend on port 8000..."
python -m uvicorn app.main:app --reload --port 8000 --host 0.0.0.0 > backend.log 2>&1 &
BACKEND_PID=$!
sleep 2

# Start frontend
echo "⚛️  Starting Next.js frontend on port 3000..."
cd ../../dashboard-message-center
npm run dev > frontend.log 2>&1 &
FRONTEND_PID=$!

echo ""
echo "✅ All services started!"
echo ""
echo "📊 Services:"
echo "   - Frontend:  http://localhost:3000"
echo "   - Backend:   http://localhost:8000"
echo "   - API Docs:  http://localhost:8000/docs"
echo ""
echo "📝 Logs:"
echo "   - Backend:   tail -f backend-dashboard-python/backend-dashboard-python.backup/backend.log"
echo "   - Frontend:  tail -f dashboard-message-center/frontend.log"
echo ""
echo "Press Ctrl+C to stop all services"
echo ""

# Wait for all background processes
wait
