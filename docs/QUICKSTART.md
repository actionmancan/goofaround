# Quick Start Guide

Get your home server up and running in minutes!

## Prerequisites

### Required Software
- Linux system (Fedora/RHEL/Ubuntu)
- Podman 4.4 or later
- Python 3.11 or later
- systemd

### Required Hardware
- Server with 16GB+ RAM
- 256GB+ storage for OS
- Additional storage for camera footage (4TB+ recommended)
- USB Zigbee coordinator (if using Zigbee devices)
- IP cameras with RTSP support (if using cameras)

## Installation Steps

### 1. Install Podman

**Fedora/RHEL:**
```bash
sudo dnf install -y podman
```

**Ubuntu:**
```bash
sudo apt update
sudo apt install -y podman
```

### 2. Clone Repository

```bash
cd ~/Documents/GitHub
git clone ssh://git@gitlab.cee.redhat.com/nesmith/homeserver.git goofaround
cd goofaround
```

### 3. Setup Project

```bash
make setup
```

This will:
- Create Python virtual environment
- Install development dependencies
- Create config directories
- Create data directories

### 4. Initialize Configurations

```bash
make init-configs
```

This creates default configuration files for all services.

### 5. Configure Your Setup

#### Zigbee USB Device
Find your Zigbee coordinator device:

```bash
ls -l /dev/serial/by-id/
```

Update `quadlets/homeserver-zigbee2mqtt.container` with the correct device path.

#### IP Cameras
Edit `configs/frigate/config.yml` to add your cameras:

```yaml
cameras:
  front_door:
    enabled: true
    ffmpeg:
      inputs:
        - path: rtsp://admin:password@192.168.1.100:554/stream
          roles: ["detect", "record"]
    detect:
      width: 1920
      height: 1080
      fps: 5
```

### 6. Run Tests

```bash
make test
```

Ensure all tests pass before deployment.

### 7. Deploy Services

```bash
make deploy
```

This will:
- Copy quadlet files to systemd
- Enable all services
- Start services in correct order
- Enable user lingering for auto-start on boot

### 8. Check Status

```bash
make status
```

### 9. Access Services

Open your browser and navigate to:

- **Home Assistant**: http://localhost:8123
- **Frigate NVR**: http://localhost:5000
- **Zigbee2MQTT**: http://localhost:8080
- **Nginx Proxy Manager**: http://localhost:8181
  - Default: admin@example.com / changeme
- **AdGuard Home**: http://localhost:3000

## Post-Installation

### 1. Configure Home Assistant

1. Go to http://localhost:8123
2. Create your admin account
3. Follow the onboarding wizard
4. MQTT integration should auto-discover

### 2. Configure Zigbee2MQTT

1. Go to http://localhost:8080
2. Set permit_join to allow pairing
3. Add your Zigbee devices

### 3. Configure Frigate

1. Go to http://localhost:5000
2. Verify cameras are working
3. Configure detection zones if needed

### 4. Configure AdGuard Home

1. Go to http://localhost:3000
2. Complete initial setup
3. Configure as your DNS server

### 5. Configure Nginx Proxy Manager

1. Go to http://localhost:8181
2. Login with default credentials
3. Change password immediately
4. Add proxy hosts for your services

## Common Commands

```bash
# View logs for a service
make logs SERVICE=homeassistant

# Restart a service
make restart SERVICE=mosquitto

# Restart all services
make restart

# Stop all services
make stop

# Create backup
make backup

# Restore from backup
make restore BACKUP_FILE=backups/homeserver-backup-20251125_120000.tar.gz

# Update container images
make update
```

## Troubleshooting

### Service won't start

Check logs:
```bash
journalctl --user -u homeserver-servicename -n 50
```

### Permission denied on USB device

Add your user to dialout group:
```bash
sudo usermod -aG dialout $USER
# Logout and login again
```

### Cannot access services

Check firewall:
```bash
# Fedora/RHEL
sudo firewall-cmd --add-port=8123/tcp --permanent
sudo firewall-cmd --reload

# Ubuntu
sudo ufw allow 8123/tcp
```

### Services not starting on boot

Ensure lingering is enabled:
```bash
loginctl enable-linger $USER
```

## Next Steps

- [Hardware Setup Guide](HARDWARE.md)
- [Network Configuration](NETWORK.md)
- [Adding Devices](DEVICES.md)
- [Automation Examples](AUTOMATIONS.md)


