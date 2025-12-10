#!/bin/bash
# Home Server Setup Script
# Run this on a fresh Fedora installation to set up the entire home server

set -e

echo "=============================================="
echo "  Home Server Setup Script"
echo "=============================================="
echo ""

# Configuration - UPDATE THESE FOR YOUR SETUP
CAMERA_IP="${CAMERA_IP:-192.168.1.126}"
CAMERA_USER="${CAMERA_USER:-admin}"
CAMERA_PASS="${CAMERA_PASS:-YOUR_PASSWORD_HERE}"
ZIGBEE_DEVICE="${ZIGBEE_DEVICE:-/dev/serial/by-id/usb-Silicon_Labs_slae.sh_cc2652rb_stick_-_slaesh_s_iot_stuff_00_12_4B_00_25_9B_BF_73-if00-port0}"
TIMEZONE="${TIMEZONE:-America/New_York}"

# Static IPs for containers (CRITICAL - don't change these!)
MOSQUITTO_IP="172.20.0.10"
FRIGATE_IP="172.20.0.20"
HOMEASSISTANT_IP="172.20.0.30"
ZIGBEE2MQTT_IP="172.20.0.40"

# Paths
HOMESERVER_DIR="$HOME/homeserver"
QUADLET_DIR="$HOME/.config/containers/systemd"

echo "Configuration:"
echo "  Camera IP: $CAMERA_IP"
echo "  Zigbee Device: $ZIGBEE_DEVICE"
echo "  Timezone: $TIMEZONE"
echo ""
read -p "Press Enter to continue or Ctrl+C to abort..."

# =============================================================================
# 1. PREVENT SYSTEM SLEEP (CRITICAL FOR SERVERS)
# =============================================================================
echo ""
echo "[1/6] Configuring system to prevent sleep..."

sudo sed -i 's/#HandleSuspendKey=.*/HandleSuspendKey=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#HandleHibernateKey=.*/HandleHibernateKey=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#HandleLidSwitch=.*/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#IdleAction=.*/IdleAction=ignore/' /etc/systemd/logind.conf

sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
sudo systemctl restart systemd-logind

# GNOME settings (if running desktop)
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' 2>/dev/null || true
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing' 2>/dev/null || true
    gsettings set org.gnome.desktop.session idle-delay 0 2>/dev/null || true
fi

echo "  ✓ Sleep prevention configured"

# =============================================================================
# 2. INSTALL PODMAN AND DEPENDENCIES
# =============================================================================
echo ""
echo "[2/6] Installing Podman and dependencies..."

sudo dnf install -y podman podman-compose curl wget git

# Enable lingering for user services
loginctl enable-linger $USER

echo "  ✓ Podman installed"

# =============================================================================
# 3. CREATE DIRECTORY STRUCTURE
# =============================================================================
echo ""
echo "[3/6] Creating directory structure..."

mkdir -p "$HOMESERVER_DIR"/{configs,data}
mkdir -p "$HOMESERVER_DIR"/configs/{mosquitto,frigate,homeassistant,zigbee2mqtt}
mkdir -p "$HOMESERVER_DIR"/data/{mosquitto/data,mosquitto/log,media/frigate}
mkdir -p "$QUADLET_DIR"

echo "  ✓ Directories created"

# =============================================================================
# 4. CREATE CONFIGURATION FILES
# =============================================================================
echo ""
echo "[4/6] Creating configuration files..."

# --- Mosquitto Config ---
cat > "$HOMESERVER_DIR/configs/mosquitto/mosquitto.conf" << 'EOF'
listener 1883
allow_anonymous true
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
EOF

# --- Frigate Config (CRITICAL: Use static IP for MQTT!) ---
cat > "$HOMESERVER_DIR/configs/frigate/config.yml" << EOF
auth:
  enabled: false

mqtt:
  host: $MOSQUITTO_IP  # CRITICAL: Use static IP, NOT hostname!
  port: 1883
  topic_prefix: frigate
  client_id: frigate

