#!/bin/bash
# Deploy to Netlify using API

echo "🚀 Deploying Adda Gold to Netlify..."

# Build first
echo "📦 Building web app..."
flutter build web --release

if [ ! -d "build/web" ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Check if Netlify is authenticated
if ! netlify status &>/dev/null; then
    echo "⚠️  Not authenticated with Netlify."
    echo "Please run: netlify login"
    echo "Then run this script again."
    exit 1
fi

# Deploy
echo "📤 Deploying to Netlify..."
netlify deploy --prod --dir=build/web

echo ""
echo "✅ Deployment complete!"
echo "Check your Netlify dashboard for the live URL."

