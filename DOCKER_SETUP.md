# Docker Setup for Tunisian Marketplace

This guide explains how to set up and run the Tunisian Marketplace project using Docker on both Linux and Windows systems.

## Prerequisites

- [Docker](https://www.docker.com/get-started/) installed on your system
- For Linux: Docker and Docker Compose
- For Windows: Docker Desktop

## Project Structure

The project includes the following Docker-related files:

- `Dockerfile` - Main Docker configuration for building the app from source
- `Dockerfile.local` - Docker configuration for building from pre-built web files
- `docker-compose.yml` - Docker Compose configuration
- `build-docker.sh` - Linux build script
- `deploy-windows.bat` - Windows deployment script
- `docker/nginx.conf` - Nginx configuration for serving the web app

## Setup on Linux

### Method 1: Build and Run with Docker Compose

This method builds the application from source and runs it using Docker Compose:

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd tunisian_marketplace
   ```

2. Build and run with Docker Compose:
   ```bash
   docker compose up --build
   ```

3. Access the application at [http://localhost:8080](http://localhost:8080)

### Method 2: Using the Build Script

This method builds the Flutter web app locally and then creates a Docker image:

1. Make the build script executable:
   ```bash
   chmod +x build-docker.sh
   ```

2. Run the build script:
   ```bash
   ./build-docker.sh
   ```

3. Once the build completes, run the container:
   ```bash
   docker run -p 8080:80 tunisian-marketplace:latest
   ```

4. Access the application at [http://localhost:8080](http://localhost:8080)

## Setup on Windows

### Method 1: Using Docker Compose

1. Open PowerShell or Command Prompt as Administrator
2. Navigate to the project directory:
   ```
   cd path\to\tunisian_marketplace
   ```

3. Build and run with Docker Compose:
   ```
   docker compose up --build
   ```

4. Access the application at [http://localhost:8080](http://localhost:8080)

### Method 2: Using Pre-built Image

If you have a pre-built Docker image file (`tunisian-marketplace.tar.gz`):

1. Place the image file in the project directory
2. Run the deployment script:
   ```
   deploy-windows.bat
   ```
3. The script will load the image, start the container, and open the application in your browser

### Method 3: Manual Image Building

To manually build the image on Windows:

1. Open PowerShell or Command Prompt as Administrator
2. Navigate to the project directory:
   ```
   cd path\to\tunisian_marketplace
   ```

3. Build the Docker image:
   ```
   docker build -t tunisian-marketplace:latest .
   ```

4. Run the container:
   ```
   docker run -d -p 8080:80 --name tunisian-marketplace tunisian-marketplace:latest
   ```

5. Access the application at [http://localhost:8080](http://localhost:8080)

## Container Management

### Common Docker Commands

#### View running containers:
```bash
docker ps
```

#### View container logs:
```bash
docker logs tunisian-marketplace
```

#### Stop the container:
```bash
docker stop tunisian-marketplace
```

#### Start an existing container:
```bash
docker start tunisian-marketplace
```

#### Remove a container:
```bash
docker rm tunisian-marketplace
```

#### Remove an image:
```bash
docker rmi tunisian-marketplace:latest
```

## Sharing the Docker Image

### Export the image (on any system):
```bash
docker save tunisian-marketplace:latest | gzip > tunisian-marketplace.tar.gz
```

### Import the image (on any system):
```bash
docker load < tunisian-marketplace.tar.gz
```

## Troubleshooting

### Container won't start
- Check if port 8080 is already in use:
  ```bash
  # Linux
  sudo lsof -i :8080
  
  # Windows (PowerShell)
  netstat -ano | findstr :8080
  ```
- Try using a different port:
  ```bash
  docker run -p 8081:80 tunisian-marketplace:latest
  ```

### Build failures
- Check Flutter version compatibility
- Ensure all dependencies are available
- Check system resources (memory/storage)

### Connection issues
- Verify Docker is running
- Check firewall settings
- Ensure the correct URL is being used

## Advanced Configuration

### Custom Ports
To use a different port, modify the port mapping in the run command:
```bash
docker run -p <your-port>:80 tunisian-marketplace:latest
```

Or update the `docker-compose.yml` file:
```yaml
ports:
  - "<your-port>:80"
```

### Environment Variables
Additional environment variables can be specified in `docker-compose.yml` or the run command:

```bash
docker run -p 8080:80 -e MY_VARIABLE=value tunisian-marketplace:latest
```

## Performance Optimization

- The Docker image uses Nginx with optimized settings for static content
- Assets are cached with appropriate headers
- Gzip compression is enabled for text-based resources

---

For more information about the application, please refer to the main [README.md](./README.md) file.
