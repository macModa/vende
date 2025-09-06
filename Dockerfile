# Multi-stage build for Flutter web application
FROM debian:12-slim AS build-env

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    xz-utils \
    zip \
    libgconf-2-4 \
    gdb \
    libstdc++6 \
    libglu1-mesa \
    fonts-droid-fallback \
    lib32stdc++6 \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
ENV FLUTTER_VERSION=3.24.5
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$FLUTTER_HOME/bin:$PATH

RUN wget -O flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz \
    && tar xf flutter.tar.xz -C /opt \
    && rm flutter.tar.xz \
    && cd /opt/flutter \
    && git config --global --add safe.directory /opt/flutter \
    && flutter doctor

# Enable web support
RUN flutter config --enable-web

# Pre-download dependencies
RUN flutter precache --web

# Set the working directory
WORKDIR /app

# Copy pubspec files and get dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy the source code
COPY . .

# Generate code (for riverpod, json serialization, hive)
RUN flutter pub run build_runner build --delete-conflicting-outputs

# Build the web application
RUN flutter build web --release --web-renderer canvaskit

# Production stage - use nginx to serve the web app
FROM nginx:alpine

# Copy the build output to nginx html directory
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
