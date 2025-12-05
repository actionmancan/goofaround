#!/usr/bin/env bash
set -euo pipefail

# Stop all home server services

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_info "Stopping home server services..."

# Stop services in reverse order
SERVICES=(
    "homeserver-adguard"
    "homeserver-nginx-proxy"
    "homeserver-frigate"
    "homeserver-homeassistant"
    "homeserver-zigbee2mqtt"
    "homeserver-mosquitto"
    "homeserver-network"
)

for service in "${SERVICES[@]}"; do
    log_info "  Stopping $service..."
    systemctl --user stop "$service.service" 2>/dev/null || true
done

log_info "All services stopped."


