# Build image for circom compiler (Rust-based)
FROM rust:1.86-alpine AS builder

# Install essential build tools and libraries:
# - git: for cloning repositories
# - make: for building projects
# - musl-dev: for compiling C/C++ programs against musl libc
# The --no-cache option ensures that no intermediate cache is stored, reducing image size.
RUN apk add --no-cache \
    git \
    make \
    musl-dev

# Build circom from source for better optimization
RUN git clone https://github.com/iden3/circom.git && \
    cd circom && \
    cargo build --release && \
    mv target/release/circom /usr/local/bin/

# Build image for circom compiler (Node.js-based)
FROM node:22-alpine

# Copy the circom binary from the builder stage
COPY --from=builder /usr/local/bin/circom /usr/local/bin/circom

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

# Install snarkjs globally
RUN npm install -g snarkjs

# Copy circuit files and package.json
COPY circuits/package*.json ./
RUN npm ci
COPY circuits ./circuits
COPY circuits/scripts ./scripts


# Copies the compile-scripts.sh script into the container's /usr/local/bin directory
# and sets the execute permission, making it runnable as a command inside the container.
COPY scripts/compile-scripts.sh /usr/local/bin/compile-scripts.sh
RUN chmod +x /usr/local/bin/compile-scripts.sh

# Set default command to run the compile script
ENTRYPOINT [ "/usr/local/bin/compile-scripts.sh" ]
