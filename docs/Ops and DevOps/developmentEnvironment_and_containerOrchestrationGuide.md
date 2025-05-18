# zkVote: Development Environment and Container Orchestration Guide

**Document ID:** ZKV-DEVENV-2025-001  
**Version:** 1.0  
**Date:** 2025-05-17  
**Author:** Cass402  
**Classification:** Internal

## Document Control

| Version | Date       | Author  | Description of Changes |
| ------- | ---------- | ------- | ---------------------- |
| 1.0     | 2025-05-17 | Cass402 | Initial version        |

## Table of Contents

1. [Introduction](#1-introduction)
2. [Development Environment Setup](#2-development-environment-setup)
3. [VSCode Configuration](#3-vscode-configuration)
4. [Devcontainer Setup](#4-devcontainer-setup)
5. [Dockerization Strategy](#5-dockerization-strategy)
6. [Docker Compose Configuration](#6-docker-compose-configuration)
7. [Kubernetes Deployment](#7-kubernetes-deployment)
8. [Environment Configuration Management](#8-environment-configuration-management)
9. [Blockchain-Specific Container Configurations](#9-blockchain-specific-container-configurations)
10. [Quantum-Safe Containerization](#10-quantum-safe-containerization)
11. [Cross-Chain Testing Environment](#11-cross-chain-testing-environment)
12. [Monitoring and Logging](#12-monitoring-and-logging)
13. [Security Considerations](#13-security-considerations)
14. [Disaster Recovery and Backup](#14-disaster-recovery-and-backup)
15. [References and Additional Resources](#15-references-and-additional-resources)

## 1. Introduction

### 1.1 Purpose

This guide provides comprehensive instructions for setting up consistent development environments, containerizing the zkVote application components, and deploying them using Kubernetes. It ensures that all team members work in identical environments and that deployments are consistent across all environments from development to production.

### 1.2 Scope

This document covers:

- Local development environment configuration
- VSCode setup and recommended extensions
- Development containers configuration
- Docker and Docker Compose setup for local development
- Kubernetes deployment configurations
- Environment-specific configurations
- Blockchain-specific container considerations
- Post-quantum cryptography integration
- Cross-chain testing environments

### 1.3 Audience

This guide is intended for:

- Developers
- DevOps engineers
- QA engineers
- System administrators
- Security engineers

### 1.4 Related Documents

- zkVote Development Handbook (ZKV-DEV-2025-001)
- zkVote CI/CD Pipeline Guide (ZKV-CICD-2025-002)
- zkVote Security Protocols (ZKV-SEC-2025-002)
- zkVote Deployment Strategy (ZKV-DEPL-2025-001)

## 2. Development Environment Setup

### 2.1 Prerequisites

Ensure the following software is installed on your development machine:

| Software       | Version        | Purpose                                   |
| -------------- | -------------- | ----------------------------------------- |
| Docker         | 25.0+          | Container runtime                         |
| Docker Compose | 2.20+          | Multi-container orchestration             |
| VSCode         | 1.84+          | Development IDE                           |
| Git            | 2.40+          | Version control                           |
| Node.js        | 18.17+ / 20.9+ | JavaScript runtime                        |
| Kubectl        | 1.28+          | Kubernetes CLI                            |
| Helm           | 3.13+          | Kubernetes package manager                |
| Rust           | 1.76+          | Required for some cryptographic libraries |
| Go             | 1.21+          | Required for some blockchain tools        |

### 2.2 Repository Structure

The zkVote repository is organized as follows:

```
zkVote/
├── .vscode/                  # VSCode configuration
├── .devcontainer/            # Development container configuration
├── contracts/                # Smart contracts
│   ├── Dockerfile            # Contract development environment
│   └── docker-compose.yml    # Local blockchain services
├── circuits/                 # Zero-knowledge circuits
│   └── Dockerfile            # Circuit compilation environment
├── frontend/                 # Web frontend
│   └── Dockerfile            # Frontend container
├── backend/                  # API and services
│   └── Dockerfile            # Backend container
├── bridge/                   # Cross-chain bridge
│   └── Dockerfile            # Bridge container
├── docker/                   # Shared Docker configurations
│   ├── base/                 # Base images
│   └── dev/                  # Development containers
├── docker-compose.yml        # Main Docker Compose file
├── docker-compose.dev.yml    # Development overrides
├── docker-compose.test.yml   # Testing configuration
└── k8s/                      # Kubernetes configuration
    ├── base/                 # Common K8s resources
    ├── development/          # Development environment
    ├── staging/              # Staging environment
    └── production/           # Production environment
```

### 2.3 Initial Setup

To set up the development environment:

1. Clone the repository:

   ```bash
   git clone https://github.com/zkvote/zkvote.git
   cd zkvote
   ```

2. Install VSCode extensions (see Section 3.1)

3. Build and start the development environment:

   ```bash
   # Option 1: Using Docker Compose
   docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

   # Option 2: Using VSCode Devcontainers
   # Open the project in VSCode and click "Reopen in Container" when prompted
   ```

4. Initialize the development environment:
   ```bash
   # Inside the container or locally if not using containers
   ./scripts/init-dev-env.sh
   ```

## 3. VSCode Configuration

### 3.1 Recommended Extensions

Create `.vscode/extensions.json`:

```json
{
  "recommendations": [
    "ms-azuretools.vscode-docker",
    "ms-kubernetes-tools.vscode-kubernetes-tools",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "JuanBlanco.solidity",
    "tintinweb.solidity-visual-auditor",
    "ms-vscode-remote.remote-containers",
    "redhat.vscode-yaml",
    "GitHub.copilot",
    "GitHub.copilot-chat",
    "ms-vscode.vscode-typescript-next",
    "rust-lang.rust-analyzer",
    "circom.circom",
    "tamasfe.even-better-toml",
    "ms-vscode.makefile-tools",
    "eamodio.gitlens",
    "yzhang.markdown-all-in-one",
    "bierner.markdown-mermaid",
    "streetsidesoftware.code-spell-checker",
    "ms-vsliveshare.vsliveshare"
  ]
}
```

### 3.2 Workspace Settings

Create `.vscode/settings.json`:

```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "editor.rulers": [100],
  "editor.tabSize": 2,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true,
  "typescript.tsdk": "node_modules/typescript/lib",
  "solidity.compileUsingRemoteVersion": "0.8.19",
  "solidity.formatter": "prettier",
  "solidity.linter": "solhint",
  "solidity.enabledAsYouTypeCompilationErrorCheck": true,
  "circom.binaryPath": "${workspaceFolder}/node_modules/.bin/circom",
  "circom.includePaths": ["${workspaceFolder}/circuits/include"],
  "[solidity]": {
    "editor.defaultFormatter": "JuanBlanco.solidity"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[yaml]": {
    "editor.defaultFormatter": "redhat.vscode-yaml"
  },
  "[markdown]": {
    "editor.defaultFormatter": "yzhang.markdown-all-in-one"
  },
  "remote.containers.defaultExtensions": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "JuanBlanco.solidity",
    "GitHub.copilot"
  ],
  "terminal.integrated.defaultProfile.linux": "bash",
  "git.autofetch": true,
  "cSpell.words": [
    "circom",
    "devcontainer",
    "hardhat",
    "zkproof",
    "zksnark",
    "zkvote",
    "solhint",
    "kubernetes",
    "kubectl",
    "kubeconfig",
    "etherscan",
    "alchemy",
    "infura",
    "ganache",
    "sepolia",
    "typechain",
    "postquantum",
    "dilithium",
    "kyber"
  ]
}
```

### 3.3 Launch Configurations

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Backend",
      "skipFiles": ["<node_internals>/**"],
      "program": "${workspaceFolder}/backend/dist/index.js",
      "preLaunchTask": "build-backend",
      "outFiles": ["${workspaceFolder}/backend/dist/**/*.js"],
      "envFile": "${workspaceFolder}/backend/.env.local",
      "internalConsoleOptions": "openOnSessionStart"
    },
    {
      "type": "chrome",
      "request": "launch",
      "name": "Debug Frontend",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}/frontend/src",
      "sourceMapPathOverrides": {
        "webpack:///src/*": "${webRoot}/*"
      }
    },
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Smart Contract Tests",
      "skipFiles": ["<node_internals>/**"],
      "program": "${workspaceFolder}/node_modules/hardhat/internal/cli/cli.js",
      "args": ["test", "${file}"],
      "cwd": "${workspaceFolder}/contracts"
    },
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Circuit Tests",
      "skipFiles": ["<node_internals>/**"],
      "program": "${workspaceFolder}/circuits/node_modules/mocha/bin/mocha.js",
      "args": ["${file}"],
      "cwd": "${workspaceFolder}/circuits"
    },
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Bridge",
      "skipFiles": ["<node_internals>/**"],
      "program": "${workspaceFolder}/bridge/dist/index.js",
      "preLaunchTask": "build-bridge",
      "outFiles": ["${workspaceFolder}/bridge/dist/**/*.js"],
      "envFile": "${workspaceFolder}/bridge/.env.local"
    }
  ]
}
```

### 3.4 Task Configurations

Create `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "build-backend",
      "type": "shell",
      "command": "cd ${workspaceFolder}/backend && npm run build",
      "group": {
        "kind": "build",
        "isDefault": true
      }
    },
    {
      "label": "build-frontend",
      "type": "shell",
      "command": "cd ${workspaceFolder}/frontend && npm run build"
    },
    {
      "label": "build-bridge",
      "type": "shell",
      "command": "cd ${workspaceFolder}/bridge && npm run build"
    },
    {
      "label": "compile-contracts",
      "type": "shell",
      "command": "cd ${workspaceFolder}/contracts && npx hardhat compile"
    },
    {
      "label": "compile-circuits",
      "type": "shell",
      "command": "cd ${workspaceFolder}/circuits && npm run build"
    },
    {
      "label": "start-dev-environment",
      "type": "shell",
      "command": "docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d",
      "problemMatcher": []
    },
    {
      "label": "stop-dev-environment",
      "type": "shell",
      "command": "docker-compose -f docker-compose.yml -f docker-compose.dev.yml down",
      "problemMatcher": []
    },
    {
      "label": "run-tests",
      "type": "shell",
      "command": "docker-compose -f docker-compose.yml -f docker-compose.test.yml up --abort-on-container-exit",
      "group": {
        "kind": "test",
        "isDefault": true
      }
    },
    {
      "label": "generate-k8s-manifests",
      "type": "shell",
      "command": "cd ${workspaceFolder}/k8s && ./scripts/generate-manifests.sh",
      "problemMatcher": []
    },
    {
      "label": "apply-k8s-dev",
      "type": "shell",
      "command": "kubectl apply -k ${workspaceFolder}/k8s/development",
      "problemMatcher": []
    }
  ]
}
```

## 4. Devcontainer Setup

### 4.1 Devcontainer Configuration

Create `.devcontainer/devcontainer.json`:

```json
{
  "name": "zkVote Development Environment",
  "dockerComposeFile": [
    "../docker-compose.yml",
    "../docker-compose.dev.yml",
    "docker-compose.yml"
  ],
  "service": "dev",
  "workspaceFolder": "/workspace",
  "shutdownAction": "stopCompose",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-azuretools.vscode-docker",
        "ms-kubernetes-tools.vscode-kubernetes-tools",
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode",
        "JuanBlanco.solidity",
        "tintinweb.solidity-visual-auditor",
        "redhat.vscode-yaml",
        "GitHub.copilot",
        "ms-vscode.vscode-typescript-next",
        "rust-lang.rust-analyzer",
        "circom.circom",
        "tamasfe.even-better-toml"
      ],
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash",
        "terminal.integrated.profiles.linux": {
          "bash": {
            "path": "/bin/bash"
          }
        }
      }
    }
  },
  "remoteUser": "node",
  "remoteEnv": {
    "LOCAL_WORKSPACE_FOLDER": "${localWorkspaceFolder}"
  },
  "postCreateCommand": "scripts/init-dev-env.sh",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "18"
    },
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/devcontainers/features/kubectl-helm-minikube:1": {},
    "ghcr.io/devcontainers/features/rust:1": {},
    "ghcr.io/devcontainers/features/go:1": {}
  }
}
```

### 4.2 Devcontainer Docker Compose Extension

Create `.devcontainer/docker-compose.yml`:

```yaml
version: "3.8"

