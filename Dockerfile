# Use an Ubuntu base image
FROM ubuntu:20.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install basic dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    software-properties-common \
    wget \
    libgmp-dev \
    nlohmann-json3-dev \
    nasm \
    python3 \
    python3-pip \
    gnupg \
 && rm -rf /var/lib/apt/lists/*

# Install Rust using rustup (this installs both Rust and Cargo)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# Add Rust's bin directory to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Node.js v22.x (latest LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs

# Install the Solidity compiler (solc) from the Ethereum PPA
RUN npm install -g solc && \
    # Create a symlink so we can run "solc --version" instead of "solcjs --version"
    ln -s $(which solcjs) /usr/local/bin/solc || true

# Clone, checkout, and build the Rust version of circom (v2.2.1)
RUN git clone https://github.com/iden3/circom.git /circom && \
    cd /circom && \
    git checkout v2.2.1 && \
    cargo build --release && \
    cp target/release/circom /usr/local/bin

# Install snarkjs and Hardhat globally via npm
RUN npm install -g snarkjs hardhat

# Set the working directory
WORKDIR /app

# Copy the contents of the current directory to the working directory
COPY . .

# Make the keys directory
RUN mkdir keys

# Decrypt the secret key
ARG ZKEY_PASSPHRASE
RUN gpg --quiet --batch --yes --decrypt --passphrase="$ZKEY_PASSPHRASE" --output keys/voting_0001.zkey keys/voting_0001.zkey.gpg

# Start a bash shell when the container runs
CMD ["/bin/bash"]