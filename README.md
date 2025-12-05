# Home Server Setup with Podman Quadlets

A test-driven, production-ready home server setup using Podman Quadlets for running:
- Home Assistant (smart home hub)
- Frigate NVR (camera management with AI)
- Zigbee2MQTT (Zigbee device control)
- Mosquitto (MQTT broker)
- Nginx Proxy Manager (reverse proxy)
- AdGuard Home (network-wide ad blocking)

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Nginx Proxy Manager                   │
│                    (Port 80, 443, 8181)                  │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┼────────────┬──────────────┐
        │            │            │              │
┌───────▼──────┐ ┌──▼────────┐ ┌─▼──────────┐ ┌─▼────────────┐
│     Home     │ │  Frigate  │ │  AdGuard   │ │  Zigbee2MQTT │
│  Assistant   │ │   NVR     │ │    Home    │ │              │
│  (8123)      │ │  (5000)   │ │  (3000)    │ │   (8080)     │
└──────┬───────┘ └─────┬─────┘ └────────────┘ └──────┬───────┘
       │               │                              │
       └───────────────┴──────────────────────────────┘
                       │
                ┌──────▼───────┐
                │   Mosquitto  │
                │  MQTT Broker │
                │   (1883)     │
                └──────────────┘
```

## Prerequisites

### Hardware
- Linux server (Fedora/RHEL/Ubuntu recommended)
- 16GB+ RAM (32GB recommended)
- 256GB+ storage for OS and containers
- Additional storage for camera footage (4TB+ recommended)
- USB Zigbee coordinator (Sonoff Zigbee 3.0 USB Dongle Plus)
- PoE switch for IP cameras
- IP cameras with RTSP support (Reolink recommended)

### Software
- Podman 4.4+ with quadlet support
- Python 3.11+
- systemd

## Quick Start

1. **Clone and setup**:
```bash
git clone ssh://git@gitlab.cee.redhat.com/nesmith/homeserver.git
cd homeserver
make setup
```

2. **Run tests**:
```bash
make test
```

3. **Deploy services**:
```bash
make deploy
```

4. **Check status**:
```bash
make status
```

## Project Structure

```
.
├── quadlets/              # Podman quadlet definitions
│   ├── homeassistant.container
│   ├── frigate.container
│   ├── mosquitto.container
│   ├── zigbee2mqtt.container
│   ├── nginx-proxy.container
│   ├── adguard.container
│   └── networks/          # Network definitions
├── configs/               # Service configurations
│   ├── homeassistant/
│   ├── frigate/
│   ├── mosquitto/
│   ├── zigbee2mqtt/
│   ├── nginx-proxy/
│   └── adguard/
├── tests/                 # Test suite
│   ├── unit/             # Unit tests
│   ├── integration/      # Integration tests
│   └── e2e/              # End-to-end tests
├── scripts/              # Deployment and management scripts
├── docs/                 # Documentation
└── Makefile              # Common operations
```

## Testing

This project follows Test-Driven Development (TDD):

```bash
# Run all tests
make test

# Run specific test suites
make test-unit
make test-integration
make test-e2e

# Run tests with coverage
make test-coverage
```

## Services

### Home Assistant (Port 8123)
Smart home control center for all devices and automations.

### Frigate NVR (Port 5000)
AI-powered network video recorder with object detection.

### Mosquitto (Port 1883)
MQTT message broker for device communication.

### Zigbee2MQTT (Port 8080)
Bridges Zigbee devices to MQTT for Home Assistant.

### Nginx Proxy Manager (Ports 80, 443, 8181)
Reverse proxy with SSL certificate management.

### AdGuard Home (Port 3000)
Network-wide ad blocking and DNS management.

## Management Commands

```bash
# Deploy all services
make deploy

# Stop all services
make stop

# Restart services
make restart

# View logs
make logs SERVICE=homeassistant

# Backup data
make backup

# Restore from backup
make restore BACKUP_FILE=backup-2025-11-25.tar.gz

# Update containers
make update
```

## Configuration

All service configurations are stored in `configs/` and mounted as volumes.

## Security

- Services run in rootless Podman containers
- Network isolation between services
- Secrets managed via Podman secrets
- Regular security updates via automated tests

## Backup Strategy

- Automated daily backups of all configs
- Camera footage retention: 7 days
- Backup destination: `/mnt/backup/homeserver/`

## Monitoring

- Service health checks via systemd
- Uptime monitoring via Home Assistant
- Log aggregation and rotation

## License

MIT

## Support

For issues and questions, see the docs/ directory.


