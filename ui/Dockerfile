# Build stage
FROM node:22-alpine AS build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json and install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Post-quantum signature verification (optional)
ARG PQC_SIGNATURE_VERIFY=false
RUN if [ "$PQC_SIGNATURE_VERIFY" = "true" ]; then \
    npm install -g @zkvote/pqc-tools && \
    pqc-tools verify --algorithm dilithium5 -- input ./dist --key-id $PQC_KEY_ID; \
    fi

# Production stage build
FROM nginx:1.28-alpine AS production

# Copy the build output
COPY --from=build /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Add security headers
# This section appends several important security headers to the Nginx configuration:
# - X-Content-Type-Options: Prevents browsers from MIME-sniffing a response away from the declared content-type.
# - X-Frame-Options: Prevents the site from being framed to protect against clickjacking attacks.
# - X-XSS-Protection: Enables cross-site scripting (XSS) filter built into most browsers.
# - Content-Security-Policy: Restricts sources for content, scripts, and objects to mitigate XSS and data injection attacks.
# Finally, it includes the custom security headers configuration in the main Nginx config.
RUN echo "add_header X-Content-Type-Options nosniff always;" >> /etc/nginx/conf.d/security-headers.conf && \
    echo "add_header X-Frame-Options DENY;" >> /etc/nginx/conf.d/security-headers.conf && \
    echo "add_header X-XSS-Protection \"1; mode=block\";" >> /etc/nginx/conf.d/security-headers.conf && \
    echo "add_header Content-Security-Policy \"default-src 'self'; script-src 'self'; object-src 'none'\";" >> /etc/nginx/conf.d/security-headers.conf && \
    echo "include /etc/nginx/conf.d/security-headers.conf;" >> /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
