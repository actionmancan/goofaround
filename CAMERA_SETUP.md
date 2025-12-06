# Camera Setup Guide

Complete guide for setting up IP cameras with Frigate on your Fedora server.

## Prerequisites

- [ ] Camera connected to network (PoE switch or WiFi)
- [ ] Camera has RTSP support enabled
- [ ] You know the camera's IP address
- [ ] You know the camera's username and password
- [ ] Frigate service is deployed (or ready to deploy)

---

## Step 1: Find Your Camera's IP Address

### Option A: Check Router/Network
- Log into your router admin panel
- Look for connected devices
- Find your camera by MAC address or device name

### Option B: Scan Network (from Fedora machine)
```bash
# Install nmap if needed
sudo dnf install -y nmap

# Scan your network for cameras (replace 192.168.1.0/24 with your network)
nmap -p 554,80,8080 192.168.1.0/24

# Look for devices with port 554 open (RTSP port)
```

### Option C: Check Camera's Web Interface
- Most cameras have a web interface
- Check camera manual for default IP (often 192.168.1.108 or similar)
- Access via browser: `http://[camera-ip]`

---

## Step 2: Find Camera RTSP Stream URL

### Common RTSP Paths by Brand

**Reolink Cameras:**
```
Main Stream: rtsp://username:password@[camera-ip]:554/h264Preview_01_main
Sub Stream: rtsp://username:password@[camera-ip]:554/h264Preview_01_sub
```

**Amcrest/Dahua:**
```
Main Stream: rtsp://username:password@[camera-ip]:554/cam/realmonitor?channel=1&subtype=0
Sub Stream: rtsp://username:password@[camera-ip]:554/cam/realmonitor?channel=1&subtype=1
```

**Hikvision:**
```
Main Stream: rtsp://username:password@[camera-ip]:554/Streaming/Channels/101
Sub Stream: rtsp://username:password@[camera-ip]:554/Streaming/Channels/102
```

**Generic ONVIF:**
```
rtsp://username:password@[camera-ip]:554/stream1
rtsp://username:password@[camera-ip]:554/onvif1
rtsp://username:password@[camera-ip]:554/Streaming/Channels/1
```

### Test RTSP Stream

Test if your RTSP URL works before configuring Frigate:

```bash
# Install ffmpeg if needed
sudo dnf install -y ffmpeg

# Test RTSP stream (replace with your camera URL)
ffmpeg -rtsp_transport tcp -i "rtsp://admin:password@192.168.1.100:554/stream" -t 5 -f null -

# If it works, you'll see output without errors
# If it fails, check:
# - Camera IP is correct
# - Username/password are correct
# - RTSP path is correct
# - Camera has RTSP enabled in settings
```

---

## Step 3: Get Camera Resolution and FPS

You need to know your camera's resolution for Frigate config:

### Option A: Check Camera Web Interface
- Log into camera web interface
- Go to Video/Stream settings
- Note resolution (e.g., 1920x1080, 2560x1440, 3840x2160)
- Note FPS (e.g., 15, 20, 25, 30)

### Option B: Use ffprobe
```bash
# Install ffmpeg (includes ffprobe)
sudo dnf install -y ffmpeg

# Probe camera stream
ffprobe -rtsp_transport tcp "rtsp://admin:password@192.168.1.100:554/stream"

# Look for lines like:
# Stream #0:0: Video: h264, yuv420p, 1920x1080, 25 fps
```

---

## Step 4: Configure Frigate

### Ensure Config File Exists

If you haven't run `make init-configs` yet:
```bash
cd ~/Documents/GitHub/goofaround
make init-configs
```

### Edit Frigate Config

```bash
nano configs/frigate/config.yml
```

### Example Configuration

**Single Camera (Reolink):**
```yaml
cameras:
  front_door:
    enabled: true
    ffmpeg:
      inputs:
        - path: rtsp://admin:yourpassword@192.168.1.100:554/h264Preview_01_main
          roles: ["detect", "record"]
    detect:
      width: 2560
      height: 1920
      fps: 5
    objects:
      track: ["person", "car", "dog", "cat"]
```

**Multiple Cameras:**
```yaml
cameras:
  front_door:
    enabled: true
    ffmpeg:
      inputs:
        - path: rtsp://admin:password@192.168.1.100:554/h264Preview_01_main
          roles: ["detect", "record"]
    detect:
      width: 2560
      height: 1920
      fps: 5
    objects:
      track: ["person", "car"]

  back_yard:
    enabled: true
    ffmpeg:
      inputs:
        - path: rtsp://admin:password@192.168.1.101:554/h264Preview_01_main
          roles: ["detect", "record"]
    detect:
      width: 1920
      height: 1080
      fps: 5
    objects:
      track: ["person", "car", "dog"]
```

