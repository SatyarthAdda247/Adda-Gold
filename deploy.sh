#!/bin/bash
# Simple deployment script for Adda Gold web app

echo "🚀 Deploying Adda Gold Web App..."

# Build the web app
echo "📦 Building web app..."
flutter build web --release

# Check if build was successful
if [ ! -d "build/web" ]; then
    echo "❌ Build failed! build/web directory not found."
    exit 1
fi

echo "✅ Build complete!"
echo ""
echo "📂 Web files are in: build/web"
echo ""
echo "🌐 To serve locally, run one of these commands:"
echo "   - Python: python3 -m http.server 8000 --directory build/web"
echo "   - Node: npx serve build/web"
echo "   - PHP: php -S localhost:8000 -t build/web"
echo ""
echo "📤 For production deployment:"
echo "   1. Upload build/web/* to your web server"
echo "   2. Or use Firebase Hosting: firebase deploy"
echo "   3. Or use Netlify: netlify deploy --prod --dir=build/web"

