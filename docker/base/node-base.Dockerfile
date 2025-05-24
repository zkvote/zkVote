# Build stage
FROM node:22-alpine

# Install essential utilities:
# - curl: for transferring data with URLs
# - jq: for processing JSON data
# - bash: for running Bash scripts
# Uses --no-cache to avoid caching index and reduce image size
RUN apk add --no-cache \
    curl \
    jq \
    bash

# Create a new group 'appuser' with GID 1000,
# add a new user 'appuser' with UID 1000 to this group,
# set the default shell to /bin/sh, and do not create a home directory.
# Then, create the /app directory and set its ownership to 'appuser:appuser'.
RUN addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -s /bin/sh -D appuser && \
    mkdir -p /app && \
    chown -R appuser:appuser /app

# Add post-quantum cryptography support
RUN apk add --no-cache liboqs-dev

# Set the working directory
WORKDIR /app

# Use non-root user
USER appuser

# This HEALTHCHECK instruction periodically checks the health of the container by sending an HTTP request
# to the /health endpoint on localhost using the specified PORT environment variable (defaulting to 3000 if not set).
# The check runs every 30 seconds, times out after 5 seconds, and starts 5 seconds after the container starts.
# If the health check fails 3 consecutive times, the container is considered unhealthy.
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
CMD curl -f https://localhost:${PORT:-3000}/health || exit 1
