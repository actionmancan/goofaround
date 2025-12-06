# 🚀 Getting Started

Your complete guide to building a test-driven home server with Podman Quadlets!

## 📋 What You're Building

A production-ready home server running:
- 🏠 **Home Assistant** - Smart home control center
- 📹 **Frigate NVR** - AI-powered camera system
- 💡 **Zigbee2MQTT** - Control Zigbee lights, sensors, switches
- 📡 **Mosquitto** - MQTT message broker
- 🌐 **Nginx Proxy Manager** - Reverse proxy with SSL
- 🛡️ **AdGuard Home** - Network-wide ad blocking

All orchestrated with **Podman Quadlets** and built with **Test-Driven Development**.

## 🛒 Step 1: Shopping (Black Friday!)

See [docs/SHOPPING_LIST.md](docs/SHOPPING_LIST.md) for complete shopping guide.

### Essential Purchases
- [ ] Mini PC or server ($200-400)
- [ ] 2-4 IP cameras ($80-240)
- [ ] PoE switch ($50-70)
- [ ] Zigbee USB coordinator ($15-20)
- [ ] Smart bulbs/switches ($50-150)
- [ ] Storage drive for footage ($80-120)

### Budget Options
**~$500 Total**
- Used Dell Optiplex Micro ($200)
- 2x Reolink cameras ($80)
- 5-port PoE switch ($50)
- Sonoff Zigbee dongle ($20)
- 5x IKEA Trådfri bulbs ($50)
- 4TB WD Purple ($80)

## 🔧 Step 2: Hardware Setup

### Install Linux
1. Download Fedora or Ubuntu Server
2. Create bootable USB (see instructions below)
3. Install on your server

#### Creating Fedora Bootable USB on macOS

**Option 1: Using Fedora Media Writer (Recommended)**
1. Download Fedora Media Writer: https://getfedora.org/en/workstation/download/
2. Install and run Fedora Media Writer
3. Select "Custom Image" and choose your downloaded Fedora ISO
4. Select your USB drive and click "Write to Disk"
5. Wait for completion - this ensures proper labeling and boot structure

**Option 2: Using Command Line (dd)**
```bash
# 1. Download Fedora ISO from https://getfedora.org/
# 2. Identify your USB drive (be VERY careful - this will erase everything!)
diskutil list

# 3. Unmount the USB (replace diskX with your USB identifier)
diskutil unmountDisk /dev/diskX

# 4. Write the ISO to USB (replace diskX and path/to/fedora.iso)
sudo dd if=/path/to/Fedora-Workstation-Live-x86_64-XX.iso of=/dev/rdiskX bs=1m

# 5. Eject when done
diskutil eject /dev/diskX
```

**Important Notes:**
- The USB must be properly labeled as `Fedora-WS-Live-XX` for the installer to work
- If you see "Fedora-WS-Live-43 does not exist" error, the USB was not created correctly
- Always verify the USB boots before attempting installation
- Use Fedora Media Writer for best results - it handles all the details automatically

#### Troubleshooting "No Disks Selected" Error

If the Fedora installer shows "no disks selected", try these solutions:

**1. Check BIOS/UEFI Settings:**
- Enter BIOS/UEFI setup (usually F2, F12, or Del during boot)
- Look for "SATA Mode" or "Storage Configuration"
- Change from "RAID" or "Intel RST" to "AHCI" mode
- Save and reboot

**2. Disable Secure Boot (temporarily):**
- In BIOS/UEFI settings, find "Secure Boot"
- Disable it temporarily for installation
- Can re-enable after installation if desired

**3. Check Disk Format:**
- If disk was previously used with macOS/Windows, it may need initialization
- In Fedora installer, try clicking "Refresh" or "Rescan Disks"
- If still not visible, the disk may need to be formatted first

**4. NVMe Driver Issues:**
- Some NVMe drives need additional drivers
- Try booting with "nomodeset" kernel parameter
- Press `e` at GRUB menu, add `nomodeset` to kernel line

**5. Use Manual Partitioning:**
- Click "Custom" or "Manual" partitioning option
- This sometimes reveals disks that auto-detection misses

**6. Check Disk Connections:**
- Ensure SATA/NVMe cables are secure
- Try different SATA ports if available
- For external drives, ensure proper connection

**7. Boot Mode:**
- Ensure UEFI boot mode matches disk partition scheme
- Try switching between UEFI and Legacy BIOS modes

4. Update system:
```bash
sudo dnf update -y  # Fedora
# or
sudo apt update && sudo apt upgrade -y  # Ubuntu
```

