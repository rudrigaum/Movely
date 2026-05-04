# Architecture Guide 🏗

This document describes the architectural decisions, patterns and conventions used in the Movely iOS project.

---

## Overview

Movely is built with **Clean Architecture + MVVM**, following the principles of separation of concerns, testability and maintainability.

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│     Views · ViewModels · Routers        │
├─────────────────────────────────────────┤
│              Domain Layer               │
│   Entities · Use Cases · Protocols      │
├─────────────────────────────────────────┤
│               Data Layer                │
│    Repositories · Firebase · APIs       │
└─────────────────────────────────────────┘
```

The dependency rule flows **inward only** — outer layers depend on inner layers, never the reverse.

---

## Layers

### 1. Domain Layer
The core of the application. Contains pure Swift with zero external dependencies.

**Entities** — Plain data models representing business objects:
```swift
struct Trainer: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let specialties: [TrainingCategory]
    let rating: Double
    // ...
}
```

**Repository Protocols** — Contracts defining what data operations are available:
```swift
protocol TrainerRepositoryProtocol {
    func fetchFeatured() async throws -> [Trainer]
    func fetchNearby(limit: Int) async throws -> [Trainer]
    func fetchByCategory(_ category: TrainingCategory) async throws -> [Trainer]
}
```

**Use Cases** — Single-responsibility business logic operations:
```swift
final class SearchTrainersUseCase: SearchTrainersUseCaseProtocol {
    func execute(query: String, category: TrainingCategory?) async throws -> [Trainer] {
        // Combines repository call + local filtering
    }
}
```

---

### 2. Data Layer
Implements the repository protocols defined in the Domain layer using Firebase.

```swift
final class AuthRepository: AuthRepositoryProtocol {
    // Only file that imports FirebaseAuth
    func signIn(email: String, password: String) async throws -> User {
        // Firebase implementation
    }
}
```

**Key rule:** Only repository implementations know about Firebase — no other file imports Firebase SDKs.

---

### 3. Presentation Layer
Built with SwiftUI + `@Observable` (iOS 17+). Divided into ViewModels and Views.

**ViewModels** — Handle state and business logic coordination:
```swift
@Observable
@MainActor
final class HomeViewModel {
    var viewState: HomeViewState = .idle
    var featuredTrainers: [Trainer] = []

    func onAppear() async {
        viewState = .loading
        // async let for parallel fetching
        async let featured = fetchFeaturedUseCase.execute()
        async let nearby = fetchNearbyUseCase.execute(limit: 4)
        // ...
    }
}
```

**Views** — Declarative UI with no business logic:
```swift
struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @Environment(AppEnvironment.self) private var env

    var body: some View {
        // Pure UI, no business logic
    }
}
```

---

## State Management

Movely uses the modern **Swift Observation** framework (`@Observable`) introduced in iOS 17.

```swift
// ✅ Correct — modern iOS 17+
@Observable
final class HomeViewModel { }

// ❌ Avoid — legacy pattern
class HomeViewModel: ObservableObject {
    @Published var trainers: [Trainer] = []
}
```

**View State Pattern** — Each ViewModel has a dedicated state enum:
```swift
enum HomeViewState: Equatable {
    case idle
    case loading
    case loaded
    case failure(String)
}
```

This eliminates impossible states like `isLoading == true` and `errorMessage != nil` simultaneously.

---

## Navigation

Navigation uses the **Router Pattern** with `NavigationStack` and `navigationDestination(for:)`.

```swift
// Route definition
enum AuthRoute: Hashable {
    case login
    case register
    case forgotPassword
}

// Router — owns the navigation path
@Observable
final class AuthRouter {
    var path: NavigationPath = NavigationPath()

    func navigate(to route: AuthRoute) { path.append(route) }
    func navigateBack() { path.removeLast() }
    func navigateToRoot() { path = NavigationPath() }
}

