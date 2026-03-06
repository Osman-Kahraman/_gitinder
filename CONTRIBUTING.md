# Contributing to _gitinder

Thank you for your interest in contributing to `_gitinder`! Contributions are welcome! 
This project is open to improvements, bug fixes, and new ideas. If you have any suggestions or improvements, 
please create an issue or submit a pull request.

---

## Getting Started

1.	Fork the repository

2.	Clone your fork

```bash
git clone https://github.com/Osman-Kahraman/_gitinder.git
cd _gitinder
```

3.	Create a new branch for your change

```bash
git checkout -b feature/YOUR-FEATURE-NAME
```

4.	Make your changes and commit them

```bash
git commit -m "Add: short description of your change"
```

5. Push the branch

```bash
git push origin feature/your-feature-name
```

6.	Open a Pull Request.

---

## Development Setup

Before running the project, configure the OAuth backend.

### 1. Add GitHub OAuth credentials

Copy `.env.example` file to `env` and `Config.xcconfig.example` file to `Config.xcconfig` for local development.

```bash
cp oauth/.env.example outh/.env
cp _gitinder/Resources/Config.xcconfig.example _gitinder/Resources/Config.xcconfig
```

Edit the `.env` and `Config.xcconfig` file. 

```bash
nano oauth/.env
nano _gitinder/Resources/Config.xcconfig
```

Fill with your credentials:
```sh
CLIENT_ID=YOUR-GITHUB-OAUTH-APP-ID
CLIENT_SECRET=YOUR-GITHUB-OAUTH-APP-SECRET
```

### 2. Start the backend server

```bash
cd oauth
npm install
node server.js
```

### 3. Run the iOS app

```sh
_gitinder.xcodeproj
```

Run the app using Xcode.

---

## Contribution Guidelines

Please follow these rules when contributing:
- Write clear commit messages
- Keep pull requests focused on one change
- Follow the existing SwiftUI code style
- Test the app before submitting a PR

Example commit message:

```sh
Fix: correct repository language parsing
Add: swipe animation improvement
Refactor: AuthManager cleanup
```

---

## Feature Ideas

Some ideas that could improve the project:
- Repository preview before swipe
- Swipe up to open README
- Advanced repository filtering
- Offline cache for repositories
- Improved GitHub profile integration

---

Thank you for helping improve `_gitinder`.