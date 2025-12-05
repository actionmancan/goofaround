#!/usr/bin/env bash
set -euo pipefail

# Update all container images

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_info "Updating container images..."

# List of images to update
IMAGES=(
    "docker.io/eclipse-mosquitto:latest"
    "docker.io/koenkk/zigbee2mqtt:latest"
    "ghcr.io/home-assistant/home-assistant:stable"
    "ghcr.io/blakeblackshear/frigate:stable"
    "docker.io/jc21/nginx-proxy-manager:latest"
    "docker.io/adguard/adguardhome:latest"
)

for image in "${IMAGES[@]}"; do
    log_info "  Updating $image..."
    podman pull "$image" || log_warn "Failed to pull $image"
done

log_info "Restarting services to use new images..."
systemctl --user restart 'homeserver-*'

log_info "Update complete!"


