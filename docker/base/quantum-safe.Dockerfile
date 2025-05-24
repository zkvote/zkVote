# Build stage
FROM node:22-alpine

# Install quantum-safe cryptography libraries:
# - liboqs-dev: Open Quantum Safe library for post-quantum cryptography algorithms.
# - libpqcrypto: Library providing post-quantum cryptographic primitives.
# Both are installed without cache to reduce image size.
RUN apk add --no-cache \
    liboqs-dev \
    libpqcrypto

# Install PQC tools
RUN npm install -g @zkvote/pqc-tools

# Install OpenSSL and its development libraries to provide cryptographic functions
# and enable building or running applications that depend on OpenSSL.
RUN apk add --no-cache \
    openssl \
    openssl-dev

# Set the environment variable to specify an additional CA certificate for Node.js to trust,
# enabling secure TLS connections using a custom quantum-safe certificate.
# Configure Node.js to use a specific quantum-safe TLS cipher suite (KEMTLS with Kyber768 and Dilithium3)
# for enhanced security against quantum attacks.
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/quantum-ca.crt
ENV NODE_OPTIONS="--tls-cipher-list=TLS_KEMTLS_KYBER768_WITH_DILITHIUM3"

# Create a new group 'appuser' with GID 1000, add a user 'appuser' with UID 1000 to this group,
# set the default shell to /bin/sh, and create the user without a password.
# Then, create the /app directory and set its ownership to 'appuser:appuser'.
RUN addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -s /bin/sh -D appuser && \
    mkdir -p /app && \
    chown -R appuser:appuser /app

# Set the working directory
WORKDIR /app

# Use the non-root user
USER appuser
