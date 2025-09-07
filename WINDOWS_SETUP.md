# Windows Setup Guide - Tunisian Marketplace

This guide will help you run the Tunisian Marketplace Flutter app on Windows using Docker, with full Firebase integration.

## 🎯 Prerequisites

### Required Software
1. **Docker Desktop for Windows**
   - Download from: https://www.docker.com/products/docker-desktop/
   - Requires Windows 10/11 Pro, Enterprise, or Education with WSL 2
   - OR Windows 10/11 Home with WSL 2 backend

2. **Git for Windows**
   - Download from: https://git-scm.com/download/win
   - Use Git Bash or PowerShell

3. **Web Browser**
   - Chrome (recommended) or Edge
   - For accessing the web application

## 🚀 Quick Start

### Step 1: Clone the Repository
```bash
# Open PowerShell or Git Bash
git clone https://github.com/your-username/tunisian_marketplace.git
cd tunisian_marketplace
```

### Step 2: Start Docker Desktop
- Launch Docker Desktop from Start menu
- Wait for Docker to fully start (whale icon in system tray should be stable)
- Ensure Docker is running Linux containers (default)

### Step 3: Build and Run
```bash
# Build and start the development environment
docker-compose -f docker-compose.dev.yml up --build

# This will:
# - Download Flutter SDK
# - Install all dependencies
# - Generate required code
# - Start the web development server
```

### Step 4: Access the Application
Open your web browser and go to:
- **Main App**: http://localhost:3000
- **Firebase Emulator UI**: http://localhost:4000 (if using emulator)
- **Flutter DevTools**: http://localhost:9100

## 🔧 Development Workflow

### Starting the Development Environment
```bash
# Start (after first build)
docker-compose -f docker-compose.dev.yml up -d

# View real-time logs
docker-compose -f docker-compose.dev.yml logs -f flutter-dev
```

### Making Code Changes
1. Edit files in your favorite editor (VS Code, Android Studio, etc.)
2. Changes are automatically synced to the Docker container
3. Hot reload works in the browser - just save and refresh!

### Running Commands in Container
```bash
# Enter the Flutter container
docker exec -it tunisian_marketplace_dev bash

# Inside the container, you can run:
flutter pub get                    # Install dependencies
flutter pub run build_runner build # Regenerate code
flutter analyze                    # Check code quality  
flutter test                       # Run tests
flutter doctor                     # Check Flutter setup
```

### Stopping the Environment
```bash
# Stop containers
docker-compose -f docker-compose.dev.yml down

# Stop and remove volumes (clean reset)
docker-compose -f docker-compose.dev.yml down -v
```

## 🔥 Firebase Setup

### Option 1: Use Firebase Emulator (Recommended for Development)
The Docker setup includes Firebase emulator for local development:

1. **Access Emulator UI**: http://localhost:4000
2. **Available Services**:
   - Authentication: http://localhost:9099
   - Firestore: http://localhost:8088
   - Storage: http://localhost:9199

### Option 2: Use Production Firebase
For real Firebase integration:

1. **Create Firebase Project**:
   - Go to https://console.firebase.google.com/
   - Create a new project
   - Enable Authentication, Firestore, and Storage

2. **Configure Web App**:
   - Add a web app to your Firebase project
   - Copy the Firebase configuration
   - Update `lib/firebase_options.dart` with your config

3. **Update Repository Mode**:
   ```dart
   // In lib/shared/services/repository_service.dart
   class RepositoryConfig {
     static const RepositoryMode mode = RepositoryMode.firebase;
     static const bool useFirebaseAuth = true;
   }
   ```

## 📁 Project Structure

```
tunisian_marketplace/
├── lib/
│   ├── features/
│   │   ├── auth/                 # Authentication
│   │   ├── products/             # Product management
│   │   ├── cart/                 # Shopping cart
│   │   └── profile/              # User profiles
│   ├── shared/services/          # Repository services
│   └── core/                     # Shared utilities
├── docker-compose.dev.yml        # Docker development setup
├── Dockerfile.dev               # Flutter development container
└── assets/                      # Mock data and images
```

## 🛠️ Troubleshooting

### Docker Issues

**Problem**: Docker build fails
```bash
# Solution: Clean Docker cache and rebuild
docker system prune -f
docker-compose -f docker-compose.dev.yml build --no-cache
```

**Problem**: Port already in use
```bash
# Check what's using the port
netstat -ano | findstr :3000

# Kill the process (replace PID)
taskkill /PID <process_id> /F
```

### Flutter Issues

**Problem**: Hot reload not working
```bash
# Restart the Flutter service
docker-compose -f docker-compose.dev.yml restart flutter-dev
```

**Problem**: Dependencies issues
```bash
# Clean and reinstall dependencies
docker exec -it tunisian_marketplace_dev bash
flutter clean
flutter pub get
flutter pub run build_runner build
```

### Firebase Issues

**Problem**: Firebase connection failed
- Check internet connection
- Verify Firebase project configuration
- Ensure proper Firebase rules are set
- Check browser console for specific errors

## 💡 Development Tips

### 1. VS Code Integration
- Install "Remote - Containers" extension
- Open project in VS Code
- Use Ctrl+Shift+P → "Remote-Containers: Reopen in Container"

### 2. Hot Reload
- Save Dart files to trigger hot reload
- Use browser refresh for full reload
- Watch the Docker logs to see reload messages

### 3. Debugging
- Use browser DevTools (F12)
- Flutter DevTools at http://localhost:9100
- Check Docker logs for Flutter console output

### 4. Performance
- Keep Docker Desktop running for faster startup
- Use volume mounts for persistent data
- Monitor Docker resource usage in Docker Desktop

## 📱 Testing Features

### Authentication
1. Go to http://localhost:3000
2. Click "Register" to create account
3. Or use "Login" with test credentials
4. Try Google Sign-In (if configured)

### Product Management
1. Navigate to "Add Product" (+ icon)
2. Upload images from your device
3. Fill product details
4. Submit and see real-time updates

### Shopping Cart
1. Browse products on home screen
2. Add items to cart
3. View cart and modify quantities
4. Place test orders

### Firebase Data
- View data in Firebase Emulator UI
- Check Firestore collections
- Monitor Authentication users
- See uploaded images in Storage

## 🚀 Production Deployment

### Web Deployment
```bash
# Build for production
docker exec -it tunisian_marketplace_dev flutter build web --release

# Files will be in build/web/ (accessible from host)
# Deploy to Firebase Hosting, Netlify, or any web server
```

### Mobile Deployment
For mobile apps, you'll need native development setup:
- Android: Android Studio + SDK
- iOS: Xcode (macOS only)

## 📞 Support

If you encounter issues:
1. Check the Docker logs first
2. Verify all prerequisites are installed
3. Try the troubleshooting steps above
4. Open an issue on GitHub with:
   - Your Windows version
   - Docker Desktop version
   - Complete error messages
   - Steps to reproduce

## 🎉 Success Indicators

You'll know everything is working when:
- ✅ Docker containers start without errors
- ✅ Web app loads at http://localhost:3000
- ✅ You can register/login users
- ✅ Products display with images
- ✅ Cart operations work smoothly
- ✅ Firebase data appears in emulator UI
- ✅ Hot reload works on code changes

Happy coding! 🚀
