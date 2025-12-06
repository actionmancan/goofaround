# Living Room Test Setup - Step by Step Guide

Complete step-by-step guide for testing your home server setup in the living room before permanent installation.

---

## Current Situation

- ✅ Fedora server is set up
- ✅ Zigbee coordinator is working
- ✅ Camera (RLC-810A) is ready
- ⚠️ Router is in a different room
- 🎯 Testing everything in living room first

---

## Step 1: Network Connection Setup

**Problem:** Router is in different room, but you need network connection.

### Option A: Temporary Ethernet Cable (Recommended)
- Run a long Ethernet cable from router room to living room
- Connect Fedora server to router via cable
- **Pros:** Most reliable, best performance
- **Cons:** Temporary cable across floor

### Option B: WiFi Connection
- Connect Fedora server to WiFi
- **Pros:** No cable needed
- **Cons:** Less reliable for server, may need WiFi adapter

### Option C: Powerline Adapter
- Use powerline Ethernet adapters
- Plug one near router, one in living room
- **Pros:** No long cable, uses existing wiring
- **Cons:** Performance depends on wiring

**Action:** Choose your method and get connected to network.

---

## Step 2: Verify Network Connection

**On Fedora server:**

```bash
# Check if connected to network
ip addr show

# Check if you can reach router
ping -c 3 192.168.1.1

# Check if you have internet
ping -c 3 8.8.8.8

# Find your Fedora IP address
hostname -I
```

**Expected:** Should see IP address like `192.168.1.XXX`

**If no connection:**
- Check cable is plugged in (if using Ethernet)
- Check WiFi is connected (if using WiFi)
- Check router is powered on
- Try restarting network: `sudo systemctl restart NetworkManager`

---

## Step 3: Connect Camera to Network

**For PoE Camera (RLC-810A) with Ubiquiti 15W PoE Switch:**

### Setup Ubiquiti PoE Switch

**Important:** Your Ubiquiti 15W switch can power **1 camera** (RLC-810A needs ~12W). Perfect for testing!

**Note:** You don't need to run a cable from the router! You have options:
- Connect switch to router via **Powerline adapter** (no long cable)
- Connect switch to router via **WiFi bridge** (no cable at all)
- Connect Fedora server via **WiFi** (no switch connection needed for server)

**Connection Steps:**

1. **Power the Switch:**
   - Plug Ubiquiti switch into power outlet
   - Wait for switch to boot up (LEDs should light up)

2. **Connect Switch to Network:**
   - **Option A (Router via Ethernet):** Run Ethernet cable from router (in other room) → Ubiquiti switch
   - **Option B (Powerline Adapter):** Connect powerline adapter → Ubiquiti switch (avoids long cable)
   - **Option C (WiFi Bridge):** Use WiFi bridge/extender with Ethernet port → Ubiquiti switch
   - Use a **non-PoE port** on the switch (check switch labels - typically ports 2-5)
   - This provides network connection to switch and camera

3. **Connect Camera to PoE Port:**
   - Connect Ethernet cable from RLC-810A camera → **Port 1 (PoE)** on switch
   - **Important:** Port 1 is PoE-enabled and will power the camera
   - Camera should power on automatically (LED lights up)

4. **Connect Fedora Server:**
   - **Option A (Via Switch):** Connect Ethernet from Fedora server → **Port 5 (non-PoE)** on switch
   - **Option B (Via WiFi):** Connect Fedora server to WiFi (no Ethernet needed)
   - **Option C (Direct to Router):** Connect Fedora directly to router via Ethernet
   - All options keep everything on same network segment

**Physical Setup Options:**

**Option 1: Switch Connected to Router (Ethernet)**
```
Router (other room)
    ↓ Ethernet cable (to Port 2-5)
Ubiquiti PoE Switch (15W) - Living Room
    ├── Port 1 (PoE) → Camera (RLC-810A) - ~12W
    └── Port 5 (non-PoE) → Fedora Server (optional)
```

**Option 2: Switch via Powerline/WiFi Bridge, Fedora via WiFi**
```
Router (other room)
    ↓ Powerline Adapter or WiFi Bridge
Ubiquiti PoE Switch (15W) - Living Room
    └── Port 1 (PoE) → Camera (RLC-810A) - ~12W

Fedora Server → WiFi (no switch connection needed)
```

**Option 3: Switch to Router, Fedora via WiFi**
```
Router (other room)
    ↓ Ethernet cable (to Port 2-5)
Ubiquiti PoE Switch (15W) - Living Room
    └── Port 1 (PoE) → Camera (RLC-810A) - ~12W

Fedora Server → WiFi (no switch connection needed)
```

