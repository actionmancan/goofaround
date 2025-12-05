#!/usr/bin/env bash
set -euo pipefail

# Restart home server services

SERVICE="${1:-all}"

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

if [ "$SERVICE" = "all" ]; then
    log_info "Restarting all services..."
    systemctl --user restart 'homeserver-*'
else
    log_info "Restarting homeserver-$SERVICE..."
    systemctl --user restart "homeserver-$SERVICE.service"
fi

log_info "Restart complete."


