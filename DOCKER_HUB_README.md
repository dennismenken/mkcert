# mkcert-enhanced - Enhanced Local Development Certificates

A streamlined Docker image of mkcert with **enhanced support for local domains** commonly used in homelab and development environments.

## 🚀 Key Features

- **✅ Enhanced Local Domain Support**: Seamlessly works with `.home`, `.local`, `.lab`, `.homelab`, `.dev`, `.test`, `.internal`, `.corp`, `.private`, `.lan`, `.intra` domains
- **✅ Automatic CA Installation**: Installs the local CA automatically on container startup
- **✅ Environment Variable Support**: Configure domains via comma-separated `DOMAINS` environment variable
- **✅ Automatic Permission Handling**: Run as root (`user: "0:0"`) for seamless volume mounting
- **✅ Persistent CA Storage**: Uses Docker volumes to persist your CA across container runs
- **✅ Minimal Size**: Only 22.9MB - highly optimized multi-stage build
- **✅ Homelab Ready**: Perfect for local network services and development environments

## 🏠 Perfect for Homelabs

This enhanced version specifically addresses the limitations of the original mkcert when working with local domains like:
- `jellyfin.homelab.home`
- `*.lab.local` 
- `grafana.internal`
- `plex.home`

## 🔧 Quick Start

### Using Environment Variables (Recommended)
```bash
# Generate certificates for multiple domains
docker run --rm --user "0:0" \
  -e DOMAINS=homelab.home,*.homelab.home,jellyfin.homelab.home \
  -v ca-data:/home/mkcert/.local/share/mkcert \
  -v $(pwd)/certs:/certs -w /certs \
  dennismenken/mkcert-enhanced:latest
```

### Using Command Line Arguments
```bash
# Traditional mkcert usage
docker run --rm --user "0:0" \
  -v ca-data:/home/mkcert/.local/share/mkcert \
  -v $(pwd)/certs:/certs -w /certs \
  dennismenken/mkcert-enhanced:latest \
  homelab.home "*.homelab.home"
```

### Docker Compose (Recommended)
```yaml
services:
  mkcert:
    image: dennismenken/mkcert-enhanced:latest
    user: "0:0"  # Run as root for automatic permission handling
    environment:
      - DOMAINS=homelab.home,*.homelab.home
    volumes:
      - ca-data:/home/mkcert/.local/share/mkcert
      - ./certs:/certs
    working_dir: /certs

volumes:
  ca-data:
```

## 📁 Output

Generated certificates will be available in your mounted volume:
- `domain.pem` - Certificate file
- `domain-key.pem` - Private key file
- Root CA automatically installed in container

## 🌐 Supported Local Domains

The enhanced validation automatically recognizes these local TLD patterns:
- `.home` - Home networks
- `.local` - Standard local domains  
- `.lab` / `.homelab` - Homelab setups
- `.dev` / `.test` - Development/testing
- `.internal` / `.corp` / `.private` - Corporate/internal
- `.lan` / `.intra` - Local area networks

## 💾 Persistent CA Storage

Use Docker volumes to maintain your CA across container runs:
```bash
# Create named volume for CA persistence
docker volume create ca-data

# All subsequent runs will reuse the same CA
docker run --rm -e DOMAINS=test.home -v ca-data:/home/mkcert/.local/share/mkcert ...
```

## 🛠️ Advanced Usage

### Custom Certificate Paths
```bash
docker run --rm --user "0:0" \
  -e DOMAINS=homelab.home \
  -v ca-data:/home/mkcert/.local/share/mkcert \
  -v $(pwd)/certs:/certs -w /certs \
  dennismenken/mkcert-enhanced:latest \
  -cert-file custom.crt -key-file custom.key homelab.home
```

### Client Certificates
```bash
docker run --rm --user "0:0" \
  -v ca-data:/home/mkcert/.local/share/mkcert \
  -v $(pwd)/certs:/certs -w /certs \
  dennismenken/mkcert-enhanced:latest \
  -client client.homelab.home
```

### Why `user: "0:0"`?
The image includes intelligent permission handling:
1. **Starts as root** to fix volume permissions automatically
2. **Switches to non-root user** (`mkcert`) for security during certificate generation
3. **No manual permission setup** required on the host system

## 🏗️ Technical Details

- **Base Image**: Alpine Linux (edge)
- **Go Version**: 1.21+
- **Build Method**: Multi-stage optimized build
- **Security**: Intelligent permission handling - starts as root, switches to non-root
- **Architecture**: linux/amd64 + linux/arm64 (multi-architecture support)

## 📖 Source Code

Source code and documentation available at: [GitHub Repository](https://github.com/dennismenken/mkcert)

## 🤝 Contributing

Issues and pull requests welcome! This enhanced version maintains full compatibility with the original mkcert while adding better support for local development domains.

---

**Note**: This image is perfect for development and homelab environments. For production use, consider proper certificate management solutions. 