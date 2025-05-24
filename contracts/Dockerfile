# Build stage
FROM node:22-alpine

# Install development tools
# Install essential build and development tools:
# - git: for version control and cloning repositories
# - python3: for running Python scripts and tools
# - g++: for compiling C++ code
# - make: for managing build automation
# - libc6-compat: for compatibility with GNU C library
# The '--no-cache' option ensures that no intermediate cache is used, reducing image size.
RUN apk add --no-cache \
    git \
    python3 \
    g++ \
    make \
    libc6-compat

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json and install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Install Hardhat and other development tools
RUN npm install -g hardhat-shorthand

# Set environment variables
ENV NODE_ENV=development

# Expose hardhat network port
EXPOSE 8545

# Start Hardhat node
CMD ["npx", "hardhat", "node"]
