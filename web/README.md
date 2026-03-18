# \_gitinder — Web Version

Web PWA version of \_gitinder built with React, TypeScript, and Vite.

Works alongside the existing `oauth/` backend for GitHub authentication.

## Tech Stack

| Layer | Choice |
|-------|--------|
| Frontend | React 18 + TypeScript + Vite |
| Styling | Tailwind CSS v3 |
| Swipe gestures | react-tinder-card |
| HTTP | axios |
| PWA | vite-plugin-pwa |
| Icons | lucide-react |

## Setup

### 1. Start the OAuth backend

Make sure the `oauth/` server is running (see root README):

```bash
cd oauth
npm install
node server.js
```

### 2. Configure environment

```bash
cd web
cp .env.example .env
```

Edit `.env` and set your GitHub OAuth App Client ID:

```
VITE_GITHUB_CLIENT_ID=YOUR-GITHUB-OAUTH-APP-ID
VITE_BACKEND_URL=http://localhost:3000
VITE_GITHUB_REDIRECT_URI=http://localhost:5173
```

> The `VITE_GITHUB_CLIENT_ID` must match the `CLIENT_ID` in `oauth/.env`.

### 3. Install and run

```bash
npm install
npm run dev
```

Open http://localhost:5173

## Features

- Tinder-style swipe cards for GitHub repositories
- Star repos with right swipe, skip with left
- Starred history panel (persisted in localStorage)
- Repository language breakdown visualization
- Direct links to repositories on GitHub
- Keyboard shortcuts: `←` skip, `→` star
- PWA support (installable on Android)
- Dark cyber-inspired UI matching the iOS app

## GitHub OAuth App Setup

If you haven't created a GitHub OAuth App yet:

1. Go to https://github.com/settings/developers → **New OAuth App**
2. **Homepage URL:** `http://localhost:5173`
3. **Authorization callback URL:** `http://localhost:5173`
4. Copy Client ID → `web/.env` and `oauth/.env`
5. Copy Client Secret → `oauth/.env`