// Flow View — owns the NavigationStack
struct AuthFlowView: View {
    @State private var router = AuthRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            LoginView(router: router)
                .navigationDestination(for: AuthRoute.self) { route in
                    // ...
                }
        }
    }
}
```

Views receive the router via initializer and call `router.navigate(to:)` — they never own the `NavigationStack`.

---

## Dependency Injection

Dependencies flow through two mechanisms:

**1. Initializer injection** — ViewModels receive their dependencies explicitly:
```swift
final class SearchViewModel {
    init(searchUseCase: SearchTrainersUseCaseProtocol) {
        self.searchUseCase = searchUseCase
    }
}
```

**2. Environment injection** — Global dependencies via `AppEnvironment`:
```swift
@Observable
final class AppEnvironment {
    let signInUseCase: SignInUseCaseProtocol
    let signUpUseCase: SignUpUseCaseProtocol
    var currentUser: User?
    // ...
}

// Injected at root
WindowGroup {
    RootView()
        .environment(AppEnvironment.production())
}

// Consumed anywhere in the hierarchy
struct ProfileView: View {
    @Environment(AppEnvironment.self) private var env
}
```

---

## Mocking Strategy

All repositories and use cases have protocol-based mocks inside `#if DEBUG` blocks:

```swift
protocol TrainerRepositoryProtocol {
    func fetchFeatured() async throws -> [Trainer]
}

#if DEBUG
final class TrainerRepositoryMock: TrainerRepositoryProtocol {
    var shouldFail: Bool = false
    var delay: UInt64 = 800_000_000

    func fetchFeatured() async throws -> [Trainer] {
        try await Task.sleep(nanoseconds: delay)
        if shouldFail { throw TrainerError.networkError }
        return Trainer.mockFeatured
    }
}
#endif
```

This enables:
- **Previews** — instant UI development without Firebase
- **Unit Tests** — fast, deterministic, no network calls
- **Failure scenarios** — `shouldFail = true` to test error states

---

## Design System

UI tokens are defined as Swift extensions for compile-time safety:

```swift
// Colors
extension ShapeStyle where Self == Color {
    static var movelyPrimary: Color { ... }
    static var movelyBackground: Color { ... }
}

// Typography
extension Font {
    static var movely: MovelyFonts { MovelyFonts() }
}

// Spacing (4pt grid)
extension CGFloat {
    static var movely: MovelySpacing { MovelySpacing() }
    // micro: 4, tiny: 8, small: 16, medium: 20, large: 24...
}
```

---

## Concurrency

All UI updates happen on the main thread via `@MainActor`:

```swift
@Observable
@MainActor
final class HomeViewModel {
    // All property updates are guaranteed on main thread
}
```

Parallel async operations use `async let`:
```swift
async let featured = fetchFeaturedUseCase.execute()
async let nearby = fetchNearbyUseCase.execute(limit: 4)
let (f, n) = try await (featured, nearby) // both run in parallel
```

Debounced search uses `Task` cancellation:
```swift
private var searchTask: Task<Void, Never>?

func onQueryChanged() {
    searchTask?.cancel()
    searchTask = Task {
        try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
        guard !Task.isCancelled else { return }
        await performSearch()
    }
}
```

---

## Testing Strategy

Tests mirror the app folder structure:

```
MovelyTests/
├── Domain/
│   ├── Utils/          → ValidatorsTests
│   └── UseCases/       → SignInUseCaseTests, SearchTrainersUseCaseTests...
└── Presentation/
    ├── Home/           → HomeViewModelTests
    └── Search/         → SearchViewModelTests
```

Uses **Swift Testing** framework (`import Testing`) — modern, expressive, iOS 17+:

```swift
@Suite("SearchTrainersUseCase")
@MainActor
struct SearchTrainersUseCaseTests {

    @Test("Query should be case insensitive")
    func queryIsCaseInsensitive() async throws {
        let results = try await sut.execute(query: "CARLOS", category: nil)
        #expect(!results.isEmpty)
    }
}
```

---

## Coding Conventions

| Convention | Rule |
|---|---|
| Language | Code and comments in English |
| Commits | Conventional Commits (`feat:`, `fix:`, `chore:`) |
| Async | `async/await` — no callbacks or Combine |
| State | `@Observable` — no `ObservableObject` or `@Published` |
| Optionals | Never initialize with `= nil` explicitly |
| Imports | Only `AuthRepository` imports `FirebaseAuth` |
| Mocks | Always inside `#if DEBUG` blocks |
| Previews | Every View file has at least one `#Preview` |
