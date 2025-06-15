#!/bin/sh
set -e

# Enhanced mkcert entrypoint with automatic CA install and domain support
# Supports comma-separated domains via DOMAINS environment variable

# Fix permissions for mounted volumes if running as root
if [ "$(id -u)" = "0" ]; then
    # Create certs directory if it doesn't exist
    mkdir -p /certs
    # Change ownership to mkcert user
    chown -R mkcert:mkcert /certs /home/mkcert/.local/share/mkcert 2>/dev/null || true
    # Switch to mkcert user
    exec su-exec mkcert "$0" "$@"
fi

# Colors for output (if terminal supports it)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if mkcert is available
if ! command -v mkcert >/dev/null 2>&1; then
    log_error "mkcert binary not found"
    exit 1
fi

# Install CA if not already installed
log_info "Checking CA installation..."
if ! mkcert -install 2>/dev/null; then
    log_warning "CA installation failed or already installed"
else
    log_success "CA installed successfully"
fi

# Handle domain arguments
if [ $# -gt 0 ]; then
    # Use command line arguments
    log_info "Using command line domains: $*"
    exec mkcert "$@"
elif [ -n "$DOMAINS" ]; then
    # Use environment variable (comma-separated)
    log_info "Using environment domains: $DOMAINS"
    # Convert comma-separated to space-separated
    domain_args=$(echo "$DOMAINS" | tr ',' ' ')
    exec mkcert $domain_args
else
    # No domains specified, show help
    log_info "No domains specified. Use DOMAINS environment variable or command line arguments."
    log_info "Examples:"
    log_info "  DOMAINS=homelab.home,*.homelab.home"
    log_info "  docker run ... mkcert test.home"
    echo
    exec mkcert --help
fi 