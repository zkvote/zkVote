# Build stage for rust backend
FROM rust:1.86-slim AS builder

# Set the working directory
WORKDIR /usr/src/zkvote_backend

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy Cargo.toml and Cargo.lock to leverage Docker cache for dependencies
COPY Cargo.toml ./Cargo.toml
COPY ../Cargo.lock ./Cargo.lock

# Create a placeholder Rust main.rs file to allow building dependencies before copying the actual source code.
# This enables Docker to cache dependency layers, speeding up subsequent builds when only application code changes.
# Build the Rust project dependencies in release mode with a locked Cargo.lock file for reproducibility.
# Copy the actual source code into the image.
# Touch main.rs to ensure it exists, then rebuild the project with the real source code.
RUN mkdir src && echo "fn main() { println!(\"Building dependencies... \"); }" > src/main.rs
# Build dependencies
RUN cargo build --release --locked

# Copy the source code
COPY src ./src

# Create an empty Rust source file to ensure the build command succeeds even if src/main.rs does not exist,
# then build the project in release mode with Cargo, using the Cargo.lock file to ensure reproducible builds.
RUN touch src/main.rs && cargo build --release --locked

# Production build stage - final slim image
FROM debian:bullseye-slim AS production

# Define build-time variables for the application user and group.
# These arguments can be overridden at build time to customize the user and group
# under which the application will run inside the container.
ARG APP_USER=appuser
ARG APP_GROUP=appgroup

# Create a new group with the name specified by the APP_GROUP environment variable,
# then create a new user with the name specified by the APP_USER environment variable,
# assign the user to the newly created group, and set the user's shell to /sbin/nologin
# to prevent direct login access.
RUN groupadd -r ${APP_GROUP} && useradd -r -g ${APP_GROUP} -s /sbin/nologin ${APP_USER}

# Set the working directory
WORKDIR /app

# Copies the compiled zkvote_backend_server binary from the builder stage to the current image.
# Assumes the binary was built in /usr/src/zkvote_backend/target/release/ during the builder stage.
COPY --from=builder /usr/src/zkvote_backend/target/release/zkvote_backend_server .

# Optionally, copy other necessary assets like .env.production.example or static files
# COPY .env.production.example .env.example

# Example: Copy circuit verification keys if needed by the backend at runtime.
# These paths are relative to the Dockerfile's build context (backend/) when COPYing from host.
# COPY --chown=${APP_USER}:${APP_GROUP} ../circuits/build/vote_casting_verification_key.json ./assets/circuits/

# Ensure the binary is executable
RUN chmod +x ./zkvote_backend_server

# Switches the current user to the value specified by the APP_USER build argument or environment variable.
# This is typically done for security reasons, to avoid running the application as the root user.
USER ${APP_USER}

# Exposes port 3000 on the container to allow external access to the application.
EXPOSE 3000

CMD [ "./zkvote_backend_server" ]