detectors:
  cpu1:
    type: cpu

database:
  path: /media/frigate/frigate.db

record:
  enabled: true
  retain:
    days: 7
    mode: motion

snapshots:
  enabled: true
  retain:
    default: 7

cameras:
  living_room:
    enabled: true
    ffmpeg:
      inputs:
        - path: rtsp://${CAMERA_USER}:${CAMERA_PASS}@${CAMERA_IP}:554/h264Preview_01_main
          roles:
            - detect
            - record
    detect:
      width: 3840
      height: 2160
      fps: 5
    objects:
      track:
        - person
        - car
        - dog
        - cat

detect:
  enabled: true

version: 0.16-0
EOF

# --- Zigbee2MQTT Config (CRITICAL: Use static IP for MQTT!) ---
cat > "$HOMESERVER_DIR/configs/zigbee2mqtt/configuration.yaml" << EOF
homeassistant:
  enabled: true

mqtt:
  base_topic: zigbee2mqtt
  server: mqtt://$MOSQUITTO_IP:1883  # CRITICAL: Use static IP, NOT hostname!

serial:
  port: /dev/ttyUSB0

frontend:
  enabled: true
  host: 0.0.0.0
  port: 8080

advanced:
  log_level: info
  last_seen: ISO_8601
  channel: 11

devices: devices.yaml
groups: groups.yaml
EOF

# Create empty devices/groups files
touch "$HOMESERVER_DIR/configs/zigbee2mqtt/devices.yaml"
touch "$HOMESERVER_DIR/configs/zigbee2mqtt/groups.yaml"

# --- Home Assistant Config ---
cat > "$HOMESERVER_DIR/configs/homeassistant/configuration.yaml" << 'EOF'
# Home Assistant Configuration
# Note: MQTT and Frigate are configured via UI (Settings -> Integrations)

default_config:

mobile_app:

http:
  server_port: 8123
  use_x_forwarded_for: true
  trusted_proxies:
    - 127.0.0.1
    - 172.16.0.0/12
    - 192.168.0.0/16
    - 10.0.0.0/8

automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml
EOF

# --- Home Assistant Automations ---
cat > "$HOMESERVER_DIR/configs/homeassistant/automations.yaml" << 'EOF'
# Person Detection - triggers on NEW detections only
- id: frigate_person_alert
  alias: Person Detected - Living Room
  trigger:
    - platform: mqtt
      topic: frigate/events
  condition:
    - condition: template
      value_template: "{{ trigger.payload_json.type == \"new\" and trigger.payload_json.after.label == \"person\" }}"
  action:
    - service: persistent_notification.create
      data:
        title: "🚨 Person Detected"
        message: "Person in Living Room at {{ now().strftime(\"%H:%M:%S\") }}"
        notification_id: "person_{{ now().timestamp() | int }}"
  mode: queued
  max: 10

# Dog Detection
- id: frigate_dog_alert
  alias: Dog Detected - Living Room
  trigger:
    - platform: mqtt
      topic: frigate/events
  condition:
    - condition: template
      value_template: "{{ trigger.payload_json.type == \"new\" and trigger.payload_json.after.label == \"dog\" }}"
  action:
    - service: persistent_notification.create
      data:
        title: "🐕 Dog Detected"
        message: "Dog in Living Room at {{ now().strftime(\"%H:%M:%S\") }}"
        notification_id: "dog_{{ now().timestamp() | int }}"
  mode: queued
  max: 10
EOF

# Create empty scripts/scenes
touch "$HOMESERVER_DIR/configs/homeassistant/scripts.yaml"
touch "$HOMESERVER_DIR/configs/homeassistant/scenes.yaml"

echo "  ✓ Configuration files created"

# =============================================================================
# 5. CREATE PODMAN QUADLET FILES (with static IPs!)
# =============================================================================
echo ""
echo "[5/6] Creating Podman Quadlet service files..."

