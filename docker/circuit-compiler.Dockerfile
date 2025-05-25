# Build image for circom compiler (Rust-based)
FROM rust:1.86-alpine AS circom_builder

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
FROM node:22-alpine AS final

# Copy the circom binary from the builder stage
COPY --from=circom_builder /usr/local/bin/circom /usr/local/bin/circom

# Install essential build and development tools:
# - git: for version control and cloning repositories
# - g++: for compiling C++ source code
# - make: for managing build automation
# The '--no-cache' option ensures that no intermediate cache is used, reducing image size.
RUN apk add --no-cache --virtual .build-deps\
    git \
    g++ \
    make

# Set the working directory
WORKDIR /app

# Install snarkjs globally
RUN npm install -g snarkjs

# Copy circuit files and package.json
COPY circuits/package*.json ./
RUN npm ci

# Clean up build-only OS dependencies
RUN apk del .build-deps

# Define a build argument APP_USER with default value 'node'.
# Create a new group with the name specified by APP_USER.
# Create a new user with the name specified by APP_USER, assign it to the group,
# and set its default shell to /bin/bash.
ARG APP_USER=node
RUN addgroup -S ${APP_USER} && adduser -S -G ${APP_USER} --shell /bin/bash ${APP_USER}


# Copies the local 'circuits' directory into the image at './circuits'
# Copies the 'scripts' subdirectory from 'circuits' into the image at './scripts'
COPY circuits ./circuits
COPY circuits/scripts ./scripts


# Copies the compile-scripts.sh script into the container's /usr/local/bin directory
# and sets the execute permission, making it runnable as a command inside the container.
COPY scripts/compile-scripts.sh /usr/local/bin/compile-scripts.sh
RUN chmod +x /usr/local/bin/compile-scripts.sh

# Change ownership of the compile-scripts.sh script and the /app directory to the application user,
# ensuring the user has the necessary permissions to execute scripts and modify files within /app.
RUN chown ${APP_USER}:${APP_USER} /usr/local/bin/compile-scripts.sh && \
    chown -R ${APP_USER}:${APP_USER} /app

# Switch to non-root user for security
USER ${APP_USER}

# Set default command to run the compile script
ENTRYPOINT [ "/usr/local/bin/compile-scripts.sh" ]
