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

### 1. Create / update GitHub OAuth App

The web version requires a GitHub OAuth App with a **web callback URL**.

> **Important:** The iOS app uses callback URL `gitinder://callback`. The web version needs `http://localhost:5173`. You can either:
> - **Option A:** Update your existing OAuth App to add `http://localhost:5173` as the callback URL
> - **Option B:** Create a new OAuth App specifically for the web version

To create a new one:

1. Go to https://github.com/settings/developers → **New OAuth App**
2. **Application name:** `_gitinder-web` (or any name)
3. **Homepage URL:** `http://localhost:5173`
4. **Authorization callback URL:** `http://localhost:5173`
5. Click **Register application**
6. Copy your **Client ID** and generate a **Client Secret**

### 2. Configure the OAuth backend

```bash
cd oauth
cp .env.example .env
```

Edit `oauth/.env`:

```
CLIENT_ID=<your Client ID>
CLIENT_SECRET=<your Client Secret>
```

Start the backend:

```bash
npm install
node server.js
```

The auth server will run on `http://localhost:3000`.

### 3. Configure and run the web app

```bash
cd web
cp .env.example .env
```

Edit `web/.env`:

```
VITE_GITHUB_CLIENT_ID=<same Client ID as oauth/.env>
VITE_BACKEND_URL=http://localhost:3000
VITE_GITHUB_REDIRECT_URI=http://localhost:5173
```

Install and run:

```bash
npm install
npm run dev
```

Open http://localhost:5173

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| **404 on GitHub login** | `VITE_GITHUB_CLIENT_ID` is missing or invalid | Make sure `web/.env` exists with a valid Client ID |
| **OAuth exchange failed** | Backend not running or `CLIENT_SECRET` is wrong | Check that `oauth/` server is running on port 3000 and `oauth/.env` has correct credentials |
| **404 after GitHub redirect** | Callback URL mismatch | Ensure your OAuth App's callback URL is exactly `http://localhost:5173` |

## Features

- Tinder-style swipe cards for GitHub repositories
- Star repos with right swipe, skip with left
- Starred history panel (persisted in localStorage)
- Repository language breakdown visualization
- Direct links to repositories on GitHub
- Keyboard shortcuts: `←` skip, `→` star
- PWA support (installable on Android)
- Dark cyber-inspired UI matching the iOS app