services:
  dev:
    build:
      context: ..
      dockerfile: docker/dev/Dockerfile
    volumes:
      - ..:/workspace:cached
      - node_modules:/workspace/node_modules
      - frontend_node_modules:/workspace/frontend/node_modules
      - backend_node_modules:/workspace/backend/node_modules
      - contracts_node_modules:/workspace/contracts/node_modules
      - circuits_node_modules:/workspace/circuits/node_modules
      - bridge_node_modules:/workspace/bridge/node_modules
      - ~/.ssh:/home/node/.ssh:ro
      - ~/.gitconfig:/home/node/.gitconfig:ro
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - NODE_ENV=development
      - PQC_ENABLED=true
      - INFURA_API_KEY
      - ALCHEMY_API_KEY
      - ETHERSCAN_API_KEY
    command: sleep infinity
    user: node

volumes:
  node_modules:
  frontend_node_modules:
  backend_node_modules:
  contracts_node_modules:
  circuits_node_modules:
  bridge_node_modules:
```

### 4.3 Development Dockerfile

Create `docker/dev/Dockerfile`:

```dockerfile
FROM node:20-alpine

# Install development tools
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

# Install Go for some blockchain tools
RUN apk add --no-cache go

# Install Circom
RUN npm install -g circom@2.1.4

# Install Solidity compiler
RUN npm install -g solc@0.8.19

# Install post-quantum cryptography tools
RUN apk add --no-cache \
    liboqs-dev \
    && npm install -g @zkvote/pqc-tools

# Create non-root user
RUN addgroup -g 1000 node && \
    adduser -u 1000 -G node -s /bin/sh -D node && \
    mkdir -p /home/node/app && \
    chown -R node:node /home/node

# Set working directory
WORKDIR /workspace

# Use non-root user by default
USER node

# Pre-install common dependencies
COPY --chown=node:node package*.json ./
RUN npm ci

# Add setup scripts
COPY --chown=node:node scripts/init-dev-env.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-dev-env.sh

CMD ["bash"]
```

### 4.4 Development Environment Initialization Script

Create `scripts/init-dev-env.sh`:

```bash
#!/bin/bash
set -e

# Initialize all project components
echo "🚀 Initializing zkVote development environment..."

# Install root dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing root dependencies..."
    npm ci
fi

# Initialize frontend
if [ -d "frontend" ]; then
    echo "🖥️ Setting up frontend..."
    cd frontend
    [ ! -d "node_modules" ] && npm ci
    cd ..
fi

# Initialize backend
if [ -d "backend" ]; then
    echo "🔙 Setting up backend..."
    cd backend
    [ ! -d "node_modules" ] && npm ci
    [ ! -f ".env.local" ] && cp .env.example .env.local
    cd ..
fi

# Initialize contracts
if [ -d "contracts" ]; then
    echo "📝 Setting up smart contracts..."
    cd contracts
    [ ! -d "node_modules" ] && npm ci
    [ ! -f ".env.local" ] && cp .env.example .env.local
    [ ! -d "artifacts" ] && npx hardhat compile
    cd ..
fi

# Initialize circuits
if [ -d "circuits" ]; then
    echo "🔄 Setting up ZK circuits..."
    cd circuits
    [ ! -d "node_modules" ] && npm ci
    [ ! -d "build" ] && mkdir -p build
    cd ..
fi

# Initialize bridge
if [ -d "bridge" ]; then
    echo "🌉 Setting up cross-chain bridge..."
    cd bridge
    [ ! -d "node_modules" ] && npm ci
    [ ! -f ".env.local" ] && cp .env.example .env.local
    cd ..
fi

# Setup PQC environment if enabled
if [ "$PQC_ENABLED" = "true" ]; then
    echo "🔒 Setting up post-quantum cryptography environment..."
    mkdir -p ~/.zkvote/pqc
    pqc-tools setup
fi

echo "✅ Development environment initialization complete!"
```

## 5. Dockerization Strategy

### 5.1 Component-Specific Docker Images

#### 5.1.1 Frontend Dockerfile

Create `frontend/Dockerfile`:

```dockerfile
# Build stage
FROM node:20-alpine AS build

WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Post-quantum signature verification (optional in development)
ARG PQC_SIGNATURE_VERIFY=false
RUN if [ "$PQC_SIGNATURE_VERIFY" = "true" ]; then \
    npm install -g @zkvote/pqc-tools && \
    pqc-tools verify --algorithm dilithium5 --input ./dist --key-id $PQC_KEY_ID; \
    fi

# Production stage
FROM nginx:1.25-alpine AS production

# Copy the build output
COPY --from=build /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Add security headers
RUN echo "add_header X-Content-Type-Options nosniff;" >> /etc/nginx/conf.d/security-headers.conf && \
    echo "add_header X-Frame-Options DENY;" >> /etc/nginx/conf.d/security-headers.conf && \
    echo "add_header X-XSS-Protection \"1; mode=block\";" >> /etc/nginx/conf.d/security-headers.conf && \
    echo "add_header Content-Security-Policy \"default-src 'self'; script-src 'self'; object-src 'none'\";" >> /etc/nginx/conf.d/security-headers.conf && \
    echo "include /etc/nginx/conf.d/security-headers.conf;" >> /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Run nginx
