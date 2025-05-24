FROM node:22-alpine

# Install essential development and utility packages:
# - bash: GNU Bourne Again SHell
# - curl: Command-line tool for transferring data with URLs
# - git: Distributed version control system
# - make: Build automation tool
# - python3: Python programming language interpreter
# - g++: GNU C++ compiler
# - libc6-compat: Compatibility for glibc-based binaries
# - openssh-client: SSH client for secure remote access
# - docker-cli: Docker command-line interface
# - docker-compose: Tool for defining and running multi-container Docker applications
# - jq: Command-line JSON processor
# - yq: Command-line YAML processor
# - vim: Text editor
RUN apk add --no-cache \
    bash \
    curl \
    git \
    make \
    python3 \
    g++ \
    libc6-compat \
    openssh-client \
    docker-cli \
    docker-compose \
    jq \
    yq \
    vim

# Install Rust for cryptographic tools
RUN apk add --no-cache \
    rustup \
    && rustup-init -y \
    && source $HOME/.cargo/env

# Install Go for some tools
RUN apk add --no-cache Go

# Install Circom
RUN npm install -g circom@2.2.1

# Install Solidity compiler
RUN npm install -g solc@0.8.30

# Install post-quantum cryptography tools
RUN apk add --no-cache \
    liboqs-dev \
    && npm install -g @zkvote/pqc-tools

# Create a new group 'node' with GID 1000, add a user 'node' with UID 1000 to this group,
# set the user's shell to /bin/sh, and ensure no password is required (-D).
# Then, create the application directory at /home/node/app and set its ownership to the 'node' user and group.
RUN addgroup -g 1000 node && \
    adduser -u 1000 -G node -s /bin/sh -D node && \
    mkdir -p /home/node/app && \
    chown -R node:node /home/node

# Set the working directory
WORKDIR /workspace

# Use non-root user
USER node

# Pre-install common dependencies
COPY --chown=node:node package*.json ./
RUN npm ci

# Add setup scripts
COPY --chown=node:node scripts/init-dev-env.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-dev-env.sh

CMD ["bash"]