# --- Network ---
cat > "$QUADLET_DIR/homeserver.network" << 'EOF'
[Network]
NetworkName=homeserver
Driver=bridge
Subnet=172.20.0.0/16
Gateway=172.20.0.1
IPv6=false
Internal=false

[Install]
WantedBy=default.target
EOF

# --- Mosquitto ---
cat > "$QUADLET_DIR/homeserver-mosquitto.container" << EOF
[Unit]
Description=Mosquitto MQTT Broker for Home Server
After=homeserver-network.service
Requires=homeserver-network.service

[Container]
Image=docker.io/eclipse-mosquitto:latest
ContainerName=homeserver-mosquitto
AutoUpdate=registry

# Network - CRITICAL: Static IP!
Network=homeserver.network
IP=$MOSQUITTO_IP
PublishPort=1883:1883
PublishPort=9001:9001

# Volumes
Volume=$HOMESERVER_DIR/configs/mosquitto:/mosquitto/config:Z
Volume=$HOMESERVER_DIR/data/mosquitto/data:/mosquitto/data:Z
Volume=$HOMESERVER_DIR/data/mosquitto/log:/mosquitto/log:Z

# Environment
Environment=TZ=$TIMEZONE

[Service]
Restart=always
TimeoutStartSec=900

[Install]
WantedBy=default.target
EOF

# --- Frigate ---
cat > "$QUADLET_DIR/homeserver-frigate.container" << EOF
[Unit]
Description=Frigate NVR for Home Server
After=homeserver-mosquitto.service
Wants=homeserver-mosquitto.service

[Container]
Image=ghcr.io/blakeblackshear/frigate:stable
ContainerName=homeserver-frigate
AutoUpdate=registry

# Network - CRITICAL: Static IP!
Network=homeserver.network
IP=$FRIGATE_IP
PublishPort=5000:5000
PublishPort=8554:8554
PublishPort=8555:8555/tcp
PublishPort=8555:8555/udp

# Volumes
Volume=$HOMESERVER_DIR/configs/frigate:/config:Z
Volume=$HOMESERVER_DIR/data/media/frigate:/media/frigate:Z
Volume=/etc/localtime:/etc/localtime:ro

# Shared memory for faster processing
ShmSize=512mb

# Environment
Environment=TZ=$TIMEZONE

# Capabilities
AddCapability=CAP_PERFMON

# Health Check
HealthCmd=curl --fail http://localhost:5000/api/version || exit 1
HealthInterval=30s
HealthTimeout=10s
HealthRetries=3
HealthStartPeriod=60s

[Service]
Restart=always
TimeoutStartSec=900

[Install]
WantedBy=default.target
EOF

# --- Home Assistant ---
cat > "$QUADLET_DIR/homeserver-homeassistant.container" << EOF
[Unit]
Description=Home Assistant for Home Server
After=homeserver-mosquitto.service
Wants=homeserver-mosquitto.service homeserver-zigbee2mqtt.service

[Container]
Image=ghcr.io/home-assistant/home-assistant:stable
ContainerName=homeserver-homeassistant
AutoUpdate=registry

# Network - CRITICAL: Static IP!
Network=homeserver.network
IP=$HOMEASSISTANT_IP
PublishPort=8123:8123

# Volumes
Volume=$HOMESERVER_DIR/configs/homeassistant:/config:Z
Volume=/etc/localtime:/etc/localtime:ro
Volume=/run/dbus:/run/dbus:ro

# Environment
Environment=TZ=$TIMEZONE

# Install Frigate dependency on startup (CRITICAL!)
Exec=/bin/sh -c "echo nameserver 8.8.8.8 > /etc/resolv.conf && pip3 install -q hass-web-proxy-lib==0.0.7 2>/dev/null; exec /init"

# Health Check
HealthCmd=curl --fail http://localhost:8123 || exit 1
HealthInterval=30s
HealthTimeout=10s
HealthRetries=5
HealthStartPeriod=120s

[Service]
Restart=always
TimeoutStartSec=900