CMD ["nginx", "-g", "daemon off;"]
```

#### 5.1.2 Backend Dockerfile

Create `backend/Dockerfile`:

```dockerfile
# Build stage
FROM node:20-alpine AS build

WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Test stage
FROM build AS test

# Run tests
RUN npm run test

# Production stage
FROM node:20-alpine AS production

# Set NODE_ENV
ENV NODE_ENV=production

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -s /bin/sh -D appuser

WORKDIR /app

# Copy package.json and install production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Install post-quantum crypto libraries
RUN apk add --no-cache liboqs-dev

# Copy built application from build stage
COPY --from=build /app/dist ./dist
COPY --from=build /app/config ./config

# Post-quantum signature verification
ARG PQC_SIGNATURE_VERIFY=false
RUN if [ "$PQC_SIGNATURE_VERIFY" = "true" ]; then \
    npm install -g @zkvote/pqc-tools && \
    pqc-tools verify --algorithm dilithium5 --input ./dist --key-id $PQC_KEY_ID; \
    fi

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 3000

# Run the application
CMD ["node", "dist/index.js"]
```

#### 5.1.3 Smart Contract Development Dockerfile

Create `contracts/Dockerfile`:

```dockerfile
FROM node:20-alpine

# Install development tools
RUN apk add --no-cache git python3 g++ make libc6-compat

WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Install Hardhat and other dev tools
RUN npm install -g hardhat-shorthand

# Set environment variables
ENV NODE_ENV=development

# Expose Hardhat Network port
EXPOSE 8545

# Default command
CMD ["npx", "hardhat", "node"]
```

#### 5.1.4 Circuit Development Dockerfile

Create `circuits/Dockerfile`:

```dockerfile
FROM node:20-alpine

# Install development tools
RUN apk add --no-cache git python3 g++ make libc6-compat

# Install Rust for some circuit tools
RUN apk add --no-cache \
    rustup \
    && rustup-init -y \
    && source $HOME/.cargo/env

# Install Circom
RUN npm install -g circom@2.1.4

WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Default command
CMD ["npm", "run", "dev"]
```

#### 5.1.5 Bridge Dockerfile

Create `bridge/Dockerfile`:

```dockerfile
# Build stage
FROM node:20-alpine AS build

WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:20-alpine AS production

# Set NODE_ENV
ENV NODE_ENV=production

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -s /bin/sh -D appuser

WORKDIR /app

# Copy package.json and install production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Install post-quantum crypto libraries
RUN apk add --no-cache liboqs-dev

# Copy built application from build stage
COPY --from=build /app/dist ./dist
COPY --from=build /app/config ./config

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 3001

# Run the application
CMD ["node", "dist/index.js"]
```

### 5.2 Multi-Stage Build Strategy

For all services, we use a multi-stage build approach to:

1. **Build Stage**: Compile the application code
2. **Test Stage** (optional): Run tests on the built code
3. **Production Stage**: Create a minimal image with only production dependencies

Benefits:

- Smaller production images
- Separation of build tools from runtime environment
- Enhanced security through reduced attack surface
- Optimized layer caching

### 5.3 Base Images

Create shared base images for consistency:

Create `docker/base/node-base.Dockerfile`:

```dockerfile
FROM node:20-alpine

# Add common dependencies for all Node.js applications
RUN apk add --no-cache \
    curl \
    jq \
    bash

# Add security hardening
RUN addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -s /bin/sh -D appuser && \
    mkdir -p /app && \
    chown -R appuser:appuser /app

# Add post-quantum cryptography support
RUN apk add --no-cache liboqs-dev

# Set working directory
WORKDIR /app

# Use non-root user
USER appuser

# Health check for Node.js applications
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT:-3000}/health || exit 1
```

Create `docker/base/quantum-safe.Dockerfile`:

```dockerfile
FROM node:20-alpine

# Add post-quantum cryptography libraries
RUN apk add --no-cache \
    liboqs-dev \
    libpqcrypto

# Install PQC tools
RUN npm install -g @zkvote/pqc-tools

# Install OpenSSL with quantum-safe algorithms
RUN apk add --no-cache \
    openssl \
    openssl-dev

# Configure Node.js to use quantum-safe TLS
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/quantum-ca.crt
ENV NODE_OPTIONS="--tls-cipher-list=TLS_KEMTLS_KYBER768_WITH_DILITHIUM3"

# Add security hardening
RUN addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -s /bin/sh -D appuser && \
    mkdir -p /app && \
    chown -R appuser:appuser /app

# Set working directory
WORKDIR /app

# Use non-root user
USER appuser
```

## 6. Docker Compose Configuration

### 6.1 Main Docker Compose

Create `docker-compose.yml`:

```yaml
version: "3.8"

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      args:
        - PQC_SIGNATURE_VERIFY=false
    ports:
      - "3000:80"
    depends_on:
      - backend
    networks:
      - frontend-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
      args:
        - PQC_SIGNATURE_VERIFY=false
    ports:
      - "3001:3000"
    depends_on:
      - postgres
      - redis
      - ganache
    networks:
      - frontend-network
      - backend-network
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgres://postgres:postgres@postgres:5432/zkvote_dev
      - REDIS_URL=redis://redis:6379
      - BLOCKCHAIN_RPC=http://ganache:8545
      - JWT_SECRET=dev_jwt_secret
      - PORT=3000
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s

  bridge:
    build:
      context: ./bridge
      dockerfile: Dockerfile
    ports:
      - "3002:3001"
    depends_on:
      - postgres
      - redis
      - ganache
    networks:
      - backend-network
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgres://postgres:postgres@postgres:5432/zkvote_bridge_dev
      - REDIS_URL=redis://redis:6379
      - ETHEREUM_RPC=http://ganache:8545
      - POLYGON_RPC=http://polygon-node:8545
      - ARBITRUM_RPC=http://arbitrum-node:8545
      - PORT=3001
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s

  postgres:
    image: postgres:15-alpine
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    networks:
      - backend-network
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=zkvote_dev
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - backend-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  ganache:
    build:
      context: ./contracts
      dockerfile: Dockerfile
    ports:
      - "8545:8545"
    volumes:
      - ganache-data:/app/.ganache
    networks:
      - backend-network
    command: npx hardhat node
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8545"]
      interval: 10s
      timeout: 5s
      retries: 5

  polygon-node:
    image: ethereum/client-go:v1.13.5
    ports:
      - "8546:8545"
    volumes:
      - polygon-data:/root/.ethereum
    networks:
      - backend-network
    command: --dev --http --http.addr 0.0.0.0 --http.api eth,net,web3,debug
    restart: unless-stopped

  arbitrum-node:
    image: offchainlabs/nitro-node:v2.0.0-rc.5
    ports:
      - "8547:8545"
    volumes:
      - arbitrum-data:/root/.arbitrum
    networks:
      - backend-network
    command: --dev-mode --http.api eth,net,web3,debug
    restart: unless-stopped

networks:
  frontend-network:
  backend-network:

volumes:
  postgres-data:
  redis-data:
  ganache-data:
  polygon-data:
  arbitrum-data:
```

### 6.2 Development Overrides

Create `docker-compose.dev.yml`:

```yaml
version: "3.8"

services:
  frontend:
    build:
      target: build
    volumes:
      - ./frontend:/app
      - /app/node_modules
    command: npm run dev
    environment:
      - NODE_ENV=development
      - VITE_API_URL=http://localhost:3001

  backend:
    build:
      target: build
    volumes:
      - ./backend:/app
      - /app/node_modules
    command: npm run dev
    environment:
      - NODE_ENV=development
      - DEBUG=zkvote:*

  bridge:
    volumes:
      - ./bridge:/app
      - /app/node_modules
    command: npm run dev
    environment:
      - NODE_ENV=development
      - DEBUG=zkvote:*

  postgres:
    ports:
      - "5432:5432"

  redis:
    ports:
      - "6379:6379"

  ganache:
    volumes:
      - ./contracts:/app
      - /app/node_modules
    environment:
      - MNEMONIC="test test test test test test test test test test test junk"

  polygon-node:
    environment:
      - DEVELOPER_MODE=true

  arbitrum-node:
    environment:
      - DEVELOPER_MODE=true

  # Add development-only services
  pqc-service:
    image: zkvote/pqc-signer:latest
    ports:
      - "3535:3535"
    volumes:
      - pqc-keys:/keys
    environment:
      - PQC_KEYSTORE_PATH=/keys
      - PQC_ALGORITHMS=dilithium5,falcon512
      - API_KEY=dev_api_key
    networks:
      - backend-network

volumes:
  pqc-keys:
```

### 6.3 Testing Configuration

Create `docker-compose.test.yml`:

```yaml
version: "3.8"

services:
  frontend-test:
    build:
      context: ./frontend
      target: build
    command: npm test
    environment:
      - NODE_ENV=test
      - JEST_JUNIT_OUTPUT_DIR=/reports
    volumes:
      - ./reports:/reports

  backend-test:
    build:
      context: ./backend
      target: build
    command: npm test
    environment:
      - NODE_ENV=test
      - DATABASE_URL=postgres://postgres:postgres@postgres:5432/zkvote_test
      - REDIS_URL=redis://redis:6379
      - BLOCKCHAIN_RPC=http://ganache:8545
      - JEST_JUNIT_OUTPUT_DIR=/reports
    volumes:
      - ./reports:/reports
    depends_on:
      - postgres
      - redis
      - ganache

  contract-test:
    build:
      context: ./contracts
    command: npx hardhat test
    environment:
      - NODE_ENV=test
      - REPORT_GAS=true
    volumes:
      - ./reports:/reports
    depends_on:
      - ganache

  bridge-test:
    build:
      context: ./bridge
      target: build
    command: npm test
    environment:
      - NODE_ENV=test
      - DATABASE_URL=postgres://postgres:postgres@postgres:5432/zkvote_bridge_test
      - REDIS_URL=redis://redis:6379
      - ETHEREUM_RPC=http://ganache:8545
      - POLYGON_RPC=http://polygon-node:8545
      - ARBITRUM_RPC=http://arbitrum-node:8545
      - JEST_JUNIT_OUTPUT_DIR=/reports
    volumes:
      - ./reports:/reports
    depends_on:
      - postgres
      - redis
      - ganache
      - polygon-node
      - arbitrum-node

  e2e-test:
    build:
      context: ./e2e
    command: npm run test:e2e
    environment:
      - FRONTEND_URL=http://frontend
      - API_URL=http://backend:3000
      - CYPRESS_VIDEO=true
    volumes:
      - ./reports:/reports
    depends_on:
      - frontend
      - backend
      - bridge

  postgres:
    environment:
      - POSTGRES_DB=zkvote_test

networks:
  default:
    name: zkvote-test-network
```

## 7. Kubernetes Deployment

### 7.1 Kustomize Structure

Create a Kustomize-based deployment structure:

```
k8s/
├── base/
│   ├── kustomization.yaml
│   ├── namespace.yaml
│   ├── frontend/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   ├── backend/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   ├── bridge/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   └── db/
│       ├── postgres-deployment.yaml
│       ├── postgres-service.yaml
│       ├── redis-deployment.yaml
│       ├── redis-service.yaml
│       └── storage-class.yaml
├── development/
│   ├── kustomization.yaml
│   ├── patches/
│   │   ├── frontend-deployment-patch.yaml
│   │   ├── backend-deployment-patch.yaml
│   │   └── bridge-deployment-patch.yaml
│   └── config/
│       ├── frontend-configmap.yaml
│       ├── backend-configmap.yaml
│       └── bridge-configmap.yaml
├── staging/
│   ├── kustomization.yaml
│   ├── patches/
│   │   ├── frontend-deployment-patch.yaml
│   │   ├── backend-deployment-patch.yaml
│   │   └── bridge-deployment-patch.yaml
│   └── config/
│       ├── frontend-configmap.yaml
│       ├── backend-configmap.yaml
│       └── bridge-configmap.yaml
└── production/
    ├── kustomization.yaml
    ├── patches/
    │   ├── frontend-deployment-patch.yaml
    │   ├── backend-deployment-patch.yaml
    │   └── bridge-deployment-patch.yaml
    ├── config/
    │   ├── frontend-configmap.yaml
    │   ├── backend-configmap.yaml
    │   └── bridge-configmap.yaml
    └── tls/
        ├── certificate.yaml
        └── ingress.yaml
```

### 7.2 Base Resources

Create `k8s/base/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - namespace.yaml
  - frontend/deployment.yaml
  - frontend/service.yaml
  - frontend/configmap.yaml
  - backend/deployment.yaml
  - backend/service.yaml
  - backend/configmap.yaml
  - bridge/deployment.yaml
  - bridge/service.yaml
  - bridge/configmap.yaml
  - db/postgres-deployment.yaml
  - db/postgres-service.yaml
  - db/redis-deployment.yaml
  - db/redis-service.yaml
  - db/storage-class.yaml

namespace: zkvote

commonLabels:
  app: zkvote
  part-of: zkvote
```

Create `k8s/base/namespace.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: zkvote
```

Create `k8s/base/frontend/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: ghcr.io/zkvote/frontend:latest
          ports:
            - containerPort: 80
          resources:
            limits:
              cpu: "0.5"
              memory: "512Mi"
            requests:
              cpu: "0.1"
              memory: "128Mi"
          livenessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 5
          envFrom:
            - configMapRef:
                name: frontend-config
          securityContext:
            runAsNonRoot: true
            runAsUser: 1000
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
```

Create `k8s/base/frontend/service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  selector:
    app: frontend
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
```

Create `k8s/base/frontend/configmap.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
data:
  NODE_ENV: "production"
  API_URL: "https://api.zkvote.io"
```

Create similar configurations for backend and bridge components.

### 7.3 Environment-Specific Resources

Create `k8s/development/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../base

namespace: zkvote-dev

namePrefix: dev-

commonLabels:
  environment: development

patchesStrategicMerge:
  - patches/frontend-deployment-patch.yaml
  - patches/backend-deployment-patch.yaml
  - patches/bridge-deployment-patch.yaml

configMapGenerator:
  - name: frontend-config
    behavior: merge
    files:
      - config/frontend-configmap.yaml
  - name: backend-config
    behavior: merge
    files:
      - config/backend-configmap.yaml
  - name: bridge-config
    behavior: merge
    files:
      - config/bridge-configmap.yaml

images:
  - name: ghcr.io/zkvote/frontend
    newTag: dev
  - name: ghcr.io/zkvote/backend
    newTag: dev
  - name: ghcr.io/zkvote/bridge
    newTag: dev
```

Create `k8s/development/patches/frontend-deployment-patch.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 1
  template:
    spec:
      containers:
        - name: frontend
          resources:
            limits:
              cpu: "0.2"
              memory: "256Mi"
            requests:
              cpu: "0.1"
              memory: "128Mi"
```

Create similar patch files for backend and bridge in the development, staging, and production environments.

### 7.4 Helm Charts

For more complex deployments, consider using Helm charts:

Create a basic Helm chart structure:

```
helm/
├── zkvote/
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── values-dev.yaml
│   ├── values-staging.yaml
│   ├── values-prod.yaml
│   ├── templates/
│   │   ├── _helpers.tpl
│   │   ├── frontend/
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   └── configmap.yaml
│   │   ├── backend/
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   └── configmap.yaml
│   │   ├── bridge/
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   └── configmap.yaml
│   │   ├── db/
│   │   │   ├── postgres-statefulset.yaml
│   │   │   ├── postgres-service.yaml
│   │   │   ├── redis-statefulset.yaml
│   │   │   └── redis-service.yaml
│   │   ├── ingress.yaml
│   │   └── namespace.yaml
│   └── charts/
│       └── .gitkeep
```

## 8. Environment Configuration Management

### 8.1 Environment Variables Strategy

Create a structured approach to manage environment variables:

```
config/
├── .env.development       # Development environment
├── .env.test              # Testing environment
├── .env.staging           # Staging environment
├── .env.production        # Production environment
└── .env.example           # Example file with variable names but no sensitive values
```

### 8.2 Secret Management

Options for secure secret management:

1. **Kubernetes Secrets**:

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: zkvote-secrets
     namespace: zkvote
   type: Opaque
   data:
     DATABASE_PASSWORD: cG9zdGdyZXM= # base64 encoded
     JWT_SECRET: c3VwZXJzZWNyZXRrZXk= # base64 encoded
     INFURA_API_KEY: eW91cmFwaWtleQ== # base64 encoded
   ```

2. **HashiCorp Vault** for more advanced secret management:

   ```yaml
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: zkvote-vault
     namespace: zkvote
   ---
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: backend
   spec:
     template:
       spec:
         serviceAccountName: zkvote-vault
         containers:
           - name: backend
             env:
               - name: VAULT_ADDR
                 value: "https://vault.example.com"
               - name: VAULT_PATH
                 value: "secret/zkvote/backend"
   ```

