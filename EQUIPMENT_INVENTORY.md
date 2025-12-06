# Equipment Inventory

Complete list of all hardware and equipment used in the home server setup.

**Last Updated:** December 6, 2025

---

## Server Hardware

### Main Server
- **Model:** Dell Optiplex
- **CPU:** [Fill in]
- **RAM:** [Fill in]
- **Storage:** [Fill in]
- **OS:** Fedora Workstation
- **IP Address:** 192.168.1.100 (static)
- **MAC Address:** [Fill in]
- **Location:** Living Room (testing) → [Final location]

### Storage Drives
- **Primary OS Drive:** [Model/Size]
- **Camera Footage Drive:** [Model/Size/Capacity]
  - **Mount Point:** [Fill in]
  - **Connection:** [Internal SATA / External USB]

---

## Network Equipment

### Router
- **Brand/Model:** [Fill in]
- **IP Address:** [Usually 192.168.1.1]
- **WiFi SSID:** [Fill in]
- **Location:** [Different room]

### PoE Injector
- **Brand/Model:** Ubiquiti UniFi PoE Adapter (U-POE-AF)
- **Type:** PoE Injector (802.3af)
- **Total Ports:** 2 (1 input, 1 PoE output)
- **Input Port:** Gigabit Ethernet (no lightning bolt ⚡) - connect to wall jack/router
- **Output Port:** Gigabit PoE (lightning bolt ⚡) - connect to camera
- **Power Output:** 48V DC @ 0.32A (15W max)
- **Input Voltage:** 100-240V AC @ 50/60Hz
- **PoE Standard:** 802.3af
- **Surge Protection:** Difference and common mode
- **Location:** Living Room (testing)
- **Connected Device:**
  - PoE Output: Camera 1 (RLC-810A) - [Fill in IP when known]