**Using Sub Stream for Detection (Recommended for Performance):**
```yaml
cameras:
  front_door:
    enabled: true
    ffmpeg:
      inputs:
        # Sub stream for detection (lower resolution, better performance)
        - path: rtsp://admin:password@192.168.1.100:554/h264Preview_01_sub
          roles: ["detect"]
        # Main stream for recording (full resolution)
        - path: rtsp://admin:password@192.168.1.100:554/h264Preview_01_main
          roles: ["record"]
    detect:
      width: 640   # Sub stream resolution
      height: 480
      fps: 5
    objects:
      track: ["person", "car"]
```

---

## Step 5: Deploy/Reload Frigate

### If Frigate is Already Running:
```bash
# Restart Frigate to pick up config changes
systemctl --user restart homeserver-frigate.service

# Check status
systemctl --user status homeserver-frigate.service

# View logs for errors
journalctl --user -u homeserver-frigate.service -f
```

### If Frigate is Not Deployed Yet:
```bash
# Run tests first
make test

# Deploy all services
make deploy

# Check status
make status
```

---

## Step 6: Verify Camera is Working

### Check Frigate Web Interface

1. Open browser: `http://192.168.1.100:5000` (replace with your Fedora IP)
2. You should see your camera(s) listed
3. Click on a camera to see live stream
4. Check that detection is working (objects should be highlighted)

### Check Logs for Errors

```bash
# View Frigate logs
journalctl --user -u homeserver-frigate.service -n 50

# Look for errors like:
# - "Failed to connect to camera"
# - "Authentication failed"
# - "Stream not found"
```

### Common Issues

**Camera Not Showing:**
- Check camera is `enabled: true` in config
- Verify RTSP URL is correct
- Check camera is accessible from Fedora machine: `ping [camera-ip]`

**Authentication Failed:**
- Double-check username and password
- Some cameras require special characters to be URL-encoded
- Try resetting camera password

**Stream Not Found:**
- Verify RTSP path is correct for your camera model
- Check camera has RTSP enabled in settings
- Try different RTSP path variations

**Poor Performance:**
- Use sub stream for detection (lower resolution)
- Reduce FPS in detect section (try fps: 5)
- Check CPU usage: `top` or `htop`

---

## Step 7: Optimize Detection Settings

### Adjust Detection FPS

Lower FPS = less CPU usage:
```yaml
detect:
  width: 1920
  height: 1080
  fps: 5  # Start with 5, increase if needed
```

### Adjust Object Detection

Only track objects you care about:
```yaml
objects:
  track: ["person", "car"]  # Only track people and cars
  # Remove "dog", "cat" if you don't need them
```

### Motion Detection Zones (Optional)

Define areas where motion matters:
```yaml
cameras:
  front_door:
    # ... other config ...
    zones:
      driveway:
        coordinates: 0,0,1920,0,1920,1080,0,1080
      porch:
        coordinates: 500,500,1420,500,1420,800,500,800
```

---

## Step 8: Configure Storage

Make sure you have storage configured for recordings:

```bash
# Check available storage
df -h

# Check Frigate data directory
ls -lh ~/Documents/GitHub/goofaround/data/media/frigate/

# If you need more storage, mount external drive:
# 1. Connect external drive
# 2. Find device: lsblk
# 3. Mount: sudo mount /dev/sdb1 /mnt/storage
# 4. Update Frigate config volume path in quadlet file
```

---

## Quick Reference: Camera Brands

### Reolink
- **Default IP:** Check router or use Reolink app
- **Default User:** `admin`
- **Default Password:** Usually set during first setup
- **RTSP Main:** `/h264Preview_01_main`
- **RTSP Sub:** `/h264Preview_01_sub`

### Amcrest
- **Default IP:** Often `192.168.1.108`
- **Default User:** `admin`
- **Default Password:** `admin` (change this!)
- **RTSP:** `/cam/realmonitor?channel=1&subtype=0`

### Wyze Cam v3 (with RTSP firmware)
- **RTSP:** `rtsp://[camera-ip]:554/live`
- **Note:** Requires custom firmware for RTSP

---

## Next Steps

After cameras are working:
1. Set up motion zones
2. Configure alerts/notifications
3. Set up Home Assistant integration
4. Create automations (motion → lights, etc.)
5. Configure recording retention

---

## Troubleshooting Commands

```bash
# Test RTSP stream
ffmpeg -rtsp_transport tcp -i "rtsp://user:pass@ip:554/path" -t 5 -f null -

# Check camera is reachable
ping [camera-ip]

# Check RTSP port is open
nc -zv [camera-ip] 554

# View Frigate logs
journalctl --user -u homeserver-frigate.service -f

# Restart Frigate
systemctl --user restart homeserver-frigate.service

# Check Frigate container
podman ps | grep frigate
podman logs homeserver-frigate
```

---

*Last Updated: December 2024*