3. **Environment-Specific Configuration Files**:
   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: zkvote-config
   data:
     config.json: |
       {
         "database": {
           "host": "postgres",
           "port": 5432,
           "database": "zkvote"
         },
         "redis": {
           "host": "redis",
           "port": 6379
         },
         "blockchain": {
           "rpcUrl": "https://mainnet.infura.io/v3/${INFURA_API_KEY}"
         }
       }
   ```

### 8.3 Configuration Validation

Create a validation script to ensure all required configuration is present:

```javascript
// scripts/validate-config.js
const dotenv = require("dotenv");
const fs = require("fs");
const path = require("path");

// Load environment variables
const envFile = `.env.${process.env.NODE_ENV || "development"}`;
const envPath = path.resolve(process.cwd(), envFile);

if (fs.existsSync(envPath)) {
  dotenv.config({ path: envPath });
} else {
  console.warn(`Warning: ${envFile} not found, using process.env`);
}

// Define required variables
const requiredVariables = [
  "DATABASE_URL",
  "REDIS_URL",
  "JWT_SECRET",
  "INFURA_API_KEY",
  "BLOCKCHAIN_RPC",
];

// Validate variables
const missing = requiredVariables.filter((varName) => !process.env[varName]);

if (missing.length > 0) {
  console.error("Error: Missing required environment variables:");
  missing.forEach((varName) => console.error(`- ${varName}`));
  process.exit(1);
} else {
  console.log("Configuration validation passed!");
}
```

Run this script at the start of your application:

```javascript
// In your main application file
require("./scripts/validate-config");

// Rest of your application...
```

## 9. Blockchain-Specific Container Configurations

### 9.1 Blockchain Node Containers

Configure blockchain nodes for development and testing:

Create `k8s/base/blockchain/ethereum-node.yaml`:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: ethereum-node
  labels:
    app: ethereum-node
spec:
  serviceName: ethereum-node
  replicas: 1
  selector:
    matchLabels:
      app: ethereum-node
  template:
    metadata:
      labels:
        app: ethereum-node
    spec:
      containers:
        - name: ethereum-node
          image: ethereum/client-go:v1.13.5
          args:
            - --datadir=/data
            - --dev
            - --http
            - --http.addr=0.0.0.0
            - --http.vhosts=*
            - --http.api=eth,net,web3,debug,txpool
            - --ws
            - --ws.addr=0.0.0.0
            - --ws.origins=*
          ports:
            - containerPort: 8545
              name: http-rpc
            - containerPort: 8546
              name: ws-rpc
          volumeMounts:
            - name: ethereum-data
              mountPath: /data
          resources:
            limits:
              cpu: "2"
              memory: "4Gi"
            requests:
              cpu: "1"
              memory: "2Gi"
  volumeClaimTemplates:
    - metadata:
        name: ethereum-data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 10Gi
```

Create `k8s/base/blockchain/ethereum-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ethereum-node
spec:
  selector:
    app: ethereum-node
  ports:
    - port: 8545
      targetPort: 8545
      name: http-rpc
    - port: 8546
      targetPort: 8546
      name: ws-rpc
  type: ClusterIP
```

### 9.2 Smart Contract Deployment Container

Create a specialized container for deploying smart contracts:

Create `docker/contract-deployer.Dockerfile`:

```dockerfile
FROM node:20-alpine

# Install required tools
RUN apk add --no-cache git python3 g++ make

WORKDIR /app

# Copy package.json and install dependencies
COPY contracts/package*.json ./
RUN npm ci

# Copy deployment scripts and contracts
COPY contracts/scripts ./scripts
COPY contracts/src ./src
COPY contracts/hardhat.config.js ./

# Add quantum signature verification
COPY contracts/pqc-verify.js ./
RUN npm install -g @zkvote/pqc-tools

# Add entrypoint script
COPY scripts/deploy-contracts.sh /usr/local/bin/deploy-contracts.sh
RUN chmod +x /usr/local/bin/deploy-contracts.sh

# Set default command
ENTRYPOINT ["/usr/local/bin/deploy-contracts.sh"]
```

Create `scripts/deploy-contracts.sh`:

```bash
#!/bin/bash
set -e

# Verify PQC signatures if enabled
if [ "$PQC_VERIFY" = "true" ]; then
  echo "Verifying quantum-resistant signatures..."
  node pqc-verify.js
fi

# Set network based on environment
NETWORK="localhost"
case "$ENVIRONMENT" in
  "development")
    NETWORK="localhost"
    ;;
  "staging")
    NETWORK="sepolia"
    ;;
  "production")
    NETWORK="mainnet"
    ;;
  *)
    echo "Unknown environment: $ENVIRONMENT"
    exit 1
    ;;
esac

echo "Deploying contracts to $NETWORK..."
npx hardhat run scripts/deploy.js --network $NETWORK

# Verify contracts on Etherscan if not local network
if [ "$NETWORK" != "localhost" ]; then
  echo "Verifying contracts on Etherscan..."
  npx hardhat verify-contracts --network $NETWORK
fi

echo "Contract deployment completed!"
```

### 9.3 Circuit Compiler Container

Create a container for compiling zero-knowledge circuits:

Create `docker/circuit-compiler.Dockerfile`:

```dockerfile
FROM rust:1.75-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git make musl-dev

# Build circom from source for better optimization
RUN git clone https://github.com/iden3/circom.git && \
    cd circom && \
    cargo build --release && \
    mv target/release/circom /usr/local/bin/

FROM node:20-alpine

# Copy circom binary from builder
COPY --from=builder /usr/local/bin/circom /usr/local/bin/circom

# Install required tools
RUN apk add --no-cache git python3 g++ make

WORKDIR /app

# Install snarkjs
RUN npm install -g snarkjs

# Copy circuit files
COPY circuits/package*.json ./
RUN npm ci

COPY circuits/src ./src
COPY circuits/scripts ./scripts

# Add entrypoint script
COPY scripts/compile-circuits.sh /usr/local/bin/compile-circuits.sh
RUN chmod +x /usr/local/bin/compile-circuits.sh

# Set default command
ENTRYPOINT ["/usr/local/bin/compile-circuits.sh"]
```

Create `scripts/compile-circuits.sh`:

```bash
#!/bin/bash
set -e

# Create output directories
mkdir -p build/circuits
mkdir -p build/verification_keys

# Compile all circuits
for circuit in src/*.circom; do
  echo "Compiling $circuit..."

  # Get circuit name without path and extension
  CIRCUIT_NAME=$(basename "$circuit" .circom)

  # Compile circuit
  circom "$circuit" --r1cs --wasm --sym -o build/circuits

  # Generate proving key
  echo "Generating proving key for $CIRCUIT_NAME..."
  snarkjs powersoftau new bn128 12 build/circuits/$CIRCUIT_NAME.ptau -v
  snarkjs powersoftau contribute build/circuits/$CIRCUIT_NAME.ptau build/circuits/$CIRCUIT_NAME.ptau --name="First contribution" -v -e="random entropy"
  snarkjs powersoftau prepare phase2 build/circuits/$CIRCUIT_NAME.ptau build/circuits/$CIRCUIT_NAME.ptau2 -v
  snarkjs groth16 setup build/circuits/$CIRCUIT_NAME.r1cs build/circuits/$CIRCUIT_NAME.ptau2 build/circuits/$CIRCUIT_NAME.zkey -v
  snarkjs zkey contribute build/circuits/$CIRCUIT_NAME.zkey build/circuits/$CIRCUIT_NAME.zkey --name="Second contribution" -e="more random entropy" -v

  # Export verification key
  echo "Exporting verification key for $CIRCUIT_NAME..."
  snarkjs zkey export verificationkey build/circuits/$CIRCUIT_NAME.zkey build/verification_keys/$CIRCUIT_NAME.json
done

echo "Circuit compilation completed!"
```

## 10. Quantum-Safe Containerization

### 10.1 Post-Quantum Cryptography Integration

Create a container with post-quantum cryptography support:

Create `docker/pqc-service.Dockerfile`:

```dockerfile
FROM node:20-alpine

# Install liboqs and other PQC libraries
RUN apk add --no-cache \
    git \
    cmake \
    make \
    g++ \
    liboqs-dev \
    openssl-dev

# Install PQC tools
RUN npm install -g @zkvote/pqc-tools

WORKDIR /app

# Copy application files
COPY pqc-service/package*.json ./
RUN npm ci

COPY pqc-service/src ./src

# Create key directory
RUN mkdir -p /keys && \
    chmod 700 /keys

# Expose API port
EXPOSE 3535

# Use non-root user
USER node

# Run the service
CMD ["node", "src/index.js"]
```

### 10.2 Quantum-Safe Docker Composition

Create a Docker Compose file for quantum-safe services:

Create `docker-compose.quantum-safe.yml`:

