# Alternative Dockerfile using go get method
# This uses the older GOPATH-based approach

FROM golang:1.21-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    git \
    ca-certificates \
    tzdata

# Set GOPATH and create directory structure
ENV GOPATH=/go
RUN mkdir -p /go/src/github.com/dennismenken

# Copy all source files
COPY . /build/

# Build from local source and prepare entrypoint
RUN cd /build && \
    go mod download && \
    go build -ldflags="-w -s -X main.Version=enhanced-$(date +%Y%m%d)" \
    -o /bin/mkcert . && \
    chmod +x entrypoint.sh

# Runtime stage - same as main Dockerfile
FROM alpine:edge

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    nss-tools \
    tzdata \
    su-exec \
    && update-ca-certificates

# Create non-root user for security
RUN addgroup -g 1001 -S mkcert && \
    adduser -u 1001 -S mkcert -G mkcert

# Copy the binary from builder stage
COPY --from=builder /bin/mkcert /usr/local/bin/mkcert

# Make binary executable
RUN chmod +x /usr/local/bin/mkcert

# Create directory for CA files with proper permissions
RUN mkdir -p /home/mkcert/.local/share/mkcert && \
    chown -R mkcert:mkcert /home/mkcert

# Switch to non-root user
USER mkcert

# Set working directory
WORKDIR /home/mkcert

# Set environment variables
ENV CAROOT=/home/mkcert/.local/share/mkcert
ENV PATH=/usr/local/bin:$PATH

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD mkcert -version || exit 1

# Copy entrypoint (already executable from builder stage)
COPY --from=builder /build/entrypoint.sh /usr/local/bin/entrypoint.sh

# Default command with entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Labels for metadata
LABEL maintainer="Enhanced mkcert for local development" \
      description="mkcert with enhanced support for local domains (built with go get)" \
      version="enhanced-goget-1.0" \
      build-method="go-get" \
      org.opencontainers.image.title="mkcert-enhanced-goget" \
      org.opencontainers.image.description="Enhanced mkcert built with go get method" \
      org.opencontainers.image.vendor="Community Enhanced" \
      org.opencontainers.image.source="https://github.com/dennismenken/mkcert" 