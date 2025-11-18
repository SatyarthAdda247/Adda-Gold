# Adda Gold - Web Deployment Guide

## Quick Start - Local Testing

1. **Build the web app:**
   ```bash
   flutter build web --release
   ```

2. **Serve locally:**
   ```bash
   ./serve.sh
   ```
   Or manually:
   ```bash
   cd build/web
   python3 -m http.server 8000
   ```

3. **Open in browser:**
   - http://localhost:8000

## Production Deployment Options

### Option 1: Firebase Hosting (Recommended)

1. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase:**
   ```bash
   firebase login
   ```

3. **Initialize Firebase (if not already done):**
   ```bash
   firebase init hosting
   ```
   - Select existing project or create new
   - Public directory: `build/web`
   - Single-page app: Yes
   - Auto-overwrite: No

4. **Deploy:**
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

5. **Your app will be live at:**
   - `https://YOUR-PROJECT-ID.web.app`
   - `https://YOUR-PROJECT-ID.firebaseapp.com`

### Option 2: Netlify

1. **Install Netlify CLI:**
   ```bash
   npm install -g netlify-cli
   ```

2. **Login:**
   ```bash
   netlify login
   ```

3. **Deploy:**
   ```bash
   flutter build web --release
   netlify deploy --prod --dir=build/web
   ```

### Option 3: GitHub Pages

1. **Build and push to GitHub:**
   ```bash
   flutter build web --release
   cd build/web
   git init
   git add .
   git commit -m "Deploy Adda Gold"
   git branch -M main
   git remote add origin YOUR_REPO_URL
   git push -u origin main
   ```

2. **Enable GitHub Pages in repository settings:**
   - Settings → Pages
   - Source: main branch
   - Folder: / (root)

### Option 4: Custom Web Server

1. **Build:**
   ```bash
   flutter build web --release
   ```

2. **Upload all files from `build/web/` to your web server:**
   - Ensure your server supports SPA routing (redirect all routes to index.html)
   - Configure proper MIME types for `.wasm` files

## Build Output

All web files are generated in: `build/web/`

## Notes

- The app uses client-side routing, so ensure your server is configured to serve `index.html` for all routes
- For best performance, enable gzip compression on your server
- The app works offline (PWA capabilities can be added)

