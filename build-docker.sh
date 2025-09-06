#!/bin/bash

# Build script for Tunisian Marketplace Flutter Web App
# This script builds the Flutter web app locally and then creates a Docker image

set -e

echo "🏗️  Building Tunisian Marketplace Docker Image"
echo "=============================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter first: https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH"
    echo "Please install Docker first"
    exit 1
fi

echo "📋 Checking Flutter configuration..."
flutter doctor

echo ""
echo "📦 Getting Flutter dependencies..."
flutter pub get

echo ""
echo "🔧 Running code generation..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "🌐 Building Flutter web application..."
flutter build web --release --web-renderer canvaskit

echo ""
echo "🐳 Building Docker image..."
# Use the local Dockerfile that expects pre-built files
docker build -f Dockerfile.local -t tunisian-marketplace:latest .

echo ""
echo "✅ Build completed successfully!"
echo ""
echo "🚀 To run the application:"
echo "   docker run -p 8080:80 tunisian-marketplace:latest"
echo ""
echo "🌍 Then open your browser to: http://localhost:8080"
echo ""
echo "📤 To export the image for sharing:"
echo "   docker save tunisian-marketplace:latest | gzip > tunisian-marketplace.tar.gz"
echo ""
echo "📥 To load the image on another machine:"
echo "   docker load < tunisian-marketplace.tar.gz"