### Install Podman
```bash
# Fedora/RHEL
sudo dnf install -y podman

# Ubuntu
sudo apt install -y podman

# Verify
podman --version  # Should be 4.4+
```

### Install Python
```bash
# Fedora
sudo dnf install -y python3 python3-pip

# Ubuntu
sudo apt install -y python3 python3-pip python3-venv
```

### Prevent System Sleep (Important for Servers!)

**Critical:** Your home server needs to stay awake 24/7. Disable sleep/suspend:

```bash
# Disable sleep in systemd-logind
sudo sed -i 's/#HandleSuspendKey=suspend/HandleSuspendKey=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#HandleHibernateKey=hibernate/HandleHibernateKey=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf

# Add settings if they don't exist
echo "HandleSuspendKey=ignore" | sudo tee -a /etc/systemd/logind.conf
echo "HandleHibernateKey=ignore" | sudo tee -a /etc/systemd/logind.conf
echo "HandleLidSwitch=ignore" | sudo tee -a /etc/systemd/logind.conf

# Mask sleep targets (prevents sleep completely)
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Restart logind service
sudo systemctl restart systemd-logind

# Disable network sleep
for iface in /sys/class/net/*; do
    echo "on" | sudo tee "$iface/power/control" 2>/dev/null
done
```

**If using GNOME desktop (Fedora Workstation):**
```bash
# Disable screen blanking and suspend
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
```

**Reboot after making these changes:**
```bash
sudo reboot
```

See [PREVENT_SLEEP_FEDORA.md](PREVENT_SLEEP_FEDORA.md) for complete details and troubleshooting.

### Connect Hardware
1. **Cameras**: Connect to PoE switch
2. **PoE Switch**: Connect to router
3. **Zigbee USB**: Plug into server
4. **Storage Drive**: Install/connect to server

## 💻 Step 3: Project Setup

### Clone Repository
```bash
cd ~/Documents/GitHub
git clone ssh://git@gitlab.cee.redhat.com/nesmith/homeserver.git goofaround
cd goofaround
```

### Initialize Project
```bash
# Create virtual environment and install dependencies
make setup

# Initialize default configurations
make init-configs
```

This creates:
- Python virtual environment (`.venv/`)
- Config directories (`configs/`)
- Data directories (`data/`)
- Default configuration files

## 🧪 Step 4: Test-Driven Setup

### Run Initial Tests
```bash
# Activate virtual environment
source .venv/bin/activate

# Run unit tests (should all pass)
make test-unit
```

Expected output:
```
🧪 Running unit tests...
======================== test session starts ========================
tests/unit/test_quadlet_files.py ........  [ 50%]
tests/unit/test_configs.py ........        [100%]

======================== 16 passed in 0.50s =========================
✅ All tests passed!
```

### Validate Quadlets
```bash
make validate
```

This ensures all quadlet files are properly formatted.

## ⚙️ Step 5: Configuration

### Find Your Zigbee Device
```bash
ls -l /dev/serial/by-id/
```

Look for something like:
```
usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20231023123456-if00
```

### Update Zigbee Configuration

Edit `quadlets/homeserver-zigbee2mqtt.container`:

```ini
# Change this line:
AddDevice=/dev/ttyACM0

# To your device (or create symlink):
AddDevice=/dev/serial/by-id/usb-ITEAD_SONOFF_...
```

Or create a symlink:
```bash
sudo ln -s /dev/serial/by-id/usb-ITEAD_SONOFF_... /dev/ttyACM0
```

### Configure Cameras

Edit `configs/frigate/config.yml`:

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

Replace:
- `admin:password` with your camera credentials
- `192.168.1.100` with your camera IP
- `front_door` with your camera name

Add more cameras as needed.

### Set Timezone

Update timezone in all quadlet files (default is `America/New_York`):

```bash
# Find your timezone
timedatectl list-timezones | grep -i york

# Use sed to replace in all files
cd quadlets
sed -i 's/America\/New_York/Your\/Timezone/g' *.container
```

## 🚀 Step 6: Deploy!

### Pre-deployment Test
```bash
# Run all tests
make test

# Validate configurations
make validate
```

### Deploy Services
```bash
make deploy
```

This will:
1. Copy quadlet files to systemd
2. Reload systemd daemon
3. Create network
4. Start services in correct order
5. Enable auto-start on boot