- **Purchase:** [CloudFree](https://cloudfree.shop/product/unifi-poe-adapter/)

### Network Cables
- **Camera 1 Cable:** [Length/Type]
- **Camera 2 Cable:** [Length/Type]
- **Server Cable:** [Length/Type]

---

## Cameras

### Camera 1: Reolink RLC-810A
- **Model:** Reolink RLC-810A
- **Type:** PoE (Power over Ethernet)
- **Sensor:** 8MP (4K)
- **Resolution:** 3840x2160 @ 25fps (main), 640x480 (sub)
- **PoE Standard:** 802.3af (15W)
- **Power Consumption:** ~12W
- **Night Vision:** IR LEDs up to 100ft
- **Field of View:** 87° (diagonal)
- **IP Address:** [Fill in - e.g., 192.168.1.101]
- **MAC Address:** [Fill in]
- **Username:** admin
- **Password:** [Fill in]
- **RTSP Main Stream:** `rtsp://admin:[password]@[ip]:554/h264Preview_01_main`
- **RTSP Sub Stream:** `rtsp://admin:[password]@[ip]:554/h264Preview_01_sub`
- **Video Codec:** H.264, H.265
- **Location:** Living Room (testing) → [Final location]
- **Mount Type:** [Wall / Ceiling / Pole]
- **Connected To:** PoE Injector output port
- **Status:** Testing

### Camera 2: [Model]
- **Model:** [Fill in]
- **Type:** [PoE / WiFi]
- **Resolution:** [Fill in]
- **IP Address:** [Fill in]
- **MAC Address:** [Fill in]
- **Username:** [Fill in]
- **Password:** [Fill in]
- **RTSP Stream:** [Fill in]
- **Location:** [Fill in]
- **Status:** [Fill in]

### Camera 3: [Model]
- [Fill in as needed]

---

## Zigbee Devices

### Zigbee Coordinator
- **Model:** Sonoff Zigbee 3.0 USB Dongle Plus (ZBDongle-E or ZBDongle-P)
- **Chip:** Texas Instruments CC2652P (ZBDongle-P) or Silicon Labs EFR32MG21 (ZBDongle-E)
- **Zigbee Version:** Zigbee 3.0
- **USB Device Path:** `/dev/serial/by-id/[fill in when connected]`
- **Firmware Version:** [Check in Zigbee2MQTT after setup]
- **Max Devices:** 100+ direct connections
- **Connected To:** Fedora Server (USB port)
- **Status:** Working (confirmed)

### Smart Bulbs
- **Bulb 1:** IKEA Trådfri LED Bulb E26 800 Lumen
  - **Model:** LED bulb E26 800 lumen, wireless dimmable white spectrum
  - **Luminous Flux:** 800 lumens
  - **Color Temperature:** Adjustable 2200K-4000K (warm glow to cool white)
  - **Power Consumption:** 8.0W
  - **Lifespan:** ~25,000 hours
  - **Connectivity:** Zigbee 3.0
  - **Zigbee ID:** [Fill in after pairing]
  - **Location:** [Fill in - e.g., Living Room]
  - **Status:** Working (confirmed)
  - **Price:** ~$8-15

- **Bulb 2:** [Add if you have more]
  - **Zigbee ID:** [Fill in]
  - **Location:** [Fill in]
  - **Status:** [Fill in]

### Smart Switches
- **Switch 1:** [Brand/Model]
  - **Zigbee ID:** [Fill in]
  - **Location:** [Fill in]
  - **Status:** [Fill in]

### Smart Sensors
- **Motion Sensor 1:** [Brand/Model]
  - **Zigbee ID:** [Fill in]
  - **Location:** [Fill in]
  - **Status:** [Fill in]

- **Door/Window Sensor 1:** [Brand/Model]
  - **Zigbee ID:** [Fill in]
  - **Location:** [Fill in]
  - **Status:** [Fill in]

---

## USB Devices

### Connected to Fedora Server
- **Zigbee Coordinator:** Sonoff Zigbee 3.0 USB Dongle Plus
  - **Port:** [USB port location]
  - **Device:** `/dev/serial/by-id/[fill in]`

- **Coral TPU (if applicable):** [Model]
  - **Port:** [USB port location]
  - **Status:** [Installed / Not Installed]

---

## Service URLs

### Access from Local Network
- **Home Assistant:** http://192.168.1.100:8123
- **Frigate NVR:** http://192.168.1.100:5000
- **Zigbee2MQTT:** http://192.168.1.100:8080
- **Nginx Proxy Manager:** http://192.168.1.100:8181
- **AdGuard Home:** http://192.168.1.100:3000

### SSH Access
- **Host:** ChaletSmithHome@192.168.1.100
- **Port:** 22
- **Key:** [SSH key location]

---

## IP Address Assignments

### Static IPs (DHCP Reservations)
- **Fedora Server:** 192.168.1.100
- **Camera 1 (RLC-810A):** [Fill in]
- **Camera 2:** [Fill in]
- **Camera 3:** [Fill in]
- **PoE Switch:** [Fill in if managed]

### Dynamic IPs
- [List any devices using DHCP]

---

## Passwords & Credentials

### Camera Credentials
- **Camera 1 (RLC-810A):**
  - Username: admin
  - Password: [Fill in - store securely]

- **Camera 2:**
  - Username: [Fill in]
  - Password: [Fill in]

### Service Credentials
- **Home Assistant:** [Fill in after setup]
- **Nginx Proxy Manager:** [Fill in after setup]
- **AdGuard Home:** [Fill in after setup]

### Network Credentials
- **Router Admin:** [Fill in]
- **WiFi Password:** [Fill in]

**⚠️ SECURITY NOTE:** Consider using a password manager for sensitive credentials. This file should be kept secure and not committed to public repositories.

---

## Purchase Information

### Where Purchased
- **Server (Dell Optiplex):** [Where/When]
- **Camera 1 (RLC-810A):** [Where/When/Price]
- **Camera 2:** [Where/When/Price]
- **PoE Injector (Ubiquiti U-POE-AF 15W):** CloudFree ($10-18 depending on model)
- **Zigbee Coordinator (Sonoff):** [Where/When/Price]
- **Smart Bulb (IKEA Trådfri):** [Where/When/Price - e.g., IKEA store/online]
- **Storage Drive:** [Where/When/Price]

### Warranty Information
- **Server:** [Warranty details]
- **Cameras:** [Warranty details]
- **Other Equipment:** [Warranty details]

---

## Configuration Notes

### Camera Settings
- **Camera 1 (RLC-810A):**
  - Resolution: 4K (3840x2160) main, 640x480 sub
  - Frame Rate: 25fps (main), 15fps (sub)
  - Bitrate: Variable (configurable in camera web UI)
  - Video Codec: H.264 / H.265
  - Night Vision: Auto (IR LEDs)
  - Motion Zones: [Configure in Frigate or camera UI]

### Network Configuration
- **Subnet:** 192.168.1.0/24
- **Gateway:** [Router IP]
- **DNS:** [Fill in]

### Frigate Configuration
- **Detection FPS:** 5
- **Recording Retention:** 7 days
- **Objects Tracked:** person, car, dog, cat

---

## Troubleshooting Notes

### Known Issues
- [Fill in any known issues or workarounds]

### Solutions Applied
- [Fill in solutions that worked]

---

## Future Additions

### Planned Equipment
- [ ] Additional cameras
- [ ] More Zigbee devices
- [ ] Storage expansion
- [ ] Other equipment

---

## Quick Reference

### Camera RTSP URLs Template
```
Main: rtsp://admin:[password]@[ip]:554/h264Preview_01_main
Sub:  rtsp://admin:[password]@[ip]:554/h264Preview_01_sub
```

### Common Commands
```bash
# Find Fedora IP
hostname -I

# Find camera IPs
nmap -p 80,554 192.168.1.0/24

# Test RTSP stream
ffmpeg -rtsp_transport tcp -i "rtsp://..." -t 5 -f null -

# Check services
make status
make logs SERVICE=frigate
```

---

**Instructions:**
1. Fill in all [Fill in] sections with your actual equipment details
2. Update IP addresses as you configure devices
3. Keep passwords secure (consider using a password manager)
4. Update this file whenever you add new equipment
5. Keep a backup of this file in a secure location

