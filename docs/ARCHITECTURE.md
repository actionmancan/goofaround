# Home Server Architecture

Complete technical architecture of the home server system.

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Host System (Linux)                      │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    systemd (User Mode)                      │ │
│  │                                                              │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │ │
│  │  │  Podman      │  │  Podman      │  │  Podman      │    │ │
│  │  │  Network     │  │  Volumes     │  │  Secrets     │    │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │ │
│  │                                                              │ │
│  │  ┌────────────────────────────────────────────────────┐   │ │
│  │  │         homeserver Network (172.20.0.0/16)         │   │ │
│  │  │                                                       │   │ │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐│   │ │
│  │  │  │Mosquitto │ │ Home     │ │ Frigate  │ │Zigbee  ││   │ │
│  │  │  │  MQTT    │ │Assistant │ │   NVR    │ │2MQTT   ││   │ │
│  │  │  └────┬─────┘ └────┬─────┘ └────┬─────┘ └───┬────┘│   │ │
│  │  │       │            │            │            │      │   │ │
│  │  │       └────────────┴────────────┴────────────┘      │   │ │
│  │  │                                                       │   │ │
│  │  │  ┌──────────┐ ┌──────────┐                         │   │ │
│  │  │  │  Nginx   │ │ AdGuard  │                         │   │ │
│  │  │  │  Proxy   │ │   Home   │                         │   │ │
│  │  │  └──────────┘ └──────────┘                         │   │ │
│  │  └────────────────────────────────────────────────────┘   │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │   USB        │  │   Network    │  │   Storage    │        │
│  │ (Zigbee)     │  │  (PoE Cams)  │  │   (Footage)  │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

## Service Layers

### Layer 1: Infrastructure Services
**Purpose**: Core services that others depend on

1. **Network** (`homeserver-network`)
   - Podman bridge network
   - Subnet: 172.20.0.0/16
   - DNS resolution between containers
   - Isolated from host network

2. **Mosquitto MQTT Broker** (`homeserver-mosquitto`)
   - Port: 1883 (MQTT)
   - Purpose: Message bus for all IoT devices
   - Used by: Home Assistant, Frigate, Zigbee2MQTT

### Layer 2: Integration Services
**Purpose**: Bridge between hardware and automation

3. **Zigbee2MQTT** (`homeserver-zigbee2mqtt`)
   - Port: 8080 (Web UI)
   - Requires: USB Zigbee coordinator
   - Bridges Zigbee devices to MQTT
   - Manages device pairing

4. **Frigate NVR** (`homeserver-frigate`)
   - Port: 5000 (Web UI)
   - Port: 8554 (RTSP)
   - AI object detection
   - Records camera footage
   - Publishes events to MQTT

### Layer 3: Control Services
**Purpose**: User interface and automation

5. **Home Assistant** (`homeserver-homeassistant`)
   - Port: 8123 (Web UI)
   - Central control hub
   - Automation engine
   - Consumes MQTT topics
   - Device management

### Layer 4: Support Services
**Purpose**: Infrastructure support

6. **Nginx Proxy Manager** (`homeserver-nginx-proxy`)
   - Port: 80 (HTTP)
   - Port: 443 (HTTPS)
   - Port: 8181 (Admin UI)
   - Reverse proxy for all services
   - SSL certificate management

7. **AdGuard Home** (`homeserver-adguard`)
   - Port: 53 (DNS)
   - Port: 3000 (Web UI)
   - Network-wide ad blocking
   - DNS server
   - HTTPS/DoT support

## Data Flow

### Zigbee Device Control
```
User → Home Assistant → MQTT → Zigbee2MQTT → USB Coordinator → Zigbee Device
                                                                      ↓
Device State ← Home Assistant ← MQTT ← Zigbee2MQTT ← USB Coordinator ←
```

### Camera to Notification
```
IP Camera → Frigate → AI Detection → MQTT Event → Home Assistant → Notification
     ↓
  Storage ← Recording
```

### Network Request Flow
```
Internet → Nginx Proxy → SSL Termination → Backend Service → Response
                 ↓
            AdGuard DNS filtering
```

## Storage Architecture

### Configuration Storage
```
~/Documents/GitHub/goofaround/configs/
├── mosquitto/
│   └── mosquitto.conf
├── zigbee2mqtt/
│   ├── configuration.yaml
│   ├── devices.yaml
│   └── groups.yaml
├── homeassistant/
│   ├── configuration.yaml
│   ├── automations.yaml
│   └── ...
├── frigate/
│   └── config.yml
├── nginx-proxy/
│   └── (auto-generated)
└── adguard/
    └── (auto-generated)
```

### Runtime Data
```
~/Documents/GitHub/goofaround/data/
├── mosquitto/
│   ├── data/
│   └── log/
├── homeassistant/
│   └── (database, logs)
├── frigate/
│   └── (cache)
├── media/
│   └── frigate/
│       ├── recordings/
│       ├── snapshots/
│       └── frigate.db
├── nginx-proxy/
│   └── letsencrypt/
└── adguard/
    ├── work/
    └── conf/
```

