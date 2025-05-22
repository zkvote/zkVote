FROM node:22-alpine

# Install required development tools
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

# Create non-root user
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
