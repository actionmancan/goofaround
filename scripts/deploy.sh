#!/usr/bin/env bash
set -euo pipefail

# Deploy Podman Quadlets for Home Server
# This script copies quadlet files to systemd user directory and enables services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
QUADLET_SOURCE="$PROJECT_ROOT/quadlets"
QUADLET_DEST="$HOME/.config/containers/systemd"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Podman is installed
if ! command -v podman &> /dev/null; then
    log_error "Podman is not installed. Please install Podman first."
    exit 1
fi

# Check Podman version
PODMAN_VERSION=$(podman --version | awk '{print $3}')
log_info "Podman version: $PODMAN_VERSION"

# Create quadlet destination directory if it doesn't exist
log_info "Creating quadlet directory: $QUADLET_DEST"
mkdir -p "$QUADLET_DEST"

# Copy quadlet files
log_info "Copying quadlet files..."
for quadlet_file in "$QUADLET_SOURCE"/*.{network,container,volume}; do
    if [ -f "$quadlet_file" ]; then
        filename=$(basename "$quadlet_file")
        log_info "  Copying $filename"
        cp "$quadlet_file" "$QUADLET_DEST/"
    fi
done

# Reload systemd user daemon
log_info "Reloading systemd daemon..."
systemctl --user daemon-reload

# Enable and start network first
log_info "Enabling homeserver network..."
systemctl --user enable homeserver-network.service
systemctl --user start homeserver-network.service

# Wait for network to be ready
sleep 2

# Enable and start services in order
log_info "Enabling and starting services..."

# Start Mosquitto first (required by others)
log_info "  Starting mosquitto..."
systemctl --user enable homeserver-mosquitto.service
systemctl --user start homeserver-mosquitto.service

# Wait for Mosquitto to be ready
sleep 5

# Start services that depend on Mosquitto
log_info "  Starting zigbee2mqtt..."
systemctl --user enable homeserver-zigbee2mqtt.service
systemctl --user start homeserver-zigbee2mqtt.service || log_warn "zigbee2mqtt may fail without USB device"

log_info "  Starting homeassistant..."
systemctl --user enable homeserver-homeassistant.service
systemctl --user start homeserver-homeassistant.service

log_info "  Starting frigate..."
systemctl --user enable homeserver-frigate.service
systemctl --user start homeserver-frigate.service

# Start independent services
log_info "  Starting nginx-proxy..."
systemctl --user enable homeserver-nginx-proxy.service
systemctl --user start homeserver-nginx-proxy.service

log_info "  Starting adguard..."
systemctl --user enable homeserver-adguard.service
systemctl --user start homeserver-adguard.service

# Enable lingering so services start on boot
log_info "Enabling lingering for user..."
loginctl enable-linger "$USER"

# Show status
log_info "\n=== Service Status ==="
systemctl --user list-units 'homeserver-*' --all

log_info "\n=== Deployment Complete ==="
log_info "Services are starting up. Use 'make status' to check their status."
log_info "\nService URLs:"
log_info "  Home Assistant:       http://localhost:8123"
log_info "  Frigate NVR:          http://localhost:5000"
log_info "  Zigbee2MQTT:          http://localhost:8080"
log_info "  Nginx Proxy Manager:  http://localhost:8181"
log_info "  AdGuard Home:         http://localhost:3000"
log_info "\nDefault credentials (change on first login):"
log_info "  Nginx Proxy Manager:  admin@example.com / changeme"
log_info "  AdGuard Home:         Configure on first access"