[Install]
WantedBy=default.target
EOF

# --- Zigbee2MQTT ---
cat > "$QUADLET_DIR/homeserver-zigbee2mqtt.container" << EOF
[Unit]
Description=Zigbee2MQTT Bridge for Home Server
After=homeserver-mosquitto.service
Requires=homeserver-mosquitto.service

[Container]
Image=docker.io/koenkk/zigbee2mqtt:latest
ContainerName=homeserver-zigbee2mqtt
AutoUpdate=registry

# Network
Network=homeserver.network
IP=$ZIGBEE2MQTT_IP
PublishPort=8080:8080

# Volumes
Volume=$HOMESERVER_DIR/configs/zigbee2mqtt:/app/data:Z
Volume=/run/udev:/run/udev:ro

# Device passthrough for Zigbee coordinator
AddDevice=$ZIGBEE_DEVICE:rwm

# Environment
Environment=TZ=$TIMEZONE

# Run with host user groups (for dialout access)
GroupAdd=keep-groups

# Security - disable SELinux for device access
SecurityLabelDisable=true
PodmanArgs=--privileged

# Health Check
HealthCmd=wget --no-verbose --tries=1 --spider http://localhost:8080 || exit 1
HealthInterval=30s
HealthTimeout=10s
HealthRetries=3

[Service]
Restart=always
TimeoutStartSec=900

[Install]
WantedBy=default.target
EOF

echo "  ✓ Quadlet files created"

# =============================================================================
# 6. START SERVICES
# =============================================================================
echo ""
echo "[6/6] Starting services..."

# Reload systemd user daemon
systemctl --user daemon-reload

# Start services in order
echo "  Starting Mosquitto..."
systemctl --user start homeserver-mosquitto
sleep 5

echo "  Starting Frigate..."
systemctl --user start homeserver-frigate
sleep 5

echo "  Starting Zigbee2MQTT..."
systemctl --user start homeserver-zigbee2mqtt
sleep 5

echo "  Starting Home Assistant..."
systemctl --user start homeserver-homeassistant

# Enable all services
systemctl --user enable homeserver-mosquitto homeserver-frigate homeserver-zigbee2mqtt homeserver-homeassistant

echo "  ✓ Services started and enabled"

# =============================================================================
# DONE!
# =============================================================================
echo ""
echo "=============================================="
echo "  Setup Complete!"
echo "=============================================="
echo ""
echo "Service URLs:"
echo "  Home Assistant: http://$(hostname -I | awk '{print $1}'):8123"
echo "  Frigate:        http://$(hostname -I | awk '{print $1}'):5000"
echo "  Zigbee2MQTT:    http://$(hostname -I | awk '{print $1}'):8080"
echo ""
echo "Container IPs (internal network):"
echo "  Mosquitto:      $MOSQUITTO_IP"
echo "  Frigate:        $FRIGATE_IP"
echo "  Home Assistant: $HOMEASSISTANT_IP"
echo "  Zigbee2MQTT:    $ZIGBEE2MQTT_IP"
echo ""
echo "NEXT STEPS:"
echo "  1. Open Home Assistant at the URL above"
echo "  2. Create your admin account"
echo "  3. Go to Settings → Devices & Services → Add Integration"
echo "  4. Add MQTT (broker: $MOSQUITTO_IP, port: 1883)"
echo "  5. Add Frigate (URL: http://$FRIGATE_IP:5000)"
echo ""
echo "To check service status:"
echo "  systemctl --user status homeserver-mosquitto"
echo "  systemctl --user status homeserver-frigate"
echo "  systemctl --user status homeserver-homeassistant"
echo "  systemctl --user status homeserver-zigbee2mqtt"
echo ""
echo "To view logs:"
echo "  podman logs -f homeserver-mosquitto"
echo "  podman logs -f homeserver-frigate"
echo "  podman logs -f homeserver-homeassistant"
echo "  podman logs -f homeserver-zigbee2mqtt"
echo ""

