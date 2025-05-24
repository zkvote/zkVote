# Build stage
FROM node:22-alpine

# Install development tools
# Install essential build and development tools:
# - git: for version control and cloning repositories
# - python3: for running Python scripts and tools
# - g++: for compiling C++ code
# - make: for managing build automation
# - libc6-compat: for compatibility with GNU C library binaries
# The '--no-cache' option ensures that no intermediate cache is used, reducing image size.
RUN apk add --no-cache \
    git \
    python3 \
    g++ \
    make \
    libc6-compat

# Install Rust toolchain using rustup for circuit-related tools.
# - Adds rustup via apk (Alpine package manager).
# - Initializes rustup with default settings.
# - Sources the cargo environment to update PATH for Rust tools.
RUN apk add --no-cache \
    rustup \
    && rustup-init -y \
    && source $HOME/.cargo/env

# Install Circom
RUN npm install -g circom@2.2.1

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json and install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Default command
CMD ["npm", "run", "dev"]