**Verify Camera Power:**
- Camera LED should light up when connected to Port 1 (PoE port)
- If no LED:
  - Check camera is connected to **Port 1** (PoE port, not regular port)
  - Verify switch is powered (check switch LEDs)
  - Check Ethernet cable connections are secure
  - Note: Only Port 1 provides PoE power on this switch

**Note:** With 15W budget, you can only power 1 camera. For more cameras later, you'll need a higher-capacity switch or PoE injectors.

---

## Step 4: Find Camera IP Address

**Method 1: Reolink App (Easiest)**
1. Download Reolink app on phone
2. Make sure phone is on same WiFi network
3. Open app → Add Device → Scan QR code on camera
4. App will show camera IP address

**Method 2: Router Admin Panel**
1. Log into router (usually `http://192.168.1.1`)
2. Look for "Connected Devices" or "DHCP Clients"
3. Find "Reolink" device
4. Note the IP address

**Method 3: Scan Network (from Fedora)**
```bash
# Install nmap if needed
sudo dnf install -y nmap

# Scan for cameras
nmap -p 80,554 192.168.1.0/24

# Look for device with port 80 (web) and 554 (RTSP) open
```

**Action:** Write down camera IP address: `192.168.1.XXX`

---

## Step 5: Test Camera Web Interface

**From any computer on same network:**

1. Open browser
2. Go to: `http://[camera-ip]`
   - Example: `http://192.168.1.100`
3. Login:
   - Username: `admin`
   - Password: Check camera label or Reolink app
4. Should see camera live view

**If can't access:**
- Verify camera IP is correct
- Check camera and computer are on same network
- Try from Fedora server: `curl http://[camera-ip]`

---

## Step 6: Test Camera RTSP Stream

**On Fedora server:**

```bash
# Install ffmpeg if needed
sudo dnf install -y ffmpeg

# Test main stream (replace IP and password)
ffmpeg -rtsp_transport tcp -i "rtsp://admin:yourpassword@[camera-ip]:554/h264Preview_01_main" -t 5 -f null -

# Test sub stream
ffmpeg -rtsp_transport tcp -i "rtsp://admin:yourpassword@[camera-ip]:554/h264Preview_01_sub" -t 5 -f null -
```

**Expected:** Should see output without errors

**If errors:**
- Check camera IP is correct
- Check username/password
- Verify RTSP is enabled in camera settings
- Check camera is accessible: `ping [camera-ip]`

---

## Step 7: Configure Frigate for Camera

**On Fedora server:**

```bash
# Edit Frigate config
nano ~/Documents/GitHub/goofaround/configs/frigate/config.yml
```

**Replace example camera with your RLC-810A:**

```yaml
cameras:
  living_room_test:
    enabled: true
    ffmpeg:
      inputs:
        # Sub stream for detection (better performance)
        - path: rtsp://admin:yourpassword@[camera-ip]:554/h264Preview_01_sub
          roles: ["detect"]
        # Main stream for recording (4K)
        - path: rtsp://admin:yourpassword@[camera-ip]:554/h264Preview_01_main
          roles: ["record"]
    detect:
      width: 640   # Sub stream resolution
      height: 480
      fps: 5
    objects:
      track: ["person", "car", "dog", "cat"]
```

**Save file:** Ctrl+X, then Y, then Enter

---

## Step 8: Deploy Services

**On Fedora server:**

```bash
cd ~/Documents/GitHub/goofaround

# Run tests first
make test-unit

# Deploy services
make deploy

# Check status
make status
```

**Expected:** All services should show "active (running)"

**If services fail:**
- Check logs: `make logs SERVICE=frigate`
- Verify camera IP/password in config
- Check network connectivity

---

## Step 9: Access Frigate Web Interface

**From any computer on same network:**

1. Open browser
2. Go to: `http://[fedora-ip]:5000`
   - Example: `http://192.168.1.100:5000`
3. Should see Frigate dashboard
4. Click on camera name
5. Should see live stream

**If can't access:**
- Check Fedora IP: `hostname -I` on Fedora
- Check firewall: `sudo firewall-cmd --list-ports`
- Add port if needed: `sudo firewall-cmd --add-port=5000/tcp --permanent && sudo firewall-cmd --reload`

---

## Step 10: Test Detection

**In Frigate web interface:**

1. Walk in front of camera
2. Should see detection boxes around you
3. Check "Events" tab for recorded detections
4. Verify recordings are saving

**If no detection:**
- Check camera is enabled in config
- Verify RTSP stream works (Step 6)
- Check Frigate logs: `make logs SERVICE=frigate`
- Adjust detection settings if needed

