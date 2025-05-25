# Build image for the contract deployer service
FROM node:22-alpine AS builder

# Install essential build and development tools:
# - git: for version control and cloning repositories
# - python3: for running Python scripts and tools
# - g++: for compiling C++ source code
# - make: for managing build automation
# The '--no-cache' option ensures that no intermediate cache is used, reducing image size.
RUN apk add --no-cache --virtual .build-deps\
    git \
    python3 \
    g++ \
    make

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json and install dependencies
COPY contracts/package*.json ./
RUN npm ci

# Copy deployment scripts and contracts
COPY contracts/scripts ./scripts
COPY contracts/contracts ./contracts
COPY contracts/hardhat.config.js ./

# Add quantum signature verification
COPY contracts/pqc-verify.js ./pqc-verify.js
RUN npm install -g @zkvote/pqc-tools

# Clean up build dependencies to reduce image size
RUN apk del .build-deps

# ---- Final Stage ----
FROM node:22-alpine AS final

# Create a non-root user and group for running the application
ARG APP_USER=node
RUN addgroup -S ${APP_USER} && adduser -S -G ${APP_USER} --shell /bin/ash ${APP_USER}

# Set the working directory
WORKDIR /app

# Copy only necessary artifacts from the builder stage
COPY --from=builder --chown=${APP_USER}:${APP_USER} /app/node_modules ./node_modules
COPY --from=builder --chown=${APP_USER}:${APP_USER} /app/scripts ./scripts
COPY --from=builder --chown=${APP_USER}:${APP_USER} /app/contracts ./contracts
COPY --from=builder --chown=${APP_USER}:${APP_USER} /app/hardhat.config.js ./hardhat.config.js
COPY --from=builder --chown=${APP_USER}:${APP_USER} /app/pqc-verify.js ./pqc-verify.js

# Copies the deploy-contracts.sh script into the container's /usr/local/bin directory
# and sets the execute permission, allowing it to be run as a command inside the container.
COPY scripts/deploy-contracts.sh /usr/local/bin/deploy-contracts.sh
RUN chmod +x /usr/local/bin/deploy-contracts.sh

# Switch to non-root user
USER ${APP_USER}

# Set default command to run the deploy script
ENTRYPOINT [ "/usr/local/bin/deploy-contracts.sh" ]
