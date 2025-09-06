# Tunisian Marketplace - Docker Deployment Guide

This guide helps you containerize and deploy the Tunisian Marketplace Flutter web application on any system, including Windows devices.

## 🚀 Quick Start

### Prerequisites

1. **Docker installed** on the target system
   - **Linux/macOS**: Follow [Docker installation guide](https://docs.docker.com/engine/install/)
   - **Windows**: Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)

### Current Status & Solutions

❌ **Issue Identified**: Firebase Auth web dependencies have compatibility issues with current Flutter version.

✅ **Immediate Solutions Available**:

## Solution 1: Fix Dependencies & Build (Recommended)

### Step 1: Update Dependencies

```bash
# Update pubspec.yaml with compatible versions
flutter pub upgrade --major-versions
```

### Step 2: Build Without Firebase (Temporary)

Create a minimal version for containerization:

```bash
# Comment out Firebase dependencies temporarily in pubspec.yaml
# Build the web version
flutter build web --release --web-renderer html

# Build Docker image
docker build -f Dockerfile.local -t tunisian-marketplace:latest .
```

### Step 3: Run Locally

```bash
docker run -p 8080:80 tunisian-marketplace:latest
```

## Solution 2: Use Build Script (Automated)

```bash
# Make build script executable
chmod +x build-docker.sh

# Run the automated build (will show current issues)
./build-docker.sh
```

## Solution 3: Manual Docker Image Creation

If Flutter build fails, create a minimal Docker image:

### Create a simple index.html for testing:

```bash
mkdir -p build/web
cat > build/web/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tunisian Marketplace</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            text-align: center; 
            margin-top: 100px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
        }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; }
        .logo { font-size: 3em; margin-bottom: 20px; }
        .status { font-size: 1.2em; margin-bottom: 30px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🛒 Tunisian Marketplace</div>
        <div class="status">Application is running in Docker container!</div>
        <p>This is a placeholder while we resolve Flutter web build issues.</p>
        <p>Your containerization setup is working correctly.</p>
    </div>
</body>
</html>
EOF

# Build Docker image with placeholder
docker build -f Dockerfile.local -t tunisian-marketplace:latest .

# Test the container
docker run -p 8080:80 tunisian-marketplace:latest
```

## 🚢 Deployment to Other Machines

### Export Docker Image

```bash
# Create compressed image file
docker save tunisian-marketplace:latest | gzip > tunisian-marketplace.tar.gz

# Check file size
ls -lh tunisian-marketplace.tar.gz
```

### Transfer to Windows Device

1. **Copy the file** to target Windows machine (USB, network, cloud storage)
2. **Install Docker Desktop** on Windows if not already installed
3. **Load the image**:
   ```cmd
   docker load < tunisian-marketplace.tar.gz
   ```

### Run on Windows

```cmd
# Run the container
docker run -p 8080:80 tunisian-marketplace:latest

# Or run in background
docker run -d -p 8080:80 --name tunisian-marketplace tunisian-marketplace:latest
```

### Access the Application

Open browser and navigate to: `http://localhost:8080`

## 🔧 Fixing the Flutter Build Issues

### Issue: Firebase Auth Web Compatibility

The current error is due to Firebase dependencies using deprecated JavaScript interop patterns.

### Solutions:

1. **Update Firebase packages**:
   ```yaml
   # In pubspec.yaml, update to latest versions:
   firebase_core: ^3.1.0
   firebase_auth: ^6.0.2
   ```

2. **Use Flutter 3.24 compatible versions**:
   ```bash
   flutter pub upgrade
   flutter pub get
   ```

3. **Alternative: Temporarily disable Firebase**:
   ```yaml
   # Comment out in pubspec.yaml:
   # firebase_core: ^2.24.2
   # firebase_auth: ^4.15.3
   ```

## 🌐 Production Deployment Options

### Option 1: Direct Docker Deployment

```bash
# Run with custom port
docker run -d -p 3000:80 --name marketplace tunisian-marketplace:latest

# Run with restart policy
docker run -d -p 8080:80 --restart unless-stopped tunisian-marketplace:latest
```

### Option 2: Using Docker Compose

```bash
# Start with docker-compose
docker-compose up -d

# Stop the application
docker-compose down
```

### Option 3: Cloud Deployment

The Docker image can be deployed to:
- AWS ECS/Fargate
- Google Cloud Run
- Azure Container Instances
- DigitalOcean App Platform

## 🛠️ Troubleshooting

### Container Not Starting
```bash
# Check container logs
docker logs tunisian-marketplace

# Check if port is in use
netstat -tulpn | grep 8080

# Try different port
docker run -p 9090:80 tunisian-marketplace:latest
```

### Build Issues
```bash
# Clean Flutter cache
flutter clean
flutter pub get

# Check Flutter doctor
flutter doctor

# Try HTML renderer instead of CanvasKit
flutter build web --web-renderer html
```

## 📋 Next Steps

1. **Fix Firebase dependencies** by updating to compatible versions
2. **Implement proper authentication** once Firebase is working
3. **Add environment variables** for different deployment environments
4. **Set up CI/CD pipeline** for automated builds
5. **Configure SSL/HTTPS** for production deployment

## 🔗 Useful Commands

```bash
# View running containers
docker ps

# Stop container
docker stop tunisian-marketplace

# Remove container
docker rm tunisian-marketplace

# View images
docker images

# Remove image
docker rmi tunisian-marketplace:latest

# Clean up unused Docker resources
docker system prune
```

---

**Need help?** The Docker setup is working correctly. The main issue is Flutter/Firebase compatibility that can be resolved by updating dependencies or temporarily removing Firebase features.
