# Build image for the contract deployer service
FROM node:22-alpine

# Install essential build and development tools:
# - git: for version control and cloning repositories
# - python3: for running Python scripts and tools
# - g++: for compiling C++ source code
# - make: for managing build automation
# The '--no-cache' option ensures that no intermediate cache is used, reducing image size.
RUN apk add --no-cache \
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
COPY contracts ./contracts
COPY contracts/hardhat.config.js ./

# Add quantum signature verification
COPY contracts/pqc-verify.js ./
RUN npm install -g @zkvote/pqc-tools


# Copies the deploy-contracts.sh script into the container's /usr/local/bin directory
# and sets the execute permission, allowing it to be run as a command inside the container.
COPY scripts/deploy-contracts.sh /usr/local/bin/deploy-contracts.sh
RUN chmod +x /usr/local/bin/deploy-contracts.sh

# Set default command to run the deploy script
ENTRYPOINT [ "/usr/local/bin/deploy-contracts.sh" ]
