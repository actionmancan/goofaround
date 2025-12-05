# Podman Quadlets Guide

Understanding and working with Podman Quadlets in this project.

## What are Quadlets?

Podman Quadlets are systemd unit files that define containers, allowing systemd to manage container lifecycle. They're superior to docker-compose for system-level deployments.

## Advantages

### vs Docker Compose
- ✅ Native systemd integration
- ✅ Automatic restart on failure
- ✅ Start on boot via systemd
- ✅ Better logging via journald
- ✅ Resource limits via systemd
- ✅ Dependency management via systemd

### vs Raw Podman Commands
- ✅ Declarative configuration
- ✅ Survives system reboots
- ✅ Integrated with system management
- ✅ Version controllable

## Quadlet File Structure

### Network Quadlet (`.network`)

```ini
[Network]
NetworkName=homeserver
Driver=bridge
Subnet=172.20.0.0/16

[Install]
WantedBy=default.target
```

### Container Quadlet (`.container`)

```ini
[Unit]
Description=Service Description
After=dependency.service
Requires=dependency.service

[Container]
Image=docker.io/image:tag
ContainerName=service-name
Network=homeserver.network
PublishPort=8080:8080
Volume=/host/path:/container/path:Z
Environment=KEY=value

[Service]
Restart=always
TimeoutStartSec=900

[Install]
WantedBy=default.target
```

## File Locations

### Development
```
project/
└── quadlets/
    ├── homeserver-network.network
    ├── homeserver-mosquitto.container
    └── ...
```

### Deployed (User Mode)
```
~/.config/containers/systemd/
├── homeserver-network.network
├── homeserver-mosquitto.container
└── ...
```

### Deployed (System Mode)
```
/etc/containers/systemd/
```

## Service Names

Quadlet files become systemd services:

```
homeserver-mosquitto.container → homeserver-mosquitto.service
```

## Common Patterns

### Service Dependencies

```ini
[Unit]
Description=Service that depends on Mosquitto
After=homeserver-mosquitto.service
Requires=homeserver-mosquitto.service
```

**After**: Start after this service
**Requires**: Fail if dependency fails
**Wants**: Prefer dependency but don't fail

### Port Publishing

```ini
[Container]
# Single port
PublishPort=8123:8123

# Multiple ports (one per line)
PublishPort=80:80
PublishPort=443:443

# UDP
PublishPort=53:53/udp

# Host IP binding
PublishPort=127.0.0.1:8080:8080
```

### Volume Mounts

```ini
[Container]
# With SELinux label (Z = private, z = shared)
Volume=%h/data:/container/data:Z

# Read-only
Volume=/etc/localtime:/etc/localtime:ro

# Tmpfs
Tmpfs=/tmp:rw,noexec,nosuid
```

**%h** expands to $HOME

### Environment Variables

```ini
[Container]
Environment=TZ=America/New_York
Environment=DEBUG=true
EnvironmentFile=/path/to/env/file
```

### Health Checks

```ini
[Container]
HealthCmd=curl -f http://localhost:8080 || exit 1
HealthInterval=30s
HealthTimeout=10s
HealthRetries=3
HealthStartPeriod=60s
```

### Resource Limits

```ini
[Container]
# Shared memory
ShmSize=512mb

# CPU/Memory (via systemd)
[Service]
CPUQuota=50%
MemoryLimit=2G
```

### Security

```ini
[Container]
# Run as specific user
User=1000

# Add capabilities
AddCapability=NET_ADMIN

# Read-only root filesystem
ReadOnly=true

# SELinux
SecurityLabelDisable=false
```

## Management Commands

### Reload After Changes
```bash
systemctl --user daemon-reload
```

### Enable Service
```bash
systemctl --user enable homeserver-mosquitto.service
```

### Start Service
```bash
systemctl --user start homeserver-mosquitto.service
```

### Stop Service
```bash
systemctl --user stop homeserver-mosquitto.service
```

### Restart Service
```bash
systemctl --user restart homeserver-mosquitto.service
```

### Check Status
```bash
systemctl --user status homeserver-mosquitto.service
```

### View Logs
```bash
# Recent logs
journalctl --user -u homeserver-mosquitto.service

# Follow logs
journalctl --user -u homeserver-mosquitto.service -f

# Last 50 lines
journalctl --user -u homeserver-mosquitto.service -n 50
```

### List All Services
```bash
systemctl --user list-units 'homeserver-*'
```

## Auto-Start on Boot

### Enable User Lingering
```bash
loginctl enable-linger $USER
```

This allows user services to start without login.

### Verify Lingering
```bash
loginctl show-user $USER | grep Linger
```

## Debugging

### Service Won't Start
```bash
# Check status
systemctl --user status homeserver-mosquitto.service

# View full logs
journalctl --user -u homeserver-mosquitto.service -b

# Check quadlet file
cat ~/.config/containers/systemd/homeserver-mosquitto.container
```

### Container Running But Service Failed
```bash
# List containers
podman ps -a

# Check container logs
podman logs homeserver-mosquitto
```

### Dependency Issues
```bash
# View dependency tree
systemctl --user list-dependencies homeserver-homeassistant.service
```

## Advanced Features

### Secrets Management

```bash
# Create secret
echo "mypassword" | podman secret create mqtt_password -

# Use in quadlet
[Container]
Secret=mqtt_password
```

### Auto-Update

```ini
[Container]
AutoUpdate=registry
```

Enable auto-update timer:
```bash
systemctl --user enable --now podman-auto-update.timer
```

### Pod Support

```ini
# pod.pod
[Pod]
PodName=homeserver-pod
PublishPort=8080:8080

[Install]
WantedBy=default.target
```

```ini
# container.container
[Container]
Pod=homeserver-pod.pod
```

## Best Practices

### 1. Naming Convention
Use descriptive prefixes:
```
homeserver-servicename.container
```

### 2. Dependency Order
Start dependencies first:
```
network → database → services → proxies
```

### 3. Health Checks
Always include health checks:
```ini
HealthCmd=service-specific-check || exit 1
```

### 4. Volume Permissions
Use SELinux labels:
```ini
Volume=/path:/path:Z
```

### 5. Restart Policies
Always set restart policy:
```ini
[Service]
Restart=always
```

### 6. Logging
Use structured logging:
```ini
[Service]
StandardOutput=journal
StandardError=journal
```

### 7. Timeouts
Set appropriate timeouts:
```ini
[Service]
TimeoutStartSec=900
TimeoutStopSec=30
```

## Troubleshooting

### Permission Denied
```bash
# Check SELinux
ls -Z /path/to/volume

# Relabel if needed
chcon -Rt container_file_t /path/to/volume
```

### Port Already in Use
```bash
# Check what's using the port
sudo ss -tlnp | grep :8123
```

### Service Fails to Start
```bash
# Validate quadlet syntax
systemd-analyze verify ~/.config/containers/systemd/homeserver-service.container

# Check for typos
cat ~/.config/containers/systemd/homeserver-service.container
```

## Migration from Docker Compose

### Compose Service
```yaml
services:
  mosquitto:
    image: eclipse-mosquitto:latest
    ports:
      - "1883:1883"
    volumes:
      - ./config:/mosquitto/config
```

### Equivalent Quadlet
```ini
[Unit]
Description=Mosquitto MQTT Broker

[Container]
Image=docker.io/eclipse-mosquitto:latest
PublishPort=1883:1883
Volume=%h/config:/mosquitto/config:Z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

## Resources

- [Podman Quadlet Documentation](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
- [systemd Service Documentation](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [Podman Documentation](https://docs.podman.io/)