```yaml
version: "3.8"

services:
  pqc-service:
    build:
      context: .
      dockerfile: docker/pqc-service.Dockerfile
    ports:
      - "3535:3535"
    volumes:
      - pqc-keys:/keys
    environment:
      - NODE_ENV=production
      - PQC_KEYSTORE_PATH=/keys
      - PQC_ALGORITHMS=dilithium5,falcon512,kyber768
      - API_KEY=${PQC_API_KEY}
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3535/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
    networks:
      - backend-network

  pqc-gateway:
    build:
      context: .
      dockerfile: docker/pqc-gateway.Dockerfile
    ports:
      - "8443:8443"
    volumes:
      - pqc-certs:/certs
    environment:
      - NODE_ENV=production
      - PQC_SERVICE_URL=http://pqc-service:3535
      - PQC_API_KEY=${PQC_API_KEY}
      - TLS_CERT_PATH=/certs/server.crt
      - TLS_KEY_PATH=/certs/server.key
    restart: unless-stopped
    depends_on:
      - pqc-service
    networks:
      - frontend-network
      - backend-network

networks:
  frontend-network:
  backend-network:

volumes:
  pqc-keys:
  pqc-certs:
```

### 10.3 Quantum-Safe TLS Configuration

Configure quantum-safe TLS for secure communications:

Create `pqc-service/src/generate-certs.js`:

```javascript
const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

// Create certificates directory
const certsDir = path.resolve(__dirname, "../certs");
if (!fs.existsSync(certsDir)) {
  fs.mkdirSync(certsDir, { recursive: true });
}

// Generate CA key and certificate
console.log("Generating CA key and certificate...");
execSync(`
  openssl req -x509 -new -newkey dilithium5 -keyout ${certsDir}/ca.key -out ${certsDir}/ca.crt -nodes -subj "/CN=zkVote Quantum CA" -days 3650
`);

// Generate server key and certificate
console.log("Generating server key and certificate...");
execSync(`
  openssl req -new -newkey dilithium5 -keyout ${certsDir}/server.key -out ${certsDir}/server.csr -nodes -subj "/CN=zkvote.io"
`);

// Sign server certificate with CA
console.log("Signing server certificate...");
execSync(`
  openssl x509 -req -in ${certsDir}/server.csr -CA ${certsDir}/ca.crt -CAkey ${certsDir}/ca.key -CAcreateserial -out ${certsDir}/server.crt -days 365
`);

// Generate client key and certificate
console.log("Generating client key and certificate...");
execSync(`
  openssl req -new -newkey dilithium5 -keyout ${certsDir}/client.key -out ${certsDir}/client.csr -nodes -subj "/CN=client"
`);

// Sign client certificate with CA
console.log("Signing client certificate...");
execSync(`
  openssl x509 -req -in ${certsDir}/client.csr -CA ${certsDir}/ca.crt -CAkey ${certsDir}/ca.key -CAcreateserial -out ${certsDir}/client.crt -days 365
`);

console.log("Certificate generation completed!");
```

Create `pqc-service/src/quantum-tls.js`:

```javascript
const https = require("https");
const fs = require("fs");
const path = require("path");

// Load quantum-safe TLS configuration
function configureQuantumSafeTLS(app) {
  // Load certificates
  const certsDir = process.env.CERTS_DIR || path.resolve(__dirname, "../certs");

  const tlsOptions = {
    key: fs.readFileSync(path.join(certsDir, "server.key")),
    cert: fs.readFileSync(path.join(certsDir, "server.crt")),
    ca: fs.readFileSync(path.join(certsDir, "ca.crt")),

    // Enable PQC cipher suites
    ciphers: [
      "TLS_KEMTLS_KYBER768_WITH_DILITHIUM3",
      "TLS_KEMTLS_KYBER512_WITH_DILITHIUM2",
      "ECDHE-RSA-AES256-GCM-SHA384", // Fallback
    ].join(":"),

    // Request client certificate
    requestCert: true,
    rejectUnauthorized: false, // Can be set to true in production
  };

  // Create HTTPS server
  const server = https.createServer(tlsOptions, app);

  return server;
}

module.exports = { configureQuantumSafeTLS };
```

## 11. Cross-Chain Testing Environment

### 11.1 Multi-Chain Local Development Setup

Create a Docker Compose file for multi-chain development:

Create `docker-compose.multichain.yml`:

```yaml
version: "3.8"

services:
  # Ethereum L1 node
  ethereum:
    image: ethereum/client-go:v1.13.5
    ports:
      - "8545:8545"
      - "8546:8546"
    volumes:
      - ethereum-data:/root/.ethereum
    command: >
      --dev
      --http
      --http.addr=0.0.0.0
      --http.api=eth,net,web3,debug,txpool
      --ws
      --ws.addr=0.0.0.0
      --ws.api=eth,net,web3,debug,txpool
      --allow-insecure-unlock
    networks:
      - blockchain-network

  # Polygon zkEVM node
  zkevm:
    image: hermeznetwork/zkevm-node:latest
    ports:
      - "8546:8545"
    volumes:
      - zkevm-data:/var/lib/zkevm
    environment:
      - ETH_NETWORK=development
      - ETH_NODE_URL=http://ethereum:8545
    networks:
      - blockchain-network
    depends_on:
      - ethereum

  # Arbitrum node
  arbitrum:
    image: offchainlabs/nitro-node:v2.0.0-rc.5
    ports:
      - "8547:8545"
    volumes:
      - arbitrum-data:/data
    environment:
      - DEVNET=true
      - L1_URL=http://ethereum:8545
    networks:
      - blockchain-network
    depends_on:
      - ethereum

  # Optimism node
  optimism:
    image: ethereumoptimism/op-node:latest
    ports:
      - "8548:8545"
    volumes:
      - optimism-data:/data
    environment:
      - L1_RPC=http://ethereum:8545
      - DEVNET=true
    networks:
      - blockchain-network
    depends_on:
      - ethereum

  # Base node
  base:
    image: coinbase/base-node:latest
    ports:
      - "8549:8545"
    volumes:
      - base-data:/data
    environment:
      - L1_RPC=http://ethereum:8545
      - DEVNET=true
    networks:
      - blockchain-network
    depends_on:
      - ethereum

  # Cross-chain test orchestrator
  orchestrator:
    build:
      context: .
      dockerfile: docker/cross-chain-orchestrator.Dockerfile
    ports:
      - "3003:3000"
    volumes:
      - ./cross-chain-tests:/app/tests
      - orchestrator-data:/app/data
    environment:
      - ETHEREUM_RPC=http://ethereum:8545
      - POLYGON_ZKEVM_RPC=http://zkevm:8545
      - ARBITRUM_RPC=http://arbitrum:8545
      - OPTIMISM_RPC=http://optimism:8545
      - BASE_RPC=http://base:8545
    networks:
      - blockchain-network
    depends_on:
      - ethereum
      - zkevm
      - arbitrum
      - optimism
      - base

networks:
  blockchain-network:
    driver: bridge

volumes:
  ethereum-data:
  zkevm-data:
  arbitrum-data:
  optimism-data:
  base-data:
  orchestrator-data:
```

### 11.2 Cross-Chain Test Orchestrator

Create a container for the test orchestrator:

Create `docker/cross-chain-orchestrator.Dockerfile`:

```dockerfile
FROM node:20-alpine

# Install required tools
RUN apk add --no-cache git python3 g++ make jq

WORKDIR /app

# Copy orchestrator code
COPY cross-chain-orchestrator/package*.json ./
RUN npm ci

COPY cross-chain-orchestrator/src ./src

# Create data directory
RUN mkdir -p /app/data

# Expose API port
EXPOSE 3000

# Run the orchestrator
CMD ["node", "src/index.js"]
```

Create `scripts/setup-cross-chain.sh`:

```bash
#!/bin/bash
set -e

echo "Setting up cross-chain testing environment..."

# Start the multi-chain environment
docker-compose -f docker-compose.multichain.yml up -d

# Wait for nodes to be ready
echo "Waiting for blockchain nodes to be ready..."
sleep 10

# Deploy bridge contracts to all chains
echo "Deploying bridge contracts..."
docker exec -it orchestrator npm run deploy-bridges

# Set up cross-chain message passing
echo "Setting up cross-chain communication..."
docker exec -it orchestrator npm run setup-ccip

# Run test transactions
echo "Running cross-chain test transactions..."
docker exec -it orchestrator npm run test-transfers

echo "Cross-chain environment setup complete!"
```

### 11.3 Cross-Chain Testing Architecture

Create a diagram of the cross-chain testing architecture in `docs/cross-chain-testing.md`:

```markdown
# Cross-Chain Testing Architecture

## Overview

The zkVote cross-chain testing environment simulates a multi-chain ecosystem for validating the protocol's cross-chain capabilities. This environment includes multiple blockchain networks and a test orchestrator to coordinate cross-chain operations.
```

Include a graph diagram:

