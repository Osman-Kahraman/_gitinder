# _gitinder

<p align="center">
  <img src="https://github.com/user-attachments/assets/4f5c198c-bb2d-4697-9009-e200f9cfae41" width="300"/>
  <img src="https://github.com/user-attachments/assets/319aa85b-753a-47f1-b434-1c174f8a9bc7" width="300"/>
</p>

Swipe-based GitHub repository discovery app built with SwiftUI.

_gitinder_ reimagines how developers explore GitHub repositories by bringing Tinder-style swipe mechanics into open-source discovery.

Instead of scrolling through endless lists, you swipe.

<p align="center">
  <b>Right → Star</b>
  <br>
  <b>Left → Skip</b>
</p>

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

- **Too many results**
- **Too much noise**
- **Not enough focus**

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

## Project Structure

```
_gitinder/
├── _gitinder.xcodeproj/              # Xcode project configuration
│
├── _gitinder/                        # iOS Application Target
│
│   ├── App/                          # Application Entry Layer
│   │   └── _gitinderApp.swift        # App entry point & environment setup
│   │
│   ├── Managers/                     # Business Logic Layer
│   │   └── AuthManager.swift         # GitHub authentication & user state
│   │
│   ├── Views/                        # UI Layer (SwiftUI)
│   │   ├── ContentView.swift         # Root view (auth routing)
│   │   ├── HomeView.swift            # Swipe-based repo discovery screen
│   │   ├── LoginView.swift           # GitHub OAuth login screen
│   │   ├── ProfileView.swift         # GitHub profile screen
│   │   │
│   │   └── Components/               # Reusable UI Components
│   │       └── SwipeCardView.swift   # Repository swipe card component
│   │
│   ├── Resources/                    # Static Resources & Config
│   │   ├── Assets.xcassets           # Images, icons, colors
│   │   ├── Fonts/                    # Custom Doto font files
│   │   ├── Preview Content/          # SwiftUI preview assets
│   └── └── Info.plist                # App configuration
│
├── .github/                          # CI/CD Configuration
│   └── workflows/
│       └── ios.yml                   # GitHub Actions pipeline
│
├── README.md                         # Project documentation
└── LICENSE                           # License file
```

---

## Usage

Come on man! Just click **_gitinder.xcodeproj** file and that's all...

---

## If You Like It

<p align="center">
  <b>Give the repo a star...</b>
  <br>
  <b>Or swipe left...</b>
</p>