Expected output:
```
🔧 Setting up project...
🚀 Deploying quadlets...
✅ Deployment complete!

Service URLs:
  Home Assistant:       http://localhost:8123
  Frigate NVR:          http://localhost:5000
  Zigbee2MQTT:          http://localhost:8080
  Nginx Proxy Manager:  http://localhost:8181
  AdGuard Home:         http://localhost:3000
```

### Check Status
```bash
make status
```

All services should show **active (running)**.

### View Logs
```bash
# All services
make logs

# Specific service
make logs SERVICE=homeassistant
```

## 🎯 Step 7: Initial Configuration

### 1. Home Assistant (http://localhost:8123)
1. Open in browser
2. Create admin account
3. Follow onboarding wizard
4. MQTT should auto-configure
5. Wait for integrations to discover

### 2. Zigbee2MQTT (http://localhost:8080)
1. Open web interface
2. Go to Settings → Permit Join
3. Enable joining
4. Press pair button on Zigbee device
5. Device should appear in Home Assistant

### 3. Frigate (http://localhost:5000)
1. Open web interface
2. Verify cameras are streaming
3. Check detection is working
4. Configure zones if needed

### 4. Nginx Proxy Manager (http://localhost:8181)
**Default login**: admin@example.com / changeme
1. Login and **CHANGE PASSWORD**
2. Add proxy hosts for each service
3. Configure SSL certificates (Let's Encrypt)

### 5. AdGuard Home (http://localhost:3000)
1. Complete initial setup wizard
2. Set admin password
3. Configure as DNS server on router OR
4. Set DNS on individual devices

## ✅ Step 8: Verification

### Test Smart Home Workflow
1. Pair a Zigbee bulb via Zigbee2MQTT
2. Refresh Home Assistant
3. Find bulb in devices
4. Toggle bulb on/off
5. Create simple automation

### Test Camera System
1. View live stream in Frigate
2. Trigger motion detection
3. Check recording appears
4. Verify event in Home Assistant

### Test Persistence
```bash
# Restart a service
make restart SERVICE=homeassistant

# Verify it comes back up
make status

# Check data persisted
```

## 📊 Step 9: Monitoring

### Daily Checks
```bash
# Service status
make status

# Recent logs
journalctl --user -u 'homeserver-*' --since "1 hour ago"

# Resource usage
podman stats
```

### Backup
```bash
# Create backup
make backup

# Backups stored in: backups/
ls -lh backups/
```

## 🔧 Troubleshooting

### Service Won't Start
```bash
# Check logs
journalctl --user -u homeserver-servicename -n 50

# Check configuration
cat ~/.config/containers/systemd/homeserver-servicename.container

# Try manual start
systemctl --user start homeserver-servicename
```

### Permission Denied (USB Device)
```bash
# Add user to dialout group
sudo usermod -aG dialout $USER

# Logout and login again
```

### Can't Access Web Interfaces
```bash
# Check if service is running
systemctl --user status homeserver-servicename

# Check port is listening
sudo ss -tlnp | grep :8123

# Check firewall
sudo firewall-cmd --list-ports  # Fedora
sudo ufw status                 # Ubuntu
```

### Camera Not Showing in Frigate
1. Test RTSP stream: `ffplay rtsp://admin:password@camera-ip:554/stream`
2. Check Frigate logs: `make logs SERVICE=frigate`
3. Verify camera IP and credentials
4. Check network connectivity

## 📚 Next Steps

### Learn More
- [Architecture Details](docs/ARCHITECTURE.md)
- [Podman Quadlets Guide](docs/PODMAN_QUADLETS.md)
- [TDD Workflow](docs/TDD_WORKFLOW.md)
- [Quick Start Guide](docs/QUICKSTART.md)
- [Fedora Installation Troubleshooting](docs/FEDORA_INSTALL_TROUBLESHOOTING.md) - Common issues and solutions

### Expand Your System
- Add more cameras
- Pair more Zigbee devices
- Create automations
- Set up remote access
- Configure notifications

### Join the Community
- [Home Assistant Community](https://community.home-assistant.io/)
- [Frigate Discussions](https://github.com/blakeblackshear/frigate/discussions)
- [r/homeassistant](https://reddit.com/r/homeassistant)
- [r/selfhosted](https://reddit.com/r/selfhosted)

## 🎉 You're Done!

You now have a production-ready, test-driven home server running on Podman Quadlets!

Key achievements:
- ✅ Services managed by systemd
- ✅ Auto-restart on failure
- ✅ Auto-start on boot
- ✅ Test coverage
- ✅ Backup strategy
- ✅ Scalable architecture

**Enjoy your smart home! 🏠✨**


