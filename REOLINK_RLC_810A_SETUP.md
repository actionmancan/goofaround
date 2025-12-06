# Reolink RLC-810A Physical Setup Guide

Complete guide for physically installing and connecting your Reolink RLC-810A 4K PoE camera.

---

## What's in the Box

- RLC-810A camera
- Mounting bracket
- Screws and anchors (for mounting)
- Ethernet cable (usually 3-5 feet)
- Waterproof connector kit
- Quick start guide

---

## Step 1: Choose Mounting Location

### Considerations:
- **Field of view:** What do you want to monitor?
- **Height:** 8-12 feet is ideal (high enough to avoid tampering, low enough for good detail)
- **Power:** Must be within Ethernet cable distance of PoE switch
- **Weather:** RLC-810A is weatherproof (IP67), but avoid direct heavy rain if possible
- **Lighting:** Consider day/night conditions
- **Network:** Must be able to run Ethernet cable to this location

### Best Practices:
- Point camera away from direct sunlight (prevents glare)
- Avoid pointing at windows (reflections)
- Consider privacy (neighbors, public areas)
- Test location first before permanent mounting

---

## Step 2: Mount the Camera

### Option A: Wall Mount (Most Common)

1. **Hold bracket against wall** where you want camera
2. **Mark screw holes** with pencil
3. **Drill holes** (use appropriate bit for your wall type)
   - Drywall: Use anchors included
   - Brick/Concrete: Use masonry bit
   - Wood: Direct screws work fine
4. **Insert anchors** (if needed)
5. **Screw bracket to wall** using included screws
6. **Attach camera to bracket:**
   - Loosen the ball joint on camera
   - Slide camera onto bracket
   - Tighten ball joint
   - Adjust angle as needed

### Option B: Ceiling Mount

1. Follow same steps as wall mount
2. Mount bracket to ceiling
3. Camera hangs down from bracket
4. Adjust angle using ball joint

### Option C: Pole Mount

1. Use included pole mount adapter (if provided)
2. Wrap around pole
3. Tighten securely
4. Attach camera

---

## Step 3: Connect Ethernet Cable

### Important: RLC-810A Uses PoE (Power over Ethernet)

