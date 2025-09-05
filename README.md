# Tunisian Marketplace

A Flutter mobile application for a traditional Tunisian marketplace featuring authentic handcrafted items from skilled artisans.

## Features

### ✨ Core Features
- **User Authentication**: Firebase Auth with email/password and Google sign-in
- **Product Catalog**: Browse authentic Tunisian products by categories
- **Featured Products**: Curated selection of artisan items
- **Product Details**: Comprehensive product information with image galleries
- **Shopping Cart**: Add items and manage purchases
- **User Profile**: Account management and settings
- **Search**: Find products across categories
- **Responsive Design**: Optimized for different screen sizes

### 🎨 Design Highlights
- **Tunisian-Inspired Theme**: Deep blue, terracotta, gold color palette
- **Accessibility-First**: Large fonts and clear buttons for older users
- **Clean Navigation**: Simple bottom navigation bar
- **Cultural Authenticity**: Emojis and design elements reflecting Tunisian heritage

### 📱 App Structure
```
lib/
├── core/
│   └── theme/                  # App theming and colors
├── features/
│   ├── auth/                   # Authentication module
│   │   ├── data/              # Auth services and Firebase integration
│   │   └── presentation/       # Login/register screens and providers
│   ├── products/               # Product catalog module
│   │   ├── data/              # Product repository and mock data
│   │   ├── domain/            # Product models
│   │   └── presentation/       # Product screens
│   ├── cart/                   # Shopping cart module
│   └── profile/                # User profile module
└── shared/                     # Shared widgets and services
    ├── services/              # Navigation and routing
    └── widgets/               # Reusable UI components
```

## Product Categories

1. **Textiles & Fabrics** 🧵
   - Handwoven Berber carpets
   - Traditional silk scarves
   - Artisan textiles

2. **Pottery & Ceramics** 🏺
   - Nabeul pottery
   - Hand-painted ceramics
   - Traditional clay items

3. **Jewelry & Accessories** 💎
   - Berber silver jewelry
   - Traditional ornaments
   - Handcrafted accessories

4. **Traditional Food** 🌶️
   - Authentic spice blends
   - Harissa and merguez spices
   - Preserved foods and oils

5. **Leather Goods** 👜
   - Handcrafted bags
   - Traditional leather items
   - Artisan accessories

6. **Art & Crafts** 🎨
   - Wood carvings
   - Traditional paintings
   - Decorative items

## Technical Stack

### Dependencies
- **Flutter**: Cross-platform mobile framework
- **Riverpod**: State management and dependency injection
- **Firebase**: Authentication and backend services
- **GoRouter**: Navigation and routing
- **Hive**: Local storage and caching
- **Phosphor Icons**: Modern icon set
- **Cached Network Image**: Image caching and loading

### Architecture
- **Clean Architecture**: Separation of concerns with data, domain, and presentation layers
- **Repository Pattern**: Abstracted data access layer
- **Provider Pattern**: State management with Riverpod
- **Feature-based Structure**: Modular organization by app features

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode for device testing
- Firebase project setup

### Installation

1. **Clone the project**
   ```bash
   git clone <repository-url>
   cd tunisian_marketplace
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Add Android/iOS apps to Firebase project
   - Download and add configuration files:
     - `android/app/google-services.json` (Android)
     - `ios/Runner/GoogleService-Info.plist` (iOS)
   - Enable Authentication (Email/Password and Google)

4. **Generate code**
   ```bash
   flutter pub run build_runner build
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Mock Data

The app includes comprehensive mock data located in `assets/data/mock_products.json` featuring:
- 8 sample products across all categories
- Product images, descriptions, and attributes
- Category information with product counts
- Featured products selection

## Key Screens

### Authentication Flow
- **Login Screen**: Email/password and Google sign-in options
- **Register Screen**: Account creation with validation
- **Auth Wrapper**: Handles authentication state management

### Main App Flow
- **Home Screen**: Featured products and category navigation
- **Categories Screen**: Browse by product categories
- **Product Detail**: Complete product information with image gallery
- **Search Screen**: Product search functionality
- **Cart Screen**: Shopping cart management
- **Profile Screen**: User account and settings

## State Management

Uses Riverpod for comprehensive state management:
- **Auth Providers**: User authentication state
- **Product Providers**: Product data and repository access
- **Navigation Providers**: Router and navigation state

## Design System

### Colors (Tunisian Palette)
- **Primary**: Deep Blue (#1B365D)
- **Secondary**: Terracotta (#D2691E)
- **Accent**: Gold (#FFD700)
- **Background**: Cream (#F5F5DC)
- **Surface**: White (#FFFFFF)

### Typography
- **Font Family**: Poppins (clean, readable)
- **Accessibility**: Optimized for older users with larger fonts
- **Hierarchy**: Clear text size hierarchy

## Development Notes

### Code Structure
- Clean, well-commented code
- Consistent naming conventions
- Error handling throughout
- Responsive layouts for different screen sizes

### Future Enhancements
- Payment integration
- Product reviews and ratings
- Wishlist functionality
- Order management
- Push notifications
- Social sharing
- Advanced search filters
- Seller profiles
- Real-time chat support

## Contributing

This project is structured for easy extension:
1. Follow the existing feature-based architecture
2. Add new features in separate modules
3. Use the established design system
4. Maintain consistency with Tunisian cultural themes

## License

This project is created as an educational example for Flutter mobile development with a focus on Tunisian marketplace functionality.

---

**Built with ❤️ for preserving and promoting Tunisian artisan traditions through modern mobile technology.**
# vende
