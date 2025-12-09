# Home Assistant Notification Setup Status

**Date:** December 8, 2025  
**Status:** ⚠️ Camera Working, Notifications Pending

---

## ✅ What's Working Perfectly

### Frigate NVR
- **Status:** ✅ Fully operational
- **Detection:** Person detection working (75-85% confidence scores)
- **Recording:** 4K video @ 5 FPS, continuous recording enabled
- **MQTT:** Publishing to Mosquitto successfully
- **Web Interface:** `http://192.168.1.100:5000`
- **Clips:** All detections saved with video clips

### Camera (Reolink RLC-810A)
- **Status:** ✅ Streaming perfectly
- **IP:** 192.168.1.126
- **Resolution:** 4K (3840x2160) @ 25fps
- **RTSP:** Working (`rtsp://admin:PASSWORD@192.168.1.126:554/h264Preview_01_main`)
- **Web Interface:** `http://192.168.1.126:9000`

### Infrastructure
- **Mosquitto MQTT:** ✅ Running, Frigate + HA connected
- **Home Assistant:** ✅ Running at `http://192.168.1.100:8123`
- **Network:** ✅ All containers on homeserver network (172.20.0.x)
- **SSH:** ✅ Working (`ssh chaletsmithhome@192.168.1.100`)

---

## ❌ What's NOT Working

### Home Assistant Notifications
- **Issue:** Automations don't trigger on Frigate events
- **Impact:** No push notifications when person detected
- **Current View:** Must check Frigate web interface manually

### Frigate Custom Integration
- **Issue:** Missing dependency `hass-web-proxy-lib==0.0.7`
- **Error:** `500 Internal Server Error` when adding integration
- **Root Cause:** No internet access to download Python package
- **Workaround:** Need temporary internet OR manual package installation

---

## 🔍 Debugging Summary

### Tested Approaches (All Failed)
1. ❌ MQTT topic triggers (`frigate/events`, `frigate/living_room/person`)
2. ❌ MQTT sensor state changes (`sensor.living_room_person`)
3. ❌ Binary sensor triggers (`binary_sensor.living_room_motion_active`)
4. ❌ Time-based test automations (even these didn't fire)
5. ❌ Frigate custom integration (missing dependencies)

### Root Causes Identified
- Frigate publishes snapshots to `frigate/living_room/person` (binary data)
- Frigate doesn't publish to `frigate/events` for some reason
- MQTT sensors in configuration.yaml never created entities (no MQTT data on expected topics)
- Frigate custom integration requires internet for dependency installation

---

## 🎯 Path Forward

### Option 1: Quick Fix with Internet (RECOMMENDED)
**Time:** 10-15 minutes

1. **Connect Fedora server to internet temporarily**
   ```bash
   # On Fedora machine
   sudo nmcli connection up "WiFi Network Name"
   ```

2. **Restart Home Assistant** (it will auto-download missing deps)
   ```bash
   systemctl --user restart homeserver-homeassistant
   ```

3. **Add Frigate Integration**
   - Settings → Devices & Services → + Add Integration
   - Search "Frigate"
   - URL: `http://172.20.0.138:5000`
   - This will automatically create:
     - Camera entities
     - Motion sensors  
     - Event notifications

4. **Disconnect from internet** (optional)

### Option 2: Manual Package Installation
**Time:** 30-60 minutes

1. Download `hass-web-proxy-lib-0.0.7` package on Mac
2. Transfer to Fedora via USB/SCP
3. Install manually in HA container:
   ```bash
   podman cp package.whl homeserver-homeassistant:/tmp/
   podman exec homeserver-homeassistant pip install /tmp/package.whl
   systemctl --user restart homeserver-homeassistant
   ```

### Option 3: Alternative Notification Methods
**Time:** 1-2 hours (experimental)

- RESTful sensor polling Frigate API
- Custom Python script checking events
- Node-RED integration (if installed)
- Webhook-based notifications

---

## 📊 Current Configuration

### MQTT Topics Frigate Publishes To
```
frigate/living_room/enabled/state
frigate/living_room/detect/state
frigate/living_room/motion/state
frigate/living_room/person/snapshot (binary image data)
frigate/living_room/recordings/state
```

### MQTT Topics Home Assistant Expects
```
frigate/events (for new detections) - NOT PUBLISHED BY FRIGATE
frigate/living_room/person (for JSON event data) - FRIGATE SENDS IMAGES
```

### Working MQTT Sensors (in configuration.yaml)
```yaml
mqtt:
  sensor:
    - name: "Living Room Motion"
      state_topic: "frigate/living_room/motion/state"  # ✅ EXISTS
    
    - name: "Living Room Detection"
      state_topic: "frigate/living_room/detect/state"  # ✅ EXISTS
    
    - name: "Living Room Person"
      state_topic: "frigate/living_room/person"  # ❌ BINARY DATA, NOT JSON
```

### Automations Attempted
All stored in `configs/homeassistant/automations.yaml` - none triggered successfully

---

## 🔧 Quick Verification Commands

### Check if Frigate is detecting
```bash
ssh chaletsmithhome@192.168.1.100
curl -s http://localhost:5000/api/events?limit=5 | python3 -m json.tool
```

### Check MQTT messages
```bash
ssh chaletsmithhome@192.168.1.100
podman exec homeserver-mosquitto mosquitto_sub -h localhost -t "frigate/#" -C 10
```

### Check if automations are loaded
```bash
ssh chaletsmithhome@192.168.1.100
podman exec homeserver-homeassistant cat /config/automations.yaml
```

---

## 📱 Current Workaround

**Bookmark on iPhone:** `http://192.168.1.100:5000`

This gives you:
- Live camera view
- All person detections with video clips
- Motion events
- Timeline of all activity
- Full 7-day recording history

---

## 🎬 Next Session Plan

1. **Connect Fedora to internet** (5 min)
2. **Add Frigate integration** (2 min)
3. **Test notifications** (3 min)
4. **Configure automation rules** (15 min)
   - Person detected → notify
   - Motion after 10pm → notify
   - Dog detected → notify (optional)
5. **Test with actual detection** (5 min)

**Total estimated time:** 30 minutes with internet access

---

## 📝 Lessons Learned

1. **Frigate custom integration requires internet** for initial setup
2. **MQTT-based approach is complex** due to Frigate's topic structure
3. **Home Assistant API requires authentication** (can't test services easily)
4. **Camera/Frigate detection works flawlessly** - it's just the HA integration
5. **Direct Frigate web interface** is very capable as a fallback

---

**Recommendation:** Connect to internet for 15 minutes to properly install Frigate integration, then disconnect. This is by far the easiest path forward.

