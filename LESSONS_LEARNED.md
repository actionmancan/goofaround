# Lessons Learned - Home Server Setup

This document captures all the critical configurations and fixes discovered during setup. Follow these to avoid the same issues on reinstall.

---

## 1. Static IPs for Containers (CRITICAL)

Without static IPs, containers get random IPs on restart, breaking inter-container communication.

### Podman Quadlet Files

**`homeserver-mosquitto.container`**
```ini
[Network]
Network=homeserver.network
IP=172.20.0.10
```

**`homeserver-frigate.container`**
```ini
[Network]
Network=homeserver.network
IP=172.20.0.20
```

**`homeserver-homeassistant.container`**
```ini
[Network]
Network=homeserver.network
IP=172.20.0.30
```

---

## 2. Frigate MQTT Configuration (CRITICAL)

Frigate MUST use the static IP for Mosquitto, NOT the hostname.

**`configs/frigate/config.yml`**
```yaml
mqtt:
  host: 172.20.0.10   # NOT homeserver-mosquitto!
  port: 1883
  topic_prefix: frigate
  client_id: frigate
```

**Why:** Frigate runs in its own network namespace and can't resolve container hostnames.

---

## 3. Home Assistant Frigate Integration

### Install the Custom Integration
```bash
# Inside HA container or via HACS
cd /config/custom_components
# Clone frigate-hass-integration
```

### Install Required Dependency
The Frigate integration requires `hass-web-proxy-lib`. If HA can't install it automatically:

```bash
# Fix DNS inside HA container first
podman exec homeserver-homeassistant bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'

# Then install
podman exec homeserver-homeassistant pip install hass-web-proxy-lib==0.0.7
```

### Configure Integration URL
When adding Frigate integration, use the static IP:
```
http://172.20.0.20:5000
```

---

## 4. Home Assistant Automations for Frigate

The key insight: **Trigger on `frigate/events` MQTT topic with `type == "new"`**

**`configs/homeassistant/automations.yaml`**
```yaml
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
```

### Why This Works
- Frigate publishes to `frigate/events` with JSON payload
- `type` field is: `new` (first detection), `update` (tracking), `end` (left frame)
- Only trigger on `new` to avoid spam
- Use `trigger.payload_json.after.label` to check what was detected

### What DOESN'T Work
- ❌ Triggering on `frigate/living_room/person` - this is just a count
- ❌ Triggering on `binary_sensor.living_room_person_occupancy` state changes - stays ON during continuous detection
- ❌ Using `frigate/living_room/person/snapshot` - this is binary JPEG data, not JSON

---

## 5. Camera RTSP Configuration

**Reolink RLC-810A / RLC-811A**
```
Main stream (4K): rtsp://admin:PASSWORD@CAMERA_IP:554/h264Preview_01_main
Sub stream (SD):  rtsp://admin:PASSWORD@CAMERA_IP:554/h264Preview_01_sub
```

Use sub stream for detection (less CPU), main stream for recording.

---

## 6. Prevent Fedora Server from Sleeping

```bash
# Disable sleep in systemd
sudo sed -i 's/#HandleSuspendKey=.*/HandleSuspendKey=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#HandleHibernateKey=.*/HandleHibernateKey=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#HandleLidSwitch=.*/HandleLidSwitch=ignore/' /etc/systemd/logind.conf

# Mask sleep targets
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Restart
sudo systemctl restart systemd-logind
```

---

## 7. SSH Setup Notes

- Username is **lowercase**: `chaletsmithhome` (not `ChaletSmithHome`)
- Set static IP via router DHCP reservation
- After IP change, update `~/.ssh/known_hosts` on client

---

## 8. Debugging Commands

### Check if Frigate is online via MQTT
```bash
timeout 3 podman exec homeserver-mosquitto mosquitto_sub -h localhost -t "frigate/available" -v -C 1
```

### Watch Frigate events in real-time
```bash
podman exec homeserver-mosquitto mosquitto_sub -h localhost -t "frigate/events" -v
```

### Check recent Frigate detections
```bash
curl -s http://localhost:5000/api/events?limit=5 | python3 -m json.tool
```

### Check Home Assistant logs
```bash
podman logs homeserver-homeassistant --tail 50 2>&1 | grep -iE "frigate|automation|trigger"
```

### Verify container IPs
```bash
podman inspect homeserver-frigate --format "{{.NetworkSettings.Networks.homeserver.IPAddress}}"
```

---

## 9. Service Restart Order

After configuration changes:
```bash
systemctl --user daemon-reload
systemctl --user restart homeserver-mosquitto
systemctl --user restart homeserver-frigate
systemctl --user restart homeserver-homeassistant
```

---

## 10. Common Errors & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| Frigate shows "offline" in MQTT | Can't resolve Mosquitto hostname | Use static IP in frigate config.yml |
| `RequirementsNotFound: hass-web-proxy-lib` | Missing Python package | `pip install hass-web-proxy-lib` inside HA container |
| Automation not triggering | Wrong MQTT topic or condition | Use `frigate/events` with `type == "new"` |
| SSH "Permission denied" | Wrong username case | Use lowercase username |
| Container IP changed | No static IP assigned | Add `IP=x.x.x.x` to quadlet file |

---

## Quick Reference: IP Addresses

| Service | Container IP | Host Port |
|---------|-------------|-----------|
| Mosquitto | 172.20.0.10 | 1883 |
| Frigate | 172.20.0.20 | 5000 |
| Home Assistant | 172.20.0.30 | 8123 |
| Camera (Reolink) | 192.168.1.126 | 554, 9000 |
| Fedora Server | 192.168.1.100 | 22 |

---

*Last updated: December 9, 2025*

