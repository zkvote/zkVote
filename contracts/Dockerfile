# ---- Builder Stage ----
# Installs dependencies including build tools if native addons are needed.
FROM node:22-alpine AS builder

# Install development tools
# Install essential build and development tools:
# - python3: for running Python scripts and tools
# - g++: for compiling C++ code
# - make: for managing build automation
# - libc6-compat: for compatibility with GNU C library
# The '--no-cache' option ensures that no intermediate cache is used, reducing image size.
RUN apk add --no-cache --virtual .build-deps \
    git \
    python3 \
    g++ \
    make \
    libc6-compat

# Set working directory for builder
WORKDIR /app

# Copy package.json and package-lock.json and install dependencies
COPY package*.json ./
# npm ci will install devDependencies as well, which should include hardhat
RUN npm ci

# Copy the rest of the source code
COPY hardhat.config.js ./
COPY tsconfig.json ./
COPY contracts ./contracts
COPY ignition ./ignition
COPY test ./test

# Optional: If hardhat-shorthand (hh alias) is desired for development *within* this builder stage
# RUN npm install -g hardhat-shorthand

# Clean up build dependencies
RUN apk del .build-deps


# ---- Final Stage ----
# Creates a slim image for running the Hardhat node.
FROM node:22-alpine AS final


# Define build arguments for the application user and group.
# Create a new group with the specified name (default: 'node').
# Create a new user with the specified name (default: 'node'), assign it to the created group,
# and set its default shell to /bin/ash.
ARG APP_USER=node
ARG APP_GROUP=node
RUN addgroup -S ${APP_GROUP} && adduser -S -G ${APP_GROUP} --shell /bin/ash ${APP_USER}

WORKDIR /app

# Copy only necessary artifacts from the builder stage
# Copy node_modules (which includes Hardhat if it's a dependency)
COPY --from=builder --chown=${APP_USER}:${APP_GROUP} /app/node_modules ./node_modules
# Copy application source code
COPY --from=builder --chown=${APP_USER}:${APP_GROUP} /app /app

# Expose hardhat network port
EXPOSE 8545

# Switch to non-root user
USER ${APP_USER}

# Start Hardhat node
CMD ["npx", "hardhat", "node", "--hostname", "0.0.0.0"]
