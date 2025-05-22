#!/bin/bash
# This script sets up the development environment for the project.
# It installs the required dependencies and sets up the virtual environment.
set -e

# Initialize all project components
echo "Initializing zkVote development environment..."

# Install root dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing root dependencies..."
    npm ci
fi

# Install frontend
if [ -d "frontend" ]; then
    echo "Setting up frontend..."
    cd frontend
    [ ! -d "node_modules" ] && npm ci
    cd ..
fi

# Initialize backend
if [ -d "backend" ]; then
    echo "Setting up backend..."
    cd backend
    [ ! -d "node_modules" ] && npm ci
    [ ! -f ".env.local" ] && cp .env.example .env.local
    cd ..
fi

# Initialize contracts
if [ -d "contracts" ]; then
    echo "Setting up smart contracts..."
    cd contracts
    [ ! -d "node_modules" ] && npm ci
    [ ! -f ".env.local" ] && cp .env.example .env.local
    [ ! -d "artifacts" ] && npx hardhat compile
    cd ..
fi

# Initialize circuits
if [ -d "circuits" ]; then
    echo "Setting up ZK circuits..."
    cd circuits
    [ ! -d "node_modules" ] && npm ci
    [ ! -d  "build" ] && mkdir -p build
    cd ..
fi

# Initialize bridge
if [ -d "bridge" ]; then
    echo "Setting up cross-chain bridge..."
    cd bridge
    [ ! -d "node_modules" ] && npm ci
    [ ! -f ".env.local" ] && cp .env.example .env.local
    cd ..
fi

# Setup PQC environment if enabled
if [ "$PQC_ENABLED" = "true" ]; then
    echo "Setting up post-quantum cryptography environment..."
    mkdir -p ~/.zkvote/pqc
    pqc-tools setup
fi

echo "Development environment initialization complete!"
