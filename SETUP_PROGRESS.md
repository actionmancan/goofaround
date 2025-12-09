# 🏠 Home Server Setup Progress

**Last Updated:** Saturday, Dec 6, 2025

---

## ✅ Completed

- [x] Project cloned and initialized
- [x] Python virtual environment created (`.venv/`)
- [x] All dependencies installed (pytest, podman-py, paho-mqtt, etc.)
- [x] Directory structure created (`configs/`, `data/`, `backups/`)
- [x] Default config files generated
- [x] Podman verified (v5.7.0)
- [x] Tests run (58 passed, 6 minor parsing issues in tests)
- [x] SSH enabled and configured
- [x] SSH key added for passwordless access from Mac
- [x] Zigbee USB dongle detected (SLAE.sh CC2652RB)
- [x] Zigbee2MQTT quadlet configured with device path
- [x] User added to dialout group (reboot required)
- [x] **Camera connected and RTSP stream working!**
- [x] **Camera IP:** 192.168.1.126
- [x] **Camera credentials stored in secrets/**
- [x] **Test frame captured successfully (195KB)**

---

## 🔐 SSH Access

**IP Address:** `192.168.1.100`
**Username:** `chaletsmithhome` (lowercase!)

From your Mac:
```bash
ssh chaletsmithhome@192.168.1.100
```

---

## 📹 Camera Status

**Model:** Reolink RLC-810A  
**IP:** 192.168.1.126  
**Web Interface:** http://192.168.1.126:9000  
**RTSP Port:** 554  
**Resolution:** 4K (3840x2160) @ 25fps  
**Status:** ✅ RTSP stream tested and working!

**RTSP Streams:**
- Main (4K): `rtsp://admin:PASSWORD@192.168.1.126:554/h264Preview_01_main`
- Sub (480p): `rtsp://admin:PASSWORD@192.168.1.126:554/h264Preview_01_sub`

---

## ⏳ Next Steps

### 1. Move repo to proper location
```bash
cd ~/Documents
mkdir -p GitHub
mv ~/Downloads/goofaround-main\(1\)/goofaround-main ~/Documents/GitHub/goofaround
cd ~/Documents/GitHub/goofaround
```

### 2. Configure Frigate with camera
- Edit `configs/frigate/config.yml`
- Add camera configuration

### 3. Deploy all services
```bash
./scripts/deploy.sh
```

---

## 📁 Project Location

**Current:** `/home/chaletsmithhome/Downloads/goofaround-main(1)/goofaround-main`  
**Target:** `/home/chaletsmithhome/Documents/GitHub/goofaround`

## 🚀 Quick Start Commands

```bash
# Navigate to project
cd ~/Documents/GitHub/goofaround

# Activate virtual environment
source .venv/bin/activate

# Check Zigbee USB device
ls -l /dev/serial/by-id/

# Run tests
.venv/bin/pytest tests/ -v

# Deploy (after configuration)
./scripts/deploy.sh
```

---

## 🛒 Hardware Checklist

- [x] Zigbee USB coordinator plugged in
- [x] PoE injector connected to router
- [x] IP camera connected to PoE injector
- [x] Camera IP identified (192.168.1.126)
- [x] Camera credentials stored

---

## 🎯 Services We're Setting Up

| Service | Port | Purpose | Status |
|---------|------|---------|--------|
| Home Assistant | 8123 | Smart home hub | Pending |
| Frigate NVR | 5000 | AI camera system | Ready to configure |
| Zigbee2MQTT | 8080 | Zigbee device bridge | Configured |
| Mosquitto | 1883 | MQTT broker | Configured |
| Nginx Proxy | 80, 443, 8181 | Reverse proxy | Configured |
| AdGuard Home | 3000 | DNS ad blocking | Configured |

---

