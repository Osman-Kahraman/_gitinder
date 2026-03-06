# _gitinder

<p align="center">
  <img width="300" src="https://github.com/user-attachments/assets/12ae8f92-fa17-4976-ad88-9b07b6f85808" />
  <img width="300" src="https://github.com/user-attachments/assets/11fc0db8-2a55-4634-bf62-4072ccaf3aef" />
</p>


Swipe-based GitHub repository discovery app built with SwiftUI.

_gitinder_ reimagines how developers explore GitHub repositories by bringing Tinder-style swipe mechanics into open-source discovery.

Instead of scrolling through endless lists, you swipe.

<p align="center">
  <b>Right → Star</b>
  <br>
  <b>Left → Skip</b>
</p>

## Why _gitinder?

GitHub’s list-based discovery can feel overwhelming.

When searching for useful repositories, you often get:

- **Too many results**
- **Too much noise**
- **Not enough focus**

`_gitinder` solves this by presenting one repository at a time in a clean, interactive card interface. Which means less scrolling and more discovering.


## Features

- GitHub OAuth authentication
- Swipe-based repository browsing
- Star repositories directly from the app
- Repository stats (stars, forks, issues)
- Language breakdown visualization
- GitHub profile integration
- Dark cyber-inspired UI
- Smooth SwiftUI animations

## Authentication Architecture

Mobile apps cannot securely store a GitHub client secret.

To solve this:

1. The app requests an authorization code from GitHub.
2. The code is sent to a lightweight backend.
3. The backend securely exchanges it for an access token.
4. The token is returned to the app.

This keeps secrets off-device and production-safe.

## Installation

1. Clone the repository:
   
```bash
git clone https://github.com/Osman-Kahraman/_gitinder.git
```

3. Open in Xcode
4. Configure your GitHub OAuth credentials
5. Run on simulator

## Requirements

To run _gitinder_ locally, you will need:

### Development Environment

- macOS (latest stable version recommended)
- Xcode 15+
- iOS 17+ Simulator or physical device
- Swift 5.9+

## Usage

Before running the app, you must configure the GitHub OAuth credentials and start the backend authentication server.

### 1. Configure OAuth Credentials

You should create a GitHub OAuth App here:
https://github.com/settings/developers

Set the callback URL to:
```bash
gitinder://callback
```

Once you have created the OAuth app and obtained your Client ID and Client Secret, switch to your terminal and navigate to the project folder.

```bash
cd _gitinder
```

Copy the example configuration files for local development:

```bash
cp oauth/.env.example oauth/.env
cp _gitinder/Resources/Config.xcconfig.example _gitinder/Resources/Config.xcconfig
```

Open the files and fill in your GitHub OAuth credentials.

```bash
nano oauth/.env
nano _gitinder/Resources/Config.xcconfig
```

Add your credentials:
```bash
CLIENT_ID=YOUR-GITHUB-OAUTH-APP-ID
CLIENT_SECRET=YOUR-GITHUB-OAUTH-APP-SECRET
```

### 2. Start the Backend Server

Navigate to the backend directory and start the OAuth server:

```bash
cd oauth
npm install
node server.js
```

### 3. Run the iOS App

Open the project in Xcode:

```sh
_gitinder.xcodeproj
```

Run the app on the simulator or your device.

*Once everything is configured, you can log in with GitHub and start discovering repositories with swipe gestures.*

## If You Like It

<p align="center">
  <b>Give the repo a star...</b>
  <br>
  <b>Or swipe left...</b>
</p>