---

## Step 11: Test Zigbee Devices

**If you have Zigbee bulbs/switches:**

1. Access Zigbee2MQTT: `http://[fedora-ip]:8080`
2. Go to Settings → Permit Join
3. Enable joining
4. Put device in pairing mode
5. Device should appear in Zigbee2MQTT
6. Test control from Home Assistant

---

## Step 12: Verify Everything Works

**Checklist:**

- [ ] Fedora server is on network
- [ ] Camera is powered and on network
- [ ] Camera web interface works
- [ ] Camera RTSP stream works
- [ ] Frigate can see camera
- [ ] Frigate shows live stream
- [ ] Detection is working
- [ ] Recordings are saving
- [ ] Zigbee devices are paired (if applicable)
- [ ] Home Assistant is accessible (if deployed)

---

## Troubleshooting Common Issues

### Camera Not Found
- Check camera is powered (LED on)
- Verify camera is connected to **Port 1 (PoE port)** on Ubiquiti switch
- Check switch is powered (LEDs on)
- Verify switch is connected to router via non-PoE port (Port 2-5)
- Verify camera IP hasn't changed
- Check camera and server are on same network
- Try pinging camera: `ping [camera-ip]`

### Frigate Can't Connect to Camera
- Verify RTSP URL is correct
- Check username/password
- Test RTSP stream manually (Step 6)
- Check camera RTSP is enabled

### No Detection
- Check camera is enabled in config
- Verify detect resolution matches sub stream
- Check Frigate logs for errors
- Try increasing FPS in detect settings

### Network Issues
- Verify all devices on same network
- Check router is working
- **Check Ubiquiti switch is powered and connected to router** (Port 2-5)
- Verify camera is on **Port 1 (PoE port)** (not regular port)
- Check Ethernet cables are securely connected
- Verify switch LEDs show activity
- Try restarting network: `sudo systemctl restart NetworkManager`
- Check firewall isn't blocking

---

## Next Steps After Testing

Once everything works in living room:

1. **Plan permanent installation:**
   - Choose camera locations
   - Plan Ethernet cable runs
   - Decide on PoE switch placement

2. **Move to permanent locations:**
   - Mount cameras
   - Run permanent Ethernet cables
   - Set up PoE switch properly

3. **Configure for production:**
   - Set static IPs for cameras
   - Configure motion zones
   - Set up alerts/notifications
   - Configure recording retention

---

## Network Setup Summary

### Your Current Setup (Living Room Testing):

```
Internet Router (other room)
    ↓ Ethernet cable (temporary, to Port 2-5)
Ubiquiti PoE Switch (15W) - Living Room
    ├── Port 1 (PoE) → Camera (RLC-810A) - ~12W
    └── Port 5 (non-PoE) → Fedora Server (optional)
```

**Important Notes:**
- **PoE Budget:** 15W total (can only power 1 camera)
- **RLC-810A Power:** ~12W (fits within budget)
- **For More Cameras:** Need higher-capacity switch (e.g., 56W+) or PoE injectors
- **Switch Location:** Living room for testing
- **Router Connection:** Temporary Ethernet cable from router room

### Port Assignments:
- **Port 1 (PoE):** Camera (RLC-810A) - ~12W (required)
- **Port 2-5 (non-PoE):** Available for:
  - Router/network connection (via Ethernet, powerline, or WiFi bridge)
  - Fedora Server (if connecting via switch instead of WiFi)
  - Other devices

### Network Connection Options Summary:
- **Switch → Router:** Ethernet cable, Powerline adapter, or WiFi bridge
- **Fedora → Network:** WiFi (recommended), Ethernet via switch, or Ethernet direct to router
- **Camera → Network:** Via switch (PoE port) - camera gets network through switch connection

---

## Quick Reference

**Camera RTSP URLs:**
- Main: `rtsp://admin:password@[ip]:554/h264Preview_01_main`
- Sub: `rtsp://admin:password@[ip]:554/h264Preview_01_sub`

**Service URLs:**
- Frigate: `http://[fedora-ip]:5000`
- Zigbee2MQTT: `http://[fedora-ip]:8080`
- Home Assistant: `http://[fedora-ip]:8123`

**Useful Commands:**
```bash
# Find IP addresses
hostname -I                    # Fedora IP
ip addr show                   # All interfaces

# Test camera
ping [camera-ip]               # Test connectivity
ffmpeg -rtsp_transport tcp -i "rtsp://..." -t 5 -f null -  # Test stream

# Check services
make status                    # Service status
make logs SERVICE=frigate      # View logs
```

---

*Work through each step one at a time. Don't move to next step until current step works!*
