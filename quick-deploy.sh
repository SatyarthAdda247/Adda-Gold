#!/bin/bash
# Quick Netlify deployment script

echo "🚀 Deploying Adda Gold to Netlify..."

# Ensure we're in the right directory
cd "$(dirname "$0")"

# Build the app
echo "📦 Building web app..."
flutter build web --release

# Deploy to Netlify
echo "📤 Deploying to Netlify..."
netlify deploy --prod --dir=build/web

echo ""
echo "✅ Check your Netlify dashboard for the live URL!"