**You need:**
- PoE switch (like TP-Link TL-SG1005P or TL-SG1008P)
- OR PoE injector (if you don't have PoE switch yet)
- Ethernet cable (Cat5e or Cat6) from camera to switch

### Connection Steps:

1. **Run Ethernet cable** from camera location to PoE switch location
   - Can be up to 100 meters (328 feet)
   - Use outdoor-rated cable if running outside
   - Protect cable from damage (conduit, cable clips, etc.)

2. **At camera end:**
   - Connect Ethernet cable to camera's Ethernet port
   - Use waterproof connector (included) if camera is outside:
     - Slide rubber gasket over cable
     - Insert cable into connector
     - Tighten connector to camera
     - Ensures weatherproof seal

3. **At switch end:**
   - Connect Ethernet cable to **PoE port** on switch
   - PoE ports are usually marked (often ports 1-4 on 5-port switch)
   - Non-PoE ports won't power the camera!

### Using PoE Injector (If No PoE Switch Yet):

If you don't have a PoE switch, use a PoE injector:

1. **PoE Injector Setup:**
   ```
   Router/Switch → Ethernet → PoE Injector → Ethernet → Camera
                      ↓
                   Power Adapter
   ```

2. **Connect:**
   - Ethernet from router/switch → PoE Injector "LAN" port
   - Ethernet from PoE Injector "PoE" port → Camera
   - Power adapter → PoE Injector

3. **PoE Injector Options:**
   - TP-Link TL-PoE150S (~$15)
   - Ubiquiti PoE Injector (~$20)

---

## Step 4: Power On and Initial Setup

### Check Camera Power:

1. **LED Indicator:**
   - Camera should have LED that lights up when powered
   - Usually blue or green when working
   - Blinking = booting up
   - Solid = ready

2. **If no LED:**
   - Check Ethernet connection
   - Verify PoE switch is powered
   - Check PoE port is enabled (some switches have per-port controls)
   - Try different PoE port

### Find Camera on Network:

**Option 1: Reolink App (Easiest)**
1. Download Reolink app on phone
2. Open app → Add Device
3. Scan QR code on camera (or enter UID)
4. App will find camera and configure

**Option 2: Router Admin Panel**
1. Log into router (usually 192.168.1.1 or 192.168.0.1)
2. Check connected devices
3. Look for "Reolink" or device with MAC address starting with Reolink's prefix
4. Note the IP address

**Option 3: Scan Network (from Fedora)**
```bash
# Install nmap if needed
sudo dnf install -y nmap

# Scan for cameras (port 80 = web interface, port 554 = RTSP)
nmap -p 80,554 192.168.1.0/24

# Look for Reolink device
```

**Option 4: Reolink Client Software**
1. Download Reolink Client for Mac/Windows
2. Open → Device Settings → Add Device
3. Scan for devices on network
4. Will show IP address

---

## Step 5: Initial Camera Configuration

### Access Camera Web Interface:

1. **Open browser** on computer on same network
2. **Navigate to camera IP** (found in Step 4)
   - Example: `http://192.168.1.100`
3. **Login:**
   - Default username: `admin`
   - Default password: Check camera label or Reolink app
   - **IMPORTANT:** Change password immediately!

### Initial Settings to Configure:

1. **Change Password:**
   - Settings → User Management → Change Password
   - Use strong password (you'll need this for Frigate)

2. **Set Time Zone:**
   - Settings → System → Time Settings
   - Set correct timezone

3. **Enable RTSP:**
   - Settings → Network → Advanced
   - Enable RTSP (usually enabled by default)
   - Note RTSP port (usually 554)

4. **Set Static IP (Recommended):**
   - Settings → Network → TCP/IP
   - Change from DHCP to Static IP
   - Set IP address (e.g., 192.168.1.100)
   - Set subnet mask (usually 255.255.255.0)
   - Set gateway (your router IP, usually 192.168.1.1)
   - Set DNS (usually same as gateway or 8.8.8.8)
   - **Why:** Prevents IP from changing, makes Frigate config easier

5. **Adjust Camera Settings:**
   - Resolution: Should be 4K (3840x2160) for main stream
   - Frame rate: 15-25 fps is good
   - Bitrate: Higher = better quality but more storage
   - Night vision: Auto or schedule

---

## Step 6: Test Camera Connection

### Test from Browser:

1. Open camera web interface
2. Click "Live View"
3. Should see camera feed
4. Test day/night vision

### Test RTSP Stream (for Frigate):

From your Fedora machine:

```bash
# Install ffmpeg if needed
sudo dnf install -y ffmpeg

# Test main stream (replace IP and password)
ffmpeg -rtsp_transport tcp -i "rtsp://admin:yourpassword@192.168.1.100:554/h264Preview_01_main" -t 5 -f null -

# Test sub stream
ffmpeg -rtsp_transport tcp -i "rtsp://admin:yourpassword@192.168.1.100:554/h264Preview_01_sub" -t 5 -f null -

# If successful, you'll see output without errors
```

### Test from VLC (Optional):

1. Open VLC Media Player
2. Media → Open Network Stream
3. Enter: `rtsp://admin:password@192.168.1.100:554/h264Preview_01_main`
4. Click Play
5. Should see camera feed

---

## Step 7: Final Adjustments

### Adjust Camera Angle:

1. **Loosen ball joint** on camera mount
2. **Point camera** where you want to monitor
3. **Tighten ball joint** to lock position
4. **Check view** via web interface or app
5. **Fine-tune** as needed

### Camera Settings to Consider:

- **Motion Detection Zones:** Set in Reolink app/web interface
- **Recording Schedule:** Set when to record
- **Email Alerts:** Configure if desired
- **Night Vision:** Auto or manual control
- **IR Lights:** Adjust intensity if needed

---

## Troubleshooting

### Camera Won't Power On:

- ✅ Check PoE switch is powered
- ✅ Verify Ethernet cable is connected securely
- ✅ Try different PoE port on switch
- ✅ Check cable isn't damaged
- ✅ Try different Ethernet cable
- ✅ Verify PoE port is enabled (some switches have per-port controls)

### Can't Find Camera on Network:

- ✅ Check camera LED is on (powered)
- ✅ Verify camera and computer are on same network
- ✅ Check router's connected devices list
- ✅ Try Reolink app to find camera
- ✅ Reset camera (hold reset button 10 seconds)
- ✅ Check firewall isn't blocking

### No Video Feed:

- ✅ Check camera web interface loads
- ✅ Verify RTSP is enabled in camera settings
- ✅ Test RTSP URL with ffmpeg or VLC
- ✅ Check username/password are correct
- ✅ Verify IP address hasn't changed

### Poor Video Quality:

- ✅ Check resolution settings (should be 4K for main stream)
- ✅ Verify bitrate isn't too low
- ✅ Check network connection (PoE can affect if cable is poor)
- ✅ Clean camera lens
- ✅ Adjust camera angle (avoid glare)

---

## Network Setup Summary

### Typical Setup:

```
Internet Router
    ↓
PoE Switch (TP-Link TL-SG1005P)
    ├── Port 1 (PoE) → Camera 1 (RLC-810A)
    ├── Port 2 (PoE) → Camera 2 (future)
    ├── Port 3 (PoE) → Camera 3 (future)
    ├── Port 4 (PoE) → Camera 4 (future)
    └── Port 5 (Non-PoE) → Fedora Server
```

### Cable Management Tips:

- Use cable clips to secure cable along wall
- Use conduit for outdoor runs
- Label cables (which camera, which port)
- Leave slack at camera end for adjustments
- Protect outdoor connections with waterproof connectors

---

## Next Steps

After physical setup is complete:

1. ✅ Camera is mounted and connected
2. ✅ Camera has power (LED on)
3. ✅ Camera is on network (found IP address)
4. ✅ Camera password changed
5. ✅ RTSP stream tested
6. ✅ Camera angle adjusted

**Now configure Frigate:**
- See [CAMERA_SETUP.md](CAMERA_SETUP.md) for Frigate configuration
- Add camera to `configs/frigate/config.yml`
- Restart Frigate service
- View camera in Frigate web interface

---

## Quick Reference

**Camera Model:** Reolink RLC-810A  
**Type:** PoE (Power over Ethernet)  
**Resolution:** 4K (3840x2160)  
**Default Username:** admin  
**Default Password:** Check camera label  
**RTSP Main Stream:** `rtsp://admin:password@[ip]:554/h264Preview_01_main`  
**RTSP Sub Stream:** `rtsp://admin:password@[ip]:554/h264Preview_01_sub`  
**Web Interface:** `http://[camera-ip]`  
**RTSP Port:** 554  
**HTTP Port:** 80  

---

*Last Updated: December 2024*

