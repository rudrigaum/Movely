# Movely 🏋️

> A personal trainer marketplace connecting students with personal trainers.

[![CI](https://github.com/rudrigaum/Movely/actions/workflows/ci.yml/badge.svg)](https://github.com/rudrigaum/Movely/actions/workflows/ci.yml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=rudrigaum_Movely&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=rudrigaum_Movely)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=rudrigaum_Movely&metric=coverage)](https://sonarcloud.io/summary/new_code?id=rudrigaum_Movely)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📱 Screenshots

<!-- Add screenshots here after UI is complete -->
> Screenshots coming soon.

---

## ✨ Features

- 🔐 **Authentication** — Sign up and sign in with email and password
- 🏠 **Home** — Browse featured and nearby personal trainers
- 🔍 **Search** — Search trainers by name, specialty or location
- 👤 **Trainer Profile** — View trainer details, rating and book a session
- 📅 **Bookings** — Schedule and manage training sessions *(coming soon)*
- 💬 **Chat** — Message your trainer directly *(coming soon)*
- 💳 **Payments** — Pay for sessions securely via Stripe *(coming soon)*

---

## 🏗 Architecture

Movely is built with **Clean Architecture + MVVM**, ensuring clear separation of concerns across three layers:

```
Domain Layer       → Entities, Use Cases, Repository Protocols
Data Layer         → Repository Implementations, Firebase
Presentation Layer → ViewModels, Views, Routers
```

For a detailed explanation, see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| State Management | Swift Observation (`@Observable`) |
| Backend | Firebase (Auth + Firestore) |
| Architecture | Clean Architecture + MVVM |
| Navigation | NavigationStack + Router Pattern |
| CI/CD | GitHub Actions |
| Code Quality | SwiftLint + SonarCloud |

---

## 🚀 Getting Started

### Prerequisites

- Xcode 15.4+
- iOS 17.0+ Simulator or Device
- [Firebase account](https://firebase.google.com)

### Setup

1. **Clone the repository**
```bash
git clone https://github.com/rudrigaum/Movely.git
cd Movely
```

2. **Open the project**
```bash
open Movely.xcodeproj
```

3. **Configure Firebase**
   - Create a project at [Firebase Console](https://console.firebase.google.com)
   - Add an iOS app with bundle ID `com.rudrigo.Movely`
   - Download `GoogleService-Info.plist`
   - Add it to `Movely/Resources/` (never commit this file)

4. **Resolve Swift Package dependencies**
   - Xcode will resolve packages automatically on first open

5. **Run the app**
   - Select an iOS 17+ simulator
   - Press `Cmd + R`

---

## 🧪 Running Tests

```bash
# Run all tests
Cmd + U

# Run tests via xcodebuild
xcodebuild test \
  -project Movely.xcodeproj \
  -scheme Movely \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5'
```

---

## 📁 Project Structure

```
Movely/
├── App/                    # App entry point and root navigation
├── Core/
│   ├── Domain/
│   │   ├── Entities/       # User, Trainer, Booking
│   │   ├── Repositories/   # Repository protocols
│   │   ├── UseCases/       # Business logic
│   │   └── Utils/          # Validators, helpers
│   ├── Data/
│   │   └── Repositories/   # Firebase implementations
│   └── DI/                 # AppEnvironment (dependency injection)
├── Features/
│   ├── Auth/               # Login, Register, ForgotPassword
│   ├── Student/            # Home, Search, Bookings, Profile
│   ├── Trainer/            # Trainer dashboard (coming soon)
│   ├── TrainerProfile/     # Trainer detail screen
│   └── Navigation/         # MainTabView, routing
└── Shared/
    ├── Components/         # MovelyButton, MovelyTextField, TrainerCard
    ├── DesignSystem/       # Colors, Typography, Spacing
    ├── Extensions/         # Swift extensions
    └── ViewModifiers/      # Reusable SwiftUI modifiers

MovelyTests/
├── Domain/
│   ├── UseCases/           # Use case unit tests
│   └── Utils/              # Validator tests
└── Presentation/
    ├── Home/               # HomeViewModel tests
    └── Search/             # SearchViewModel tests
```

---

## 🔄 Git Workflow

```
main          → Production-ready code
feat/*        → New features
fix/*         → Bug fixes
chore/*       → Internal tasks
refactor/*    → Code refactoring
test/*        → Test coverage
```

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/):
```
feat(auth): add forgot password flow
fix(home): fix trainer card tap not navigating
chore(ci): update GitHub Actions to v5
```

---

## 📊 Code Quality

- **SwiftLint** — enforces Swift style and conventions
- **SonarCloud** — tracks code quality, coverage and security

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=rudrigaum_Movely&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=rudrigaum_Movely)

---

## 🗺 Roadmap

- [x] Design System
- [x] Authentication Flow
- [x] Home Screen
- [x] Trainer Profile
- [x] Search
- [x] User Profile
- [ ] Firestore Integration
- [ ] Bookings
- [ ] Stripe Payments
- [ ] Chat
- [ ] Android Version (Kotlin)
- [ ] Push Notifications

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Rodrigo Cerqueira**
- GitHub: [@rudrigaum](https://github.com/rudrigaum)

---

> Built with ❤️ using SwiftUI and Clean Architecture.