```
graph TD
    A[Ethereum L1] -->|CCIP| B{Test Orchestrator}
    B --> C[Polygon zkEVM]
    B --> D[Arbitrum Nova]
    B --> E[Optimism]
    B --> F[Base]
    C --> G{Consensus Check}
    D --> G
    E --> G
    F --> G
```

```markdown
## Components

### Blockchain Nodes

- **Ethereum L1**: Main chain that serves as the source of truth
- **Polygon zkEVM**: Layer 2 with ZK-rollup technology
- **Arbitrum**: Layer 2 with optimistic rollup technology
- **Optimism**: Layer 2 with optimistic rollup technology
- **Base**: Layer 2 built on the Optimism stack

### Test Orchestrator

Coordinates test transactions across all chains and validates that:

1. Messages are correctly passed between chains
2. Data consistency is maintained across chains
3. Transaction atomicity is preserved
4. Bridge functionality works as expected
5. Voting results are properly aggregated
```

## 12. Monitoring and Logging

### 12.1 Logging Configuration

Create logging configurations for containerized applications:

Create `backend/src/config/logger.js`:

```javascript
const winston = require("winston");
const { format } = winston;

// Configure log format based on environment
const logFormat =
  process.env.NODE_ENV === "production"
    ? format.json()
    : format.combine(
        format.colorize(),
        format.timestamp(),
        format.printf(({ timestamp, level, message, ...meta }) => {
          return `${timestamp} [${level}]: ${message} ${
            Object.keys(meta).length ? JSON.stringify(meta, null, 2) : ""
          }`;
        })
      );

// Create Winston logger
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || "info",
  format: format.combine(
    format.timestamp(),
    format.errors({ stack: true }),
    logFormat
  ),
  defaultMeta: { service: "zkvote-backend" },
  transports: [new winston.transports.Console()],
});

// Add file transport in production
if (process.env.NODE_ENV === "production") {
  logger.add(
    new winston.transports.File({
      filename: "/var/log/zkvote/error.log",
      level: "error",
    })
  );
  logger.add(
    new winston.transports.File({
      filename: "/var/log/zkvote/combined.log",
    })
  );
}

module.exports = logger;
```

### 12.2 Prometheus Metrics

Create a Prometheus configuration for monitoring:

Create `k8s/base/monitoring/prometheus-config.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s

    scrape_configs:
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            target_label: __address__
          - action: labelmap
            regex: __meta_kubernetes_pod_label_(.+)
          - source_labels: [__meta_kubernetes_namespace]
            action: replace
            target_label: kubernetes_namespace
          - source_labels: [__meta_kubernetes_pod_name]
            action: replace
            target_label: kubernetes_pod_name
```

Create `k8s/base/monitoring/prometheus-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
        - name: prometheus
          image: prom/prometheus:v2.43.0
          args:
            - "--config.file=/etc/prometheus/prometheus.yml"
            - "--storage.tsdb.path=/prometheus"
          ports:
            - containerPort: 9090
          volumeMounts:
            - name: prometheus-config
              mountPath: /etc/prometheus
            - name: prometheus-storage
              mountPath: /prometheus
      volumes:
        - name: prometheus-config
          configMap:
            name: prometheus-config
        - name: prometheus-storage
          emptyDir: {}
```

### 12.3 Metrics Endpoints

Add metrics endpoints to service containers:

Update `backend/src/app.js`:

```javascript
const express = require("express");
const promBundle = require("express-prom-bundle");
const logger = require("./config/logger");

const app = express();

// Add Prometheus metrics middleware
const metricsMiddleware = promBundle({
  includeMethod: true,
  includePath: true,
  includeStatusCode: true,
  includeUp: true,
  customLabels: { app: "zkvote-backend" },
  promClient: {
    collectDefaultMetrics: {
      timeout: 5000,
    },
  },
});
app.use(metricsMiddleware);

// Add custom metrics
const { Counter, Histogram } = require("prom-client");

// Transaction metrics
const txCounter = new Counter({
  name: "zkvote_transactions_total",
  help: "Total number of blockchain transactions",
  labelNames: ["status", "chain"],
});

// Vote processing time
const voteProcessingTime = new Histogram({
  name: "zkvote_vote_processing_seconds",
  help: "Time taken to process votes",
  labelNames: ["type"],
  buckets: [0.1, 0.5, 1, 2, 5, 10],
});

// Rest of the application code...

module.exports = app;
```

### 12.4 Grafana Dashboard

Create a Grafana deployment for visualization:

Create `k8s/base/monitoring/grafana-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
        - name: grafana
          image: grafana/grafana:9.4.3
          ports:
            - containerPort: 3000
          volumeMounts:
            - name: grafana-storage
              mountPath: /var/lib/grafana
            - name: grafana-datasources
              mountPath: /etc/grafana/provisioning/datasources
            - name: grafana-dashboards
              mountPath: /etc/grafana/provisioning/dashboards
      volumes:
        - name: grafana-storage
          emptyDir: {}
        - name: grafana-datasources
          configMap:
            name: grafana-datasources
        - name: grafana-dashboards
          configMap:
            name: grafana-dashboards
```

Create `k8s/base/monitoring/grafana-datasources.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-datasources
data:
  datasources.yaml: |
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://prometheus:9090
        access: proxy
        isDefault: true
```

## 13. Security Considerations

### 13.1 Container Security

Create a security policy for container hardening:

Create `docker/security/container-security-policy.md`:

```markdown
# Container Security Policy

## Base Image Security

- Use official minimal base images (Alpine-based where possible)
- Pin exact image versions with SHA256 digests
- Regular scanning of base images for vulnerabilities
- Automatic updates for critical security patches

## Container Hardening

- Run containers as non-root users
- Use read-only root filesystems where possible
- Drop all Linux capabilities except those required
- Use seccomp profiles to restrict system calls
- Set resource limits for all containers

## Runtime Security

- Enable user namespace isolation
- Implement network policies for pod-to-pod communication
- Use admission controllers for policy enforcement
- Regular vulnerability scanning of deployed containers
- Implement least privilege principle for all services
```

### 13.2 Secret Management

Create scripts for securely handling secrets:

Create `scripts/generate-secrets.sh`:

```bash
#!/bin/bash
set -e

# Create random secrets for different environments
ENVIRONMENT=$1
OUTPUT_DIR="./secrets/$ENVIRONMENT"

if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: $0 <environment>"
  echo "Where environment is: development, staging, or production"
  exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Generate random secrets
echo "Generating secrets for $ENVIRONMENT environment..."

# Database password
openssl rand -base64 32 > "$OUTPUT_DIR/db-password.txt"

# JWT secret
openssl rand -base64 64 > "$OUTPUT_DIR/jwt-secret.txt"

# API keys
openssl rand -hex 32 > "$OUTPUT_DIR/api-key.txt"

# Generate PQC keys if enabled
if [ "$PQC_ENABLED" = "true" ]; then
  echo "Generating post-quantum cryptographic keys..."

  # Create PQC directory
  mkdir -p "$OUTPUT_DIR/pqc"

  # Generate Dilithium keys
  pqc-tools generate --algorithm dilithium5 --output "$OUTPUT_DIR/pqc/dilithium-key"

  # Generate Kyber keys
  pqc-tools generate --algorithm kyber768 --output "$OUTPUT_DIR/pqc/kyber-key"
fi

echo "Secret generation complete! Secrets stored in $OUTPUT_DIR"
```

Create `k8s/base/security/network-policy.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - ipBlock:
            cidr: 0.0.0.0/0
      ports:
        - protocol: TCP
          port: 80
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: backend
      ports:
        - protocol: TCP
          port: 3000
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 3000
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: postgres
      ports:
        - protocol: TCP
          port: 5432
    - to:
        - podSelector:
            matchLabels:
              app: redis
      ports:
        - protocol: TCP
          port: 6379
    - to:
        - podSelector:
            matchLabels:
              app: bridge
      ports:
        - protocol: TCP
          port: 3001
```

### 13.3 Pod Security Policies

Create Kubernetes pod security policies:

Create `k8s/base/security/pod-security-context.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: backend
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
            privileged: false
```

## 14. Disaster Recovery and Backup

### 14.1 Database Backup Strategy

Create a database backup configuration:

Create `k8s/base/backup/postgres-backup.yaml`:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup
spec:
  schedule: "0 1 * * *" # Daily at 1 AM
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: postgres-backup
              image: postgres:15-alpine
              command:
                - /bin/sh
                - -c
                - |
                  pg_dump -h postgres -U postgres -d zkvote > /backup/zkvote-$(date +%Y%m%d).sql
                  gzip /backup/zkvote-$(date +%Y%m%d).sql
              env:
                - name: PGPASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: postgres-secrets
                      key: password
              volumeMounts:
                - name: backup-volume
                  mountPath: /backup
          restartPolicy: OnFailure
          volumes:
            - name: backup-volume
              persistentVolumeClaim:
                claimName: backup-pvc
