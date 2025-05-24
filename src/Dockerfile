# Build stage
FROM node:22-alpine AS build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json and install dependencies
COPY package*.json ./
RUN npm ci

# Copy the source code
COPY . .

# Build the application
RUN npm run build

# Test stage
FROM build AS test

# Run tests
RUN npm run test

# Production stage
FROM node:22-alpine AS production

# Set NODE_ENV to production
ENV NODE_ENV=production

# Create a non-root user
RUN addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -s /bin/sh -D appuser

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json and install production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Install post-quantum crypto libraries
RUN apk add --no-cache liboqs-dev

# Copy built application from build stage
COPY --from=build /app/dist /app/dist
COPY --from=build /app/config ./config

# Post-quantum signature verification
ARG PQC_SIGNATURE_VERIFY=false
# If PQC_SIGNATURE_VERIFY is true, install pqc-tools and verify the signature
RUN if [ "$PQC_SIGNATURE_VERIFY" = "true" ]; then \
        npm install -g @zkvote/pqc-tools && \
        pqc-tools verify --algorithm dilithium5 --input ./dist --key-id $PQC_KEY_ID; \
    fi

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose the application port
EXPOSE 3000

# Run the application
CMD ["node", "dist/index.js"]
