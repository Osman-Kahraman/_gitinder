# _gitinder

Swipe-based GitHub repository discovery app built with SwiftUI.

_gitinder_ reimagines how developers explore GitHub repositories by bringing Tinder-style swipe mechanics into open-source discovery.

Instead of scrolling through endless lists, you swipe.

Right → Star  
Left → Skip  

---

## Features

- GitHub OAuth authentication
- Swipe-based repository browsing
- Star repositories directly from the app
- Repository stats (stars, forks, issues)
- Language breakdown visualization
- GitHub profile integration
- Dark cyber-inspired UI
- Smooth SwiftUI animations

---

## Why _gitinder?

GitHub’s list-based discovery can feel overwhelming.

When searching for useful repositories, you often get:

- Too many results
- Too much noise
- Not enough focus

__gitinder_ solves this by presenting one repository at a time in a clean, interactive card interface. Which means less scrolling and more discovering.

---

## Authentication Architecture

Mobile apps cannot securely store a GitHub client secret.

To solve this:

1. The app requests an authorization code from GitHub.
2. The code is sent to a lightweight backend.
3. The backend securely exchanges it for an access token.
4. The token is returned to the app.

This keeps secrets off-device and production-safe.

---

## Installation

1. Clone the repository:
   
```sh
git clone https://github.com/Osman-Kahraman/_gitinder.git
```

3. Open in Xcode
4. Configure your GitHub OAuth credentials
5. Run on simulator

---

## Requirements

To run _gitinder_ locally, you will need:

### Development Environment

- macOS (latest stable version recommended)
- Xcode 15+
- iOS 17+ Simulator or physical device
- Swift 5.9+

---

## If You Like It

Give the repo a star...
Or swipe right...
