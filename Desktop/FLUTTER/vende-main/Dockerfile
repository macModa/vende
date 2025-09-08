# ==========================
# Stage 1: Build Flutter web app
# ==========================
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
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK (latest stable)
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$FLUTTER_HOME/bin:$PATH

RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME \
    && flutter --version \
    && flutter doctor

# Enable web support
RUN flutter config --enable-web

# Pre-download web dependencies
RUN flutter precache --web

# Set working directory
WORKDIR /app

# Copy pubspec files and install dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy project files
COPY . .

# Generate missing files for JSON/Hive/Riverpod
RUN flutter pub run build_runner build --delete-conflicting-outputs

# Build Flutter web (release mode)
RUN flutter build web --release

# ==========================
# Stage 2: Serve via nginx
# ==========================
FROM nginx:alpine

# Copy built web app from previous stage
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy custom nginx config if you have one
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