## Network Architecture

### Internal Network
- **Name**: homeserver
- **Subnet**: 172.20.0.0/16
- **Gateway**: 172.20.0.1
- **DNS**: Internal container DNS

### Port Mapping
```
Host Port  →  Container  →  Service
─────────────────────────────────────
53         →  adguard    →  DNS
80         →  nginx      →  HTTP
443        →  nginx      →  HTTPS
1883       →  mosquitto  →  MQTT
3000       →  adguard    →  Web UI
5000       →  frigate    →  Web UI
8080       →  zigbee2mqtt→  Web UI
8123       →  homeassist →  Web UI
8181       →  nginx      →  Admin UI
8554       →  frigate    →  RTSP
```

### External Network
- IP cameras connect via PoE switch
- Zigbee devices via USB coordinator
- Client devices access via published ports

## Security Architecture

### Container Security
1. **Rootless Podman**
   - All containers run as user
   - No root privileges required

2. **SELinux Labels**
   - Volume mounts use `:Z` labels
   - Container isolation enforced

3. **Network Isolation**
   - Containers on private network
   - Only specified ports published

4. **Read-only Containers**
   - Where applicable
   - Mutable data in volumes

### Access Control
1. **Service Authentication**
   - Home Assistant: User accounts
   - Nginx Proxy: Admin login
   - AdGuard: Admin login
   - Zigbee2MQTT: Optional auth

2. **MQTT Security**
   - Can enable authentication
   - Network-level isolation
   - TLS optional

3. **Network Security**
   - Firewall rules
   - Private network subnet
   - Reverse proxy for external access

## High Availability

### Restart Policies
All services configured with `Restart=always`

### Health Checks
- Periodic checks via systemd
- Auto-restart on failure
- Configurable retry counts

### Data Persistence
- Volumes for all data
- Survive container restarts
- Independent of container lifecycle

## Backup Strategy

### What's Backed Up
1. **Configurations**
   - All YAML files
   - Service configs
   - Automation rules

2. **Data**
   - MQTT persistence
   - Home Assistant database
   - Frigate database
   - Zigbee device pairings

3. **Recordings** (optional)
   - Camera footage
   - Snapshots

### Backup Process
```bash
make backup
```
Creates timestamped tarball of configs and data.

### Restore Process
```bash
make restore BACKUP_FILE=backups/backup-file.tar.gz
```

## Resource Requirements

### Minimum
- CPU: 4 cores
- RAM: 16GB
- Storage: 256GB (OS + containers)
- Additional: 4TB (camera footage)

### Recommended
- CPU: 6+ cores
- RAM: 32GB
- Storage: 512GB NVMe (OS + containers)
- Additional: 6-8TB (camera footage)
- Optional: Google Coral TPU

### Resource Allocation
```
Service          CPU    RAM     Storage
────────────────────────────────────────
Mosquitto        0.5    512MB   1GB
Zigbee2MQTT      0.5    512MB   1GB
Home Assistant   2.0    2GB     10GB
Frigate          2.0    4GB     Variable
Nginx Proxy      0.5    512MB   1GB
AdGuard          0.5    1GB     2GB
────────────────────────────────────────
Total           ~6.0    ~9GB    Variable
```

## Scaling Considerations

### Horizontal Scaling
Not applicable - single-node architecture

### Vertical Scaling
- Add RAM for more cameras
- Add storage for longer retention
- Add Coral TPU for better detection

### Service Optimization
1. **Frigate**
   - Limit detection FPS
   - Use hardware acceleration
   - Configure retention policies

2. **Home Assistant**
   - Disable unused integrations
   - Use efficient automations
   - Regular database maintenance

3. **Mosquitto**
   - Configure persistence carefully
   - Set retention policies
   - Monitor message rates

## Monitoring

### systemd Integration
```bash
systemctl --user status homeserver-*
journalctl --user -u homeserver-*
```

### Service Health
- Built-in health checks
- Automatic restarts
- Status via systemd

### Resource Monitoring
```bash
podman stats
```

## Disaster Recovery

### Service Failure
- Automatic restart via systemd
- Health check triggers restart
- Manual restart: `make restart SERVICE=name`

### Data Corruption
- Restore from backup
- Check service logs
- Validate configurations

### Hardware Failure
- Restore to new hardware
- Run `make restore`
- Reconfigure USB devices
- Update camera IPs if needed

## Future Expansion

### Additional Services
- Jellyfin (media server)
- Portainer (container UI)
- Uptime Kuma (monitoring)
- Grafana/Prometheus (metrics)

### Hardware Additions
- Additional cameras
- More Zigbee devices
- Z-Wave coordinator
- Coral TPU

### Software Integrations
- Voice assistants
- Weather data
- Energy monitoring
- Presence detection


