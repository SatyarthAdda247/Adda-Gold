#!/bin/bash
# Quick local server for testing the web app

PORT=${1:-8000}

echo "🌐 Starting local server on port $PORT..."
echo "📱 Open http://localhost:$PORT in your browser"
echo ""

cd build/web

# Try different server options
if command -v python3 &> /dev/null; then
    python3 -m http.server $PORT
elif command -v python &> /dev/null; then
    python -m SimpleHTTPServer $PORT
elif command -v php &> /dev/null; then
    php -S localhost:$PORT
elif command -v npx &> /dev/null; then
    npx serve -p $PORT
else
    echo "❌ No suitable server found. Please install Python, PHP, or Node.js"
    exit 1
fi

