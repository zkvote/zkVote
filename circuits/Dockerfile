# Builder stage
FROM node:22-alpine AS builder

# Install development tools
# Install essential build and development tools:
# - git: for version control and cloning repositories
# - python3: for running Python scripts and tools
# - g++: for compiling C++ code
# - make: for managing build automation
# - libc6-compat: for compatibility with GNU C library binaries
# The '--no-cache' option ensures that no intermediate cache is used, reducing image size.
RUN apk add --no-cache --virtual .build-deps\
    git \
    python3 \
    g++ \
    make \
    libc6-compat \
    rustup

# Install Rust toolchain using rustup for circuit-related tools.
# $HOME is /root when RUN is executed as root in the Dockerfile.
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup-init -y --profile minimal --default-toolchain stable --no-modify-path

# Install Circom globally
RUN npm install -g circom@2.2.1

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json and install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Clean up build-only OS dependencies
RUN apk del .build-deps

# Final stage
FROM node:22-alpine AS final

# Install Python 3 and libc6-compat (GNU C library compatibility) packages without caching index files,
# ensuring a minimal Docker image size and providing necessary runtime dependencies.
RUN apk add --no-cache \
    python3 \
    libc6-compat

# Define a build argument APP_USER with default value 'node'
# Create a new group with the name specified by APP_USER
# Create a new user with the name specified by APP_USER, assign it to the group,
# and set its default shell to /bin/bash
ARG APP_USER=node
RUN addgroup -S ${APP_USER} && adduser -S -G ${APP_USER} --shell /bin/bash ${APP_USER}

# Set working directory
WORKDIR /app

# Copy circom binary and its global node_modules from the builder stage to the final image,
# setting ownership to the application user.
# Also copy the Rust cargo directory, application node_modules, and the application source code,
# all with correct ownership for the application user.
COPY --from=builder --chown=${APP_USER}:${APP_USER} /usr/local/bin/circom /usr/local/bin/circom
COPY --from=builder --chown=${APP_USER}:${APP_USER} /usr/local/lib/node_modules/circom /usr/local/lib/node_modules/circom
COPY --from=builder --chown=${APP_USER}:${APP_USER} /root/.cargo /home/${APP_USER}/.cargo
COPY --from=builder --chown=${APP_USER}:${APP_USER} /app/node_modules ./node_modules
COPY --from=builder --chown=${APP_USER}:${APP_USER} /app .

# Adds the Rust Cargo binary directory to the PATH environment variable for the specified application user,
# ensuring that Cargo-installed binaries are accessible in subsequent Dockerfile instructions and at runtime.
ENV PATH="/home/${APP_USER}/.cargo/bin:${PATH}"

# Switch to non-root user
USER ${APP_USER}

# Default command
CMD ["npm", "run", "dev"]
