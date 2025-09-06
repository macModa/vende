# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Common Development Commands

### Setup and Dependencies
```bash
# Install Flutter dependencies
flutter pub get

# Generate code for JSON serialization, Riverpod, and Hive
flutter pub run build_runner build

# Watch for changes and regenerate code automatically
flutter pub run build_runner watch
```

### Running the App
```bash
# Run on default device
flutter run

# Run in debug mode with hot reload
flutter run --debug

# Run in profile mode for performance testing
flutter run --profile

# Run in release mode
flutter run --release

# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### Testing and Code Quality
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart

# Run tests with coverage
flutter test --coverage

# Analyze code for issues
flutter analyze

# Format code according to Dart style
dart format lib/ test/

# Check for outdated packages
flutter pub outdated
```

### Build Commands
```bash
# Build APK for Android
flutter build apk

# Build App Bundle for Google Play
flutter build appbundle

# Build iOS app (requires Xcode)
flutter build ios

# Clean build cache
flutter clean
```

### Firebase Setup Commands
```bash
# Initialize Firebase (if not already done)
firebase init

# Deploy Firebase functions (if any)
firebase deploy --only functions

# View Firebase project status
firebase projects:list
```

## Code Architecture

### High-Level Structure
This is a Flutter mobile application built using **Clean Architecture** principles with **feature-based modularization**. The app uses **Riverpod** for state management and **Firebase** for authentication and backend services.

### Key Architectural Patterns

#### 1. Feature-Based Modular Architecture
- Each feature is self-contained in its own directory under `lib/features/`
- Features include: `auth`, `products`, `cart`, `profile`
- Each feature follows the same structure: `data/`, `domain/`, `presentation/`

#### 2. State Management with Riverpod
- All state is managed through Riverpod providers
- Providers are organized by feature and responsibility
- Authentication state is globally accessible through `authStateProvider`
- Product data flows through `ProductRepository` and related providers

#### 3. Navigation Architecture
- Uses **GoRouter** for declarative routing
- Navigation service located in `lib/shared/services/navigation_service.dart`
- **ShellRoute** pattern for bottom navigation tabs
- Authentication routes are separate from main app routes

### Core Components

#### Authentication Flow
- **Firebase Auth** integration with email/password and Google Sign-In
- Auth state managed through `lib/features/auth/presentation/providers/auth_providers.dart`
- Authentication wrapper determines app entry point
- Session persistence handled by Firebase Auth

#### Product System
- **Repository Pattern** for data access (`lib/features/products/data/product_repository.dart`)
- **Domain Models** with JSON serialization (`lib/features/products/domain/product.dart`)
- Category-based product organization
- Mock data system for development (`assets/data/mock_products.json`)

#### Theme and Design System
- **Tunisian-inspired color palette** in `lib/core/theme/app_theme.dart`
- **Accessibility-focused** with larger fonts for older users
- **Material 3** design system with custom theming
- Responsive design patterns throughout

### Data Flow Architecture

#### State Management Flow
1. **UI Components** consume data through Riverpod `Consumer*` widgets
2. **Providers** manage state and business logic
3. **Repositories** abstract data access (local storage, Firebase, mock data)
4. **Services** handle external integrations (Firebase, navigation)

#### Authentication Flow
1. User interactions trigger auth methods in `AuthService`
2. Firebase Auth manages authentication state
3. `authStateProvider` streams auth changes
4. Router redirects based on authentication status
5. UI updates reactively through provider watchers

#### Product Data Flow
1. UI requests product data through providers
2. `ProductRepository` checks local storage (Hive) first
3. If not cached, fetches from mock data or Firebase
4. Data is serialized through domain models
5. State updates trigger UI rebuilds

### Key Dependencies Integration

#### Riverpod Provider Architecture
- **Global Providers**: Auth state, navigation, theme
- **Feature Providers**: Product data, cart state, user profile
- **Generated Providers**: Using `riverpod_annotation` for type safety

#### Firebase Integration
- Authentication handled in `lib/features/auth/data/auth_service.dart`
- Initialization in `main.dart` before app starts
- Configuration files required: `google-services.json` (Android), `GoogleService-Info.plist` (iOS)

#### Local Storage Strategy
- **Hive** for structured data caching
- **SharedPreferences** for simple key-value storage
- **Firebase Auth** for session persistence

### Development Patterns

#### Code Generation Dependencies
- **JSON Serialization**: `json_annotation` + `json_serializable`
- **Riverpod Code Gen**: `riverpod_annotation` + `riverpod_generator`
- **Hive Type Adapters**: `hive_generator`
- Always run `flutter pub run build_runner build` after model changes

#### Error Handling Patterns
- Consistent error handling across all features
- User-friendly error messages in Arabic/French context
- Loading states managed through Riverpod providers
- Network error handling with retry mechanisms

#### Testing Strategy
- Unit tests for business logic and repositories
- Widget tests for UI components
- Integration tests for complete user flows
- Mock data for isolated testing

### Cultural and Accessibility Considerations
- **Tunisian Market Context**: Authentic product categories and cultural elements
- **Accessibility**: Large touch targets, readable fonts, proper semantic labels
- **Multi-language Ready**: Text externalization patterns for Arabic/French support
- **Responsive Design**: Optimized for various screen sizes and orientations

### Firebase Project Requirements
- **Authentication**: Email/password and Google Sign-In enabled
- **Project Configuration**: Platform-specific config files in correct locations
- **Security Rules**: Proper Firestore rules for data access control
- **Environment Setup**: Development vs. production Firebase projects
