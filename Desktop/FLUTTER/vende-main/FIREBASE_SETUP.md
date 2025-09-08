# Firebase Setup Guide

This document provides step-by-step instructions to configure Firebase for the Tunisian Marketplace Flutter app.

## Prerequisites

1. **Google Account**: You'll need a Google account to access Firebase Console
2. **Flutter Project**: Ensure your Flutter project is set up and running
3. **Firebase CLI** (optional but recommended): Install from [firebase.google.com/docs/cli](https://firebase.google.com/docs/cli)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"**
3. Enter project name: `tunisian-marketplace` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Choose or create a Google Analytics account
6. Click **"Create project"**

## Step 2: Enable Authentication

1. In your Firebase project, go to **Authentication** in the left sidebar
2. Click **"Get started"**
3. Go to the **"Sign-in method"** tab
4. Enable the following providers:
   - **Email/Password**: Click and toggle "Enable"
   - **Google**: Click, toggle "Enable", and add your support email

## Step 3: Configure Android App

### Add Android App to Firebase
1. In Firebase Console, click **"Add app"** and select Android
2. Fill in the following:
   - **Android package name**: `com.example.tunisian_marketplace`
   - **App nickname**: `Tunisian Marketplace Android`
   - **Debug signing certificate SHA-1** (optional for now)

### Download Configuration File
1. Download `google-services.json`
2. Place it in `android/app/google-services.json`

### Update Android Configuration
1. Open `android/build.gradle` and add:
```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

2. Open `android/app/build.gradle` and add:
```gradle
// At the top, after other apply plugin lines
apply plugin: 'com.google.gms.google-services'

android {
    compileSdkVersion 34
    minSdkVersion 21  // Firebase requires minimum SDK 21
    targetSdkVersion 34
}
```

## Step 4: Configure iOS App

### Add iOS App to Firebase
1. In Firebase Console, click **"Add app"** and select iOS
2. Fill in the following:
   - **iOS bundle ID**: `com.example.tunisianMarketplace`
   - **App nickname**: `Tunisian Marketplace iOS`
   - **App Store ID** (optional)

### Download Configuration File
1. Download `GoogleService-Info.plist`
2. Place it in `ios/Runner/GoogleService-Info.plist`

### Update iOS Configuration
Open `ios/Runner/Info.plist` and add:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

Replace `YOUR_REVERSED_CLIENT_ID` with the value from your `GoogleService-Info.plist`.

## Step 5: Update Flutter Dependencies

Your `pubspec.yaml` already includes the necessary dependencies:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  google_sign_in: ^6.1.6
```

Run:
```bash
flutter pub get
```

## Step 6: Initialize Firebase in Flutter

The app already includes Firebase initialization in `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  runApp(
    const ProviderScope(
      child: TunisianMarketplaceApp(),
    ),
  );
}
```

## Step 7: Test Authentication

1. Run your app: `flutter run`
2. Try the following features:
   - **Email Registration**: Create a new account
   - **Email Login**: Sign in with created account
   - **Google Sign-In**: Use Google authentication
   - **Sign Out**: Test the logout functionality

## Step 8: Set up Firestore (Optional)

If you plan to store product data in Firestore:

1. Go to **Firestore Database** in Firebase Console
2. Click **"Create database"**
3. Choose **"Start in test mode"** for development
4. Select a region close to your users (e.g., europe-west1 for Tunisia)

### Security Rules for Development
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access on all documents to any user signed in to the application
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Step 9: Production Considerations

### Security Rules
For production, implement proper security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products are read-only for authenticated users
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### Environment Configuration
Consider using different Firebase projects for:
- **Development**: `tunisian-marketplace-dev`
- **Staging**: `tunisian-marketplace-staging` 
- **Production**: `tunisian-marketplace-prod`

## Troubleshooting

### Common Issues

1. **"No Firebase App"**: Ensure `Firebase.initializeApp()` is called before `runApp()`
2. **Google Sign-In not working**: Check SHA-1 certificate is added to Firebase project
3. **iOS build fails**: Ensure `GoogleService-Info.plist` is added to Xcode project
4. **Android build fails**: Check `google-services.json` location and Gradle plugin

### Getting Help

1. Check Firebase Console logs under **"Crashlytics"** or **"Remote Config"**
2. Enable debug mode: `flutter run --debug`
3. Check Flutter logs: `flutter logs`
4. Firebase documentation: [firebase.google.com/docs/flutter](https://firebase.google.com/docs/flutter)

## Testing Checklist

- [ ] Firebase project created
- [ ] Authentication enabled (Email/Password + Google)
- [ ] Android app configured with `google-services.json`
- [ ] iOS app configured with `GoogleService-Info.plist`
- [ ] App builds successfully
- [ ] Email registration works
- [ ] Email login works
- [ ] Google Sign-In works
- [ ] Sign out works
- [ ] User state persists across app restarts

---

**Note**: The Tunisian Marketplace app is fully functional without Firebase for demo purposes using mock data. Firebase integration adds real authentication and the ability to scale to real users and products.
