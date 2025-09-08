@echo off
echo ======================================
echo Tunisian Marketplace - Windows Setup
echo ======================================
echo.

REM Check if Docker is installed
docker version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not installed or not running
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

echo ✅ Docker is available
echo.

REM Check if image file exists
if not exist "tunisian-marketplace.tar.gz" (
    echo ERROR: tunisian-marketplace.tar.gz not found
    echo Please ensure the Docker image file is in the same directory as this script
    pause
    exit /b 1
)

echo ✅ Docker image file found
echo.

echo 📦 Loading Docker image...
docker load < tunisian-marketplace.tar.gz
if errorlevel 1 (
    echo ERROR: Failed to load Docker image
    pause
    exit /b 1
)

echo ✅ Image loaded successfully
echo.

REM Stop and remove existing container if it exists
echo 🛑 Stopping existing container (if any)...
docker stop tunisian-marketplace 2>nul
docker rm tunisian-marketplace 2>nul

echo 🚀 Starting Tunisian Marketplace container...
docker run -d -p 8080:80 --name tunisian-marketplace tunisian-marketplace:latest
if errorlevel 1 (
    echo ERROR: Failed to start container
    pause
    exit /b 1
)

echo.
echo ✅ SUCCESS! Tunisian Marketplace is now running
echo.
echo 🌍 Open your browser and go to: http://localhost:8080
echo.
echo 📋 Container Management Commands:
echo    • View status:    docker ps
echo    • View logs:      docker logs tunisian-marketplace
echo    • Stop app:       docker stop tunisian-marketplace
echo    • Start app:      docker start tunisian-marketplace
echo    • Remove app:     docker rm tunisian-marketplace
echo.
echo Press any key to open the application in your browser...
pause >nul

REM Try to open in default browser
start http://localhost:8080

echo.
echo 🎉 Setup complete! The application should open in your browser.
pause