```

### 14.2 Blockchain State Snapshot

Create a script for blockchain state snapshots:

Create `scripts/blockchain-snapshot.sh`:

```bash
#!/bin/bash
set -e

# Create a snapshot of blockchain state
ENVIRONMENT=$1
SNAPSHOT_DIR="./snapshots/$ENVIRONMENT/$(date +%Y%m%d-%H%M%S)"

if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: $0 <environment>"
  echo "Where environment is: development, staging, or production"
  exit 1
fi

# Create snapshot directory
mkdir -p "$SNAPSHOT_DIR"

# Get chain endpoints based on environment
if [ "$ENVIRONMENT" = "development" ]; then
  ETHEREUM_RPC="http://localhost:8545"
  POLYGON_RPC="http://localhost:8546"
  ARBITRUM_RPC="http://localhost:8547"
elif [ "$ENVIRONMENT" = "staging" ]; then
  ETHEREUM_RPC="https://sepolia.infura.io/v3/$INFURA_API_KEY"
  POLYGON_RPC="https://polygon-mumbai.infura.io/v3/$INFURA_API_KEY"
  ARBITRUM_RPC="https://arbitrum-sepolia.infura.io/v3/$INFURA_API_KEY"
else
  ETHEREUM_RPC="https://mainnet.infura.io/v3/$INFURA_API_KEY"
  POLYGON_RPC="https://polygon-mainnet.infura.io/v3/$INFURA_API_KEY"
  ARBITRUM_RPC="https://arbitrum-one.infura.io/v3/$INFURA_API_KEY"
fi

# Snapshot Ethereum state
echo "Creating Ethereum state snapshot..."
curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest", false],"id":1}' $ETHEREUM_RPC > "$SNAPSHOT_DIR/ethereum-latest-block.json"

# Get contract state
echo "Snapshotting contract state..."
CONTRACT_ADDRESSES=(
  "0x1234567890123456789012345678901234567890" # Main contract
  "0x0987654321098765432109876543210987654321" # Bridge contract
  "0xabcdef0123456789abcdef0123456789abcdef01" # Registry contract
)

for CONTRACT in "${CONTRACT_ADDRESSES[@]}"; do
  echo "Snapshotting contract $CONTRACT..."
  curl -s -X POST -H "Content-Type: application/json" --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getCode\",\"params\":[\"$CONTRACT\", \"latest\"],\"id\":1}" $ETHEREUM_RPC > "$SNAPSHOT_DIR/$CONTRACT-code.json"

  # Get storage slots (this is a simplified version)
  for SLOT in {0..10}; do
    SLOT_HEX=$(printf "0x%064x" $SLOT)
    curl -s -X POST -H "Content-Type: application/json" --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getStorageAt\",\"params\":[\"$CONTRACT\", \"$SLOT_HEX\", \"latest\"],\"id\":1}" $ETHEREUM_RPC > "$SNAPSHOT_DIR/$CONTRACT-slot-$SLOT.json"
  done
done

echo "Blockchain state snapshot complete! Snapshot stored in $SNAPSHOT_DIR"
```

### 14.3 Recovery Plan

Create a disaster recovery plan:

Create `docs/disaster-recovery-plan.md`:

# zkVote Disaster Recovery Plan

## Overview

This document outlines the procedures to recover the zkVote system in case of catastrophic failures, data corruption, or security incidents.

## Recovery Scenarios

### 1. Database Corruption or Loss

**Recovery Steps:**

1. Stop affected services:

   ```bash
   kubectl scale deployment backend --replicas=0
   kubectl scale deployment bridge --replicas=0
   ```

2. Restore from latest backup:

   ```bash
   # Get latest backup
   LATEST_BACKUP=$(ls -t /backup/zkvote-*.sql.gz | head -1)

   # Restore database
   gunzip -c $LATEST_BACKUP | kubectl exec -i postgres-0 -- psql -U postgres -d zkvote
   ```

3. Restart services:

   ```bash
   kubectl scale deployment backend --replicas=3
   kubectl scale deployment bridge --replicas=2
   ```

4. Verify data integrity.

### 2. Blockchain Smart Contract Recovery

**Recovery Steps:**

1. Identify compromised contracts from security monitoring.

2. Deploy emergency fix contracts:

   ```bash
   # Deploy fixed version
   cd contracts
   EMERGENCY=true npm run deploy:recovery
   ```

3. Migrate state from snapshot if necessary.

4. Update contract addresses in configuration.

5. Restart dependent services.

### 3. Kubernetes Cluster Failure

**Recovery Steps:**

1. Create new cluster from backup configuration:

   ```bash
   ./scripts/create-cluster.sh --from-backup
   ```

2. Restore persistent volumes from backups.

3. Apply Kubernetes configurations:

   ```bash
   kubectl apply -k k8s/production
   ```

4. Verify all services are operational.

## Backup Schedule

| Resource         | Frequency | Retention |
| ---------------- | --------- | --------- |
| Database         | Daily     | 30 days   |
| Blockchain State | Daily     | 7 days    |
| Configuration    | On change | 90 days   |
| Logs             | Hourly    | 14 days   |

## Testing Schedule

Recovery procedures should be tested quarterly using a staging environment to ensure they work as expected.

## 15. References and Additional Resources

### 15.1 Docker and Kubernetes Documentation

#### Official Documentation

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kustomize Documentation](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)

#### Container Best Practices

- [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [CNCF Cloud Native Security Whitepaper](https://github.com/cncf/tag-security/tree/main/security-whitepaper)

#### Post-Quantum Cryptography

- [NIST Post-Quantum Cryptography](https://csrc.nist.gov/projects/post-quantum-cryptography)
- [OpenSSL Post-Quantum Documentation](https://www.openssl.org/docs/man3.0/man7/oqs.html)
- [liboqs Documentation](https://openquantumsafe.org/liboqs/)

#### Multi-Chain Development

- [ChainLink CCIP Documentation](https://docs.chain.link/ccip)
- [LayerZero Documentation](https://layerzero.network/developers)
- [Polygon zkEVM Documentation](https://polygon.technology/polygon-zkevm)
- [Arbitrum Documentation](https://docs.arbitrum.io/)

````

### 15.2 Tool Versions Table

```markdown
## Required Tools and Versions

| Tool           | Required Version | Notes                                 |
| -------------- | ---------------- | ------------------------------------- |
| Docker         | 25.0+            | For containerization                  |
| Docker Compose | 2.20+            | For local development                 |
| Kubernetes     | 1.28+            | For orchestration                     |
| Helm           | 3.13+            | For package management                |
| VSCode         | 1.84+            | Recommended IDE                       |
| Node.js        | 18.17+ / 20.9+   | For JavaScript/TypeScript development |
| Rust           | 1.76+            | For cryptographic libraries           |
| Go             | 1.21+            | For some blockchain tools             |
| OpenSSL        | 3.2+             | With NIST PQC support                 |
````

### 15.3 Troubleshooting Guide

```markdown
## Common Issues and Solutions

### Docker Container Won't Start

**Symptoms**: Container exits immediately after starting.

**Solutions**:

- Check logs: `docker logs <container_id>`
- Verify environment variables: `docker inspect <container_id> | grep -A 20 "Env"`
- Check for permission issues: `ls -la ./volume/path`
- Try running with elevated privileges for debugging: `docker run --privileged ...`

### Kubernetes Pod Crashes

**Symptoms**: Pod continuously restarts or shows CrashLoopBackOff.

**Solutions**:

- Check pod logs: `kubectl logs <pod_name>`
- Describe the pod: `kubectl describe pod <pod_name>`
- Check events: `kubectl get events`
- Verify resource limits: `kubectl describe pod <pod_name> | grep -A 10 "Limits"`

### Database Connection Issues

**Symptoms**: Services can't connect to the database.

**Solutions**:

- Check if database pod is running: `kubectl get pods | grep postgres`
- Verify connection string: `kubectl describe configmap backend-config | grep DATABASE_URL`
- Try direct connection: `kubectl exec -it <pod_name> -- psql -U postgres -h postgres`
- Check network policies: `kubectl describe networkpolicy`

### Cross-Chain Communication Failures

**Symptoms**: Messages aren't propagating between chains.

**Solutions**:

- Check RPC endpoints: `kubectl describe configmap bridge-config | grep RPC`
- Verify contract addresses: `kubectl describe configmap bridge-config | grep CONTRACT`
- Check bridge logs: `kubectl logs <bridge_pod>`
- Try manual transaction: `kubectl exec -it <bridge_pod> -- node /app/scripts/test-ccip.js`
```

---
